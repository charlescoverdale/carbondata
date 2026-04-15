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

# Build a standard httr2 request with Mozilla User-Agent (required by some
# EC servers like climate.ec.europa.eu which return 429 to bare curl UA),
# retry behaviour, and modest throttling.
co2_request <- function(url) {
  req <- httr2::request(url)
  req <- httr2::req_user_agent(
    req,
    "Mozilla/5.0 (compatible; carbondata R package; https://github.com/charlescoverdale/carbondata)"
  )
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

# Download a URL to a file with caching
co2_download <- function(url, dest, refresh = FALSE) {
  if (file.exists(dest) && !refresh) {
    return(dest)
  }
  req <- co2_request(url)
  resp <- tryCatch(
    httr2::req_perform(req, path = dest),
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

# Case-insensitive column picker for messy published datasets
co2_pick <- function(df, patterns, default = NA_character_) {
  n <- names(df)
  for (p in patterns) {
    hit <- n[tolower(n) == tolower(p)]
    if (length(hit) > 0L) return(df[[hit[1L]]])
    hit <- n[grepl(p, n, ignore.case = TRUE)]
    if (length(hit) > 0L) return(df[[hit[1L]]])
  }
  rep(default, nrow(df))
}
