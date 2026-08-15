# Internal helpers (not exported)

`%||%` <- function(a, b) if (is.null(a)) b else a

# Package-level env for runtime state (API keys, etc.)
co2_env <- new.env(parent = emptyenv())

# Cache directory (configurable via options, fallback to R_user_dir)
co2_cache_dir <- function() {
  d <- getOption("carbondata.cache_dir",
                 default = tools::R_user_dir("carbondata", "cache"))
  if (!dir.exists(d)) dir.create(d, recursive = TRUE)
  d
}

# Normalise and validate a year argument
co2_validate_year <- function(year, min_year = 1990L) {
  if (is.null(year)) return(NULL)
  if (!is.numeric(year)) {
    cli_abort("{.arg year} must be numeric.")
  }
  year <- as.integer(year)
  current_year <- as.integer(format(Sys.Date(), "%Y"))
  bad <- year < min_year | year > current_year
  if (any(bad)) {
    cli_abort("{.arg year} must be between {min_year} and {current_year}.")
  }
  year
}

# Normalise a date argument to ISO string or NULL
co2_validate_date <- function(x, arg = "date") {
  if (is.null(x)) return(NULL)
  d <- tryCatch(as.Date(x), error = function(e) NA)
  if (is.na(d)) {
    cli_abort("{.arg {arg}} must be a date or ISO string (YYYY-MM-DD).")
  }
  format(d, "%Y-%m-%d")
}

# Some EC servers (climate.ec.europa.eu) return 429 to a bare curl UA.
.co2_user_agent <- paste0(
  "Mozilla/5.0 (compatible; carbondata R package; ",
  "https://github.com/charlescoverdale/carbondata)"
)

# Build a standard httr2 request with the package User-Agent, retry
# behaviour, and modest throttling.
co2_request <- function(url) {
  req <- httr2::request(url)
  req <- httr2::req_user_agent(req, .co2_user_agent)
  req <- httr2::req_retry(
    req,
    max_tries = 3L,
    is_transient = function(resp) {
      httr2::resp_status(resp) %in% c(429L, 503L)
    },
    backoff = ~ min(60, 2 ^ .x)
  )
  req <- httr2::req_throttle(req, rate = 2)
  req
}

# Download a URL to a file with caching. `max_age_days` re-downloads a
# cached file older than the given age; use for sources that update in
# place under a stable filename (EEX current-year report, ICAP JSON).
co2_download <- function(url, dest, refresh = FALSE, max_age_days = Inf) {
  if (file.exists(dest) && !refresh) {
    age_days <- as.numeric(difftime(Sys.time(), file.mtime(dest), units = "days"))
    if (age_days <= max_age_days) {
      return(dest)
    }
    cli_inform(c("i" = "Cached copy is {round(age_days, 1)} days old; re-downloading."))
  }
  # Download to a temporary file and move it into place only on
  # success. httr2 writes the response body to `path` before it raises
  # on an HTTP error, so writing straight to `dest` leaves the error
  # page sitting in the cache, and every later call serves that instead
  # of re-fetching.
  tmp <- paste0(dest, ".part")
  on.exit(unlink(tmp), add = TRUE)
  req <- co2_request(url)
  resp <- tryCatch(
    httr2::req_perform(req, path = tmp),
    error = function(e) {
      cli_abort(c(
        "Failed to download {.url {url}}.",
        "x" = conditionMessage(e),
        "i" = "If the publisher has moved the file, pass {.code refresh = TRUE}",
        " " = "or report at https://github.com/charlescoverdale/carbondata/issues."
      ))
    }
  )
  status <- httr2::resp_status(resp)
  if (status >= 400L) {
    cli_abort("Download failed with HTTP {status}: {.url {url}}")
  }
  # A 200 carrying an empty body is not a success. CDNs in front of some
  # publishers answer automated clients that way instead of sending a 403.
  # Letting it through is worse than the bad response itself: the empty
  # file lands in the cache, the next call sees a cached copy and skips
  # the fetch, and every later call fails in the parser with an error
  # that says nothing about the download ("no lines available in input").
  size <- file.size(tmp)
  if (is.na(size) || size == 0) {
    cli_abort(c(
      "Download of {.url {url}} returned HTTP {status} with an empty body.",
      "i" = "The publisher may be refusing automated clients from this network.",
      " " = "Retry later, or report at",
      " " = "https://github.com/charlescoverdale/carbondata/issues."
    ))
  }
  if (!file.rename(tmp, dest)) {
    # rename fails across filesystems; fall back to a copy.
    if (!file.copy(tmp, dest, overwrite = TRUE)) {
      cli_abort("Could not write downloaded file to {.file {dest}}.")
    }
  }
  dest
}

# Fetch HTML from a landing page and extract download URLs matching a regex.
# Used for sources that publish date-stamped filenames on a stable landing
# page (GOV.UK, CARB, Berkeley GSPP).
co2_scrape_links <- function(page_url, pattern) {
  req <- co2_request(page_url)
  resp <- tryCatch(
    httr2::req_perform(req),
    error = function(e) {
      cli_abort(c(
        "Failed to reach landing page {.url {page_url}}.",
        "x" = conditionMessage(e)
      ))
    }
  )
  if (httr2::resp_status(resp) >= 400L) {
    cli_abort("Landing page returned HTTP {httr2::resp_status(resp)}.")
  }
  html <- httr2::resp_body_string(resp)
  hrefs <- regmatches(html, gregexpr('href="[^"]+"', html))[[1L]]
  hrefs <- gsub('^href="|"$', "", hrefs)
  hrefs <- gsub("&amp;", "&", hrefs, fixed = TRUE)
  hits <- grep(pattern, hrefs, value = TRUE)
  # Resolve relative URLs
  base_url <- sub("(https?://[^/]+).*", "\\1", page_url)
  ifelse(grepl("^https?://", hits), hits, paste0(base_url, hits))
}

# Convert a list of parsed JSON records to a data frame
co2_list_to_df <- function(items) {
  if (length(items) == 0L) return(data.frame())
  cols <- unique(unlist(lapply(items, names)))
  cols_data <- lapply(cols, function(col) {
    vals <- lapply(items, function(item) {
      v <- item[[col]]
      if (is.null(v) || length(v) == 0L) return(NA_character_)
      if (is.list(v)) return(paste(unlist(v), collapse = ";"))
      if (length(v) > 1L) return(paste(as.character(v), collapse = ";"))
      as.character(v)
    })
    unlist(vals, use.names = FALSE)
  })
  names(cols_data) <- cols
  as.data.frame(cols_data, stringsAsFactors = FALSE)
}

# Pick the newest release from a set of date-stamped download URLs.
# Plain lexical sorting is wrong whenever a publisher mixes numbering
# schemes: Berkeley's VROD archive holds both "v4-2021-year-end" and
# "v2026-06", and "v4" sorts above "v2026". Rank by the date embedded
# in the filename instead, falling back to lexical order for names
# carrying no parseable date.
co2_latest_release <- function(urls) {
  if (length(urls) == 0L) return(character(0L))
  score <- vapply(basename(urls), function(f) {
    ym <- regmatches(f, regexpr("(19|20)\\d{2}[-_]\\d{2}([-_]\\d{2})?", f))
    if (length(ym) == 1L) {
      parts <- as.integer(strsplit(gsub("[-_]", " ", ym), " ")[[1L]])
      parts <- c(parts, rep(1L, 3L - length(parts)))
      return(parts[1L] * 10000 + parts[2L] * 100 + parts[3L])
    }
    y <- regmatches(f, regexpr("(19|20)\\d{2}", f))
    if (length(y) == 1L) return(as.integer(y) * 10000)
    NA_real_
  }, numeric(1L))
  if (all(is.na(score))) return(sort(urls, decreasing = TRUE)[1L])
  urls[order(score, urls, decreasing = TRUE, na.last = TRUE)][1L]
}

# Collapse whitespace inside column names. Spreadsheet headers that
# wrap across lines carry the line break into the name, so VROD ships
# columns literally called "Total Credits \r\nIssued". Nobody can guess
# that, and it makes every reference to the column unreadable.
co2_clean_names <- function(df) {
  names(df) <- trimws(gsub("[[:space:]]+", " ", names(df)))
  df
}

# Make a published filename safe to use as a cache filename. Publishers
# put characters like "&" in filenames (UK ETS compliance report).
co2_safe_filename <- function(x) {
  x <- utils::URLdecode(x)
  x <- gsub("[^A-Za-z0-9._-]+", "_", x)
  gsub("_{2,}", "_", x)
}

# Format bytes as human-readable string
co2_format_bytes <- function(x) {
  if (is.na(x) || x < 1024) return(paste0(x, " B"))
  units <- c("KB", "MB", "GB", "TB")
  for (i in seq_along(units)) {
    x <- x / 1024
    if (x < 1024 || i == length(units)) {
      return(sprintf("%.1f %s", x, units[i]))
    }
  }
}

# Case-insensitive column picker for messy published datasets.
# `required = TRUE` aborts (instead of silently filling the default) when
# no pattern matches: silent NA identifier columns turn downstream filters
# into empty results with no explanation.
co2_pick <- function(df, patterns, default = NA_character_, required = FALSE) {
  n <- names(df)
  for (p in patterns) {
    hit <- n[tolower(n) == tolower(p)]
    if (length(hit) > 0L) return(df[[hit[1L]]])
    hit <- n[grepl(p, n, ignore.case = TRUE)]
    if (length(hit) > 0L) return(df[[hit[1L]]])
  }
  if (required) {
    cli_abort(c(
      "Expected a column matching {.val {patterns}} but found none.",
      "i" = "Columns present: {.val {utils::head(n, 20)}}.",
      "i" = "The publisher may have changed the file layout; please report at",
      " " = "https://github.com/charlescoverdale/carbondata/issues."
    ))
  }
  rep(default, nrow(df))
}

# Locate the header row in a spreadsheet whose publisher prepends banner
# rows above the real header. Returns the number of rows to skip so that
# the row containing `marker` becomes the header row.
co2_find_header_row <- function(path, marker, sheet = 1L, max_rows = 60L) {
  raw <- suppressMessages(
    readxl::read_excel(path, sheet = sheet, col_names = FALSE,
                       n_max = max_rows, col_types = "text")
  )
  for (i in seq_len(nrow(raw))) {
    vals <- as.character(unlist(raw[i, ]))
    if (any(grepl(marker, vals, ignore.case = TRUE), na.rm = TRUE)) {
      return(i - 1L)
    }
  }
  cli_abort(c(
    "Could not find a header row containing {.val {marker}} in {.file {basename(path)}}.",
    "i" = "The publisher may have changed the file layout; please report at",
    " " = "https://github.com/charlescoverdale/carbondata/issues."
  ))
}
