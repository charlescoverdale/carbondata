# Cross-market aggregators: ICAP, World Bank, RFF/WCPD.

# Public API behind worldcarbonpricing.org. Serves the emissions-
# weighted carbon price (ECP) dataset without a key; full raw WCPD
# downloads need an emailed token and are not wrapped here.
.ecp_api_base <- "https://wcpd-dashboard.onrender.com/api/ecp"

#' ICAP Allowance Price Explorer
#'
#' Fetches allowance prices across 20+ Emissions Trading Systems from
#' the International Carbon Action Partnership (ICAP) Allowance Price
#' Explorer. Covers EU ETS, UK ETS, California, RGGI, New Zealand,
#' Korea, and other jurisdictions with auction and secondary-market
#' prices where available.
#'
#' @param jurisdiction Optional character vector. Filter by
#'   jurisdiction name. Matching is case-insensitive and partial, so
#'   `"EU ETS"` matches
#'   `"European Union Emissions Trading System (from 2019)"`. When
#'   `NULL`, returns all. Use [co2_icap_systems()] to list the exact
#'   names.
#' @param include_download Logical. ICAP publishes a second "(download)"
#'   copy of several systems carrying the same prices as the main
#'   series. These are excluded by default, because including them
#'   duplicates a system in any chart or average. Set `TRUE` to keep
#'   them.
#' @param refresh Re-download? Default `FALSE`. The cached copy is
#'   refreshed automatically when it is more than a day old.
#'
#' @return A data frame with `date`, `jurisdiction`, `market_type`
#'   (`"primary"` auction or `"secondary"`), `price`, and `currency`.
#'
#' @family aggregators
#' @export
#' @examples
#' \donttest{
#' op <- options(carbondata.cache_dir = tempdir())
#' prices <- co2_icap_prices(jurisdiction = "EU ETS")
#' options(op)
#' }
co2_icap_prices <- function(jurisdiction = NULL, include_download = FALSE,
                            refresh = FALSE) {
  body <- .icap_body(refresh)
  if (length(body) == 0L) return(data.frame())

  # Build one long vector per column rather than rbind-ing ~45,000
  # single-row data frames.
  parts <- list()
  for (sys in body) {
    name <- trimws(sys$name %||% NA_character_)
    curr <- if (!is.null(sys$currency)) sys$currency[[1L]] else "USD"
    for (mt in c("primary", "secondary")) {
      vals <- sys$values[[mt]]
      if (is.null(vals) || length(vals) == 0L) next
      price <- suppressWarnings(as.numeric(unlist(
        lapply(vals, function(v) if (length(v) == 0L) NA_real_ else v[[1L]]),
        use.names = FALSE
      )))
      keep <- !is.na(price)
      if (!any(keep)) next
      parts[[length(parts) + 1L]] <- list(
        date = names(vals)[keep],
        jurisdiction = rep(name, sum(keep)),
        market_type = rep(mt, sum(keep)),
        price = price[keep],
        currency = rep(curr, sum(keep))
      )
    }
  }
  if (length(parts) == 0L) return(data.frame())

  out <- data.frame(
    date = as.Date(unlist(lapply(parts, `[[`, "date"), use.names = FALSE)),
    jurisdiction = unlist(lapply(parts, `[[`, "jurisdiction"), use.names = FALSE),
    market_type = unlist(lapply(parts, `[[`, "market_type"), use.names = FALSE),
    price = unlist(lapply(parts, `[[`, "price"), use.names = FALSE),
    currency = unlist(lapply(parts, `[[`, "currency"), use.names = FALSE),
    stringsAsFactors = FALSE
  )

  # The "(download)" entries repeat an existing system's prices; every
  # one of them has a main-series counterpart, so dropping them loses
  # no system and avoids plotting the same market twice.
  if (!include_download) {
    out <- out[!grepl("download\\)$", out$jurisdiction), , drop = FALSE]
  }

  if (!is.null(jurisdiction)) {
    out <- out[.icap_match(out$jurisdiction, jurisdiction), , drop = FALSE]
  }
  out <- out[order(out$jurisdiction, out$market_type, out$date), , drop = FALSE]
  rownames(out) <- NULL
  out
}

#' ICAP systems available
#'
#' Lists the emissions trading systems carried by the ICAP Allowance
#' Price Explorer, with the date range and number of observations for
#' each. Use this to find the exact `jurisdiction` names accepted by
#' [co2_icap_prices()].
#'
#' @inheritParams co2_icap_prices
#' @param refresh Re-download? Default `FALSE`.
#' @return A data frame with `jurisdiction`, `currency`, `market_type`,
#'   `first_date`, `last_date`, and `n_obs`.
#' @family aggregators
#' @export
#' @examples
#' \donttest{
#' op <- options(carbondata.cache_dir = tempdir())
#' co2_icap_systems()
#' options(op)
#' }
co2_icap_systems <- function(include_download = FALSE, refresh = FALSE) {
  df <- co2_icap_prices(include_download = include_download, refresh = refresh)
  if (nrow(df) == 0L) return(data.frame())
  key <- paste(df$jurisdiction, df$market_type, sep = "\r")
  split_df <- split(df, key)
  out <- do.call(rbind, lapply(split_df, function(g) {
    data.frame(
      jurisdiction = g$jurisdiction[1L],
      currency = g$currency[1L],
      market_type = g$market_type[1L],
      first_date = min(g$date),
      last_date = max(g$date),
      n_obs = nrow(g),
      stringsAsFactors = FALSE
    )
  }))
  out <- out[order(out$jurisdiction, out$market_type), , drop = FALSE]
  rownames(out) <- NULL
  out
}

#' @noRd
.icap_body <- function(refresh = FALSE) {
  url <- "https://allowancepriceexplorer.icapcarbonaction.com/api/systems"
  dest <- file.path(co2_cache_dir(), "icap_prices.json")
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading ICAP Allowance Price Explorer data..."))
  }
  co2_download(url, dest, refresh = refresh, max_age_days = 1)
  jsonlite::fromJSON(dest, simplifyVector = FALSE)
}

# Common short names mapped to a regex over ICAP's official names.
# ICAP spells systems out in full and versions them ("European Union
# Emissions Trading System (from 2019)"), so the abbreviations people
# actually type match nothing on their own.
.icap_aliases <- list(
  "eu ets"      = "^European Union Emissions Trading System",
  "eu"          = "^European Union Emissions Trading System",
  "uk ets"      = "^United Kingdom Emissions Trading Scheme",
  "uk"          = "^United Kingdom Emissions Trading Scheme",
  "rggi"        = "^Regional Greenhouse Gas Initiative",
  "california"  = "^California Cap-and-Trade",
  "quebec"      = "Cap-and-Trade System",
  "korea"       = "^Korean Emissions Trading System",
  "china"       = "^China National Emissions Trading System",
  "new zealand" = "^New Zealand Emissions Trading System",
  "nz ets"      = "^New Zealand Emissions Trading System",
  "germany"     = "^German National Emissions Trading System",
  "switzerland" = "^Switzerland Emissions Trading System",
  "washington"  = "^Washington Cap-and-Invest"
)

# Match user-supplied jurisdiction names against ICAP's official names,
# via alias, exact match, or substring, in that order.
#' @noRd
.icap_match <- function(available, wanted) {
  hit <- rep(FALSE, length(available))
  unmatched <- character(0L)
  clean <- tolower(trimws(available))
  for (w in wanted) {
    key <- tolower(trimws(w))
    this <- if (!is.null(.icap_aliases[[key]])) {
      grepl(.icap_aliases[[key]], trimws(available), ignore.case = TRUE)
    } else {
      clean == key | grepl(w, available, ignore.case = TRUE)
    }
    if (!any(this)) unmatched <- c(unmatched, w)
    hit <- hit | this
  }
  if (length(unmatched) > 0L) {
    cli_abort(c(
      "No ICAP jurisdiction matches {.val {unmatched}}.",
      "i" = "Available: {.val {sort(unique(trimws(available)))}}",
      "i" = "Matching accepts short names ({.val EU ETS}, {.val RGGI}), exact names, or substrings.",
      "i" = "See {.fn co2_icap_systems} for the full list."
    ))
  }
  hit
}

.wb_dashboard_page <- "https://carbonpricingdashboard.worldbank.org/about-us"

# Known-good direct file URL (verified 2026-08-02). Used when the
# landing page cannot be scraped, which is the normal case now that the
# host blocks non-browser clients.
.wb_known_file <- paste0(
  "https://carbonpricingdashboard.worldbank.org",
  "/sites/default/files/2026-04/data_08_2025.xlsx"
)

#' World Bank Carbon Pricing Dashboard
#'
#' Reads the World Bank Carbon Pricing Dashboard Excel file, which
#' covers 70+ carbon pricing initiatives worldwide (carbon taxes and
#' emissions trading systems) with price, coverage, and revenue data.
#'
#' **Manual download may be required.** Since 2026 the dashboard host
#' rejects non-browser HTTP clients (every request returns HTTP 403,
#' regardless of user agent), so this function often cannot fetch the
#' file for you. When the automatic download fails it reports the
#' direct file URL: download that in a browser and pass the local path
#' via `path`. The file is republished roughly twice a year, so a
#' manual copy stays current for months.
#'
#' @param path Optional path to a locally downloaded dashboard `.xlsx`
#'   file. When supplied, no network request is made.
#' @param sheet Sheet to read. Default `1`. The workbook carries
#'   several sheets; pass a name or number to read another.
#' @param refresh Re-download? Default `FALSE`.
#' @return A data frame.
#' @family aggregators
#' @export
#' @examples
#' \donttest{
#' op <- options(carbondata.cache_dir = tempdir())
#' wb <- try(co2_world_bank(), silent = TRUE)
#' options(op)
#' }
co2_world_bank <- function(path = NULL, sheet = 1L, refresh = FALSE) {
  if (!is.null(path)) {
    if (!file.exists(path)) {
      cli_abort("{.arg path} does not exist: {.file {path}}.")
    }
    df <- readxl::read_excel(path, sheet = sheet)
    return(as.data.frame(df, stringsAsFactors = FALSE))
  }

  cli_inform(c("i" = "Resolving latest World Bank Carbon Pricing file..."))
  hits <- tryCatch(
    co2_scrape_links(.wb_dashboard_page, "/sites/default/files/[^\"]+\\.xlsx$"),
    error = function(e) character(0L)
  )
  url <- if (length(hits) > 0L) co2_latest_release(hits) else .wb_known_file

  filename <- co2_safe_filename(basename(url))
  dest <- file.path(co2_cache_dir(), paste0("wb_", filename))
  if (file.exists(dest) && !refresh) {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  } else {
    cli_inform(c("i" = "Downloading {.file {filename}}..."))
    ok <- tryCatch({
      co2_download(url, dest, refresh = refresh)
      TRUE
    }, error = function(e) FALSE)
    if (!ok) {
      if (file.exists(dest)) unlink(dest)
      cli_abort(c(
        "The World Bank dashboard host refused the request (HTTP 403).",
        "i" = "It blocks non-browser clients, so {.pkg carbondata} cannot fetch this file for you.",
        "*" = "Download {.url {url}} in a browser, then pass the local path:",
        " " = "{.code co2_world_bank(path = \"~/Downloads/{filename}\")}"
      ))
    }
  }
  df <- readxl::read_excel(dest, sheet = sheet, guess_max = 1048576L)
  co2_clean_names(as.data.frame(df, stringsAsFactors = FALSE))
}

#' RFF World Carbon Pricing Database
#'
#' Fetches the Dolphin-Pollitt-Newbery World Carbon Pricing Database
#' for one country: national-level carbon pricing with CO2 tax and ETS
#' instruments harmonised by IPCC sector across 200+ jurisdictions.
#'
#' On 30 May 2026 the maintainer stopped distributing WCPD through
#' GitHub and stripped the data files from the default branch; new
#' releases moved to <https://worldcarbonpricing.org> behind an
#' emailed download token. This function therefore reads the last
#' openly published snapshot, the `v2025.0.0` tag, which remains
#' available and covers 1990 to 2023. For newer vintages, request
#' access on the WCPD site. For the companion emissions-weighted
#' carbon price, which is still served openly, see [co2_ecp_prices()].
#'
#' @param country Character. Country name using underscores
#'   (e.g. `"United_Kingdom"`, `"Germany"`, `"Antigua_and_Barbuda"`).
#' @param version Character. Git tag of the dataset release to read.
#'   Default `"v2025.0.0"`, the last openly published snapshot.
#' @param refresh Re-download? Default `FALSE`.
#'
#' @return A data frame of annual carbon prices by IPCC sector code.
#'
#' @references
#' Dolphin, G. G., Pollitt, M. G. and Newbery, D. M. (2020).
#' "The political economy of carbon pricing: a panel analysis."
#' \emph{Oxford Economic Papers}, 72(2), 472--500.
#' <doi:10.1093/oep/gpz042>
#'
#' @family aggregators
#' @export
#' @examples
#' \donttest{
#' op <- options(carbondata.cache_dir = tempdir())
#' uk <- co2_rff_pricing("United_Kingdom")
#' options(op)
#' }
co2_rff_pricing <- function(country, version = "v2025.0.0", refresh = FALSE) {
  if (missing(country) || !is.character(country) || length(country) != 1L) {
    cli_abort("{.arg country} must be a single country name with underscores.")
  }
  filename <- sprintf("wcpd_co2_%s.csv", country)
  url <- sprintf(
    "https://raw.githubusercontent.com/g-dolphin/WorldCarbonPricingDatabase/%s/_dataset/data/CO2/national/%s",
    version, filename
  )
  dest <- file.path(co2_cache_dir(), paste0("rff_", version, "_", filename))
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading RFF World Carbon Pricing Database for {country}..."))
    ok <- tryCatch({
      co2_download(url, dest, refresh = refresh)
      TRUE
    }, error = function(e) FALSE)
    if (!ok) {
      if (file.exists(dest)) unlink(dest)
      cli_abort(c(
        "No WCPD file for country {.val {country}} at release {.val {version}}.",
        "i" = "Country names use underscores, e.g. {.val United_Kingdom}.",
        "i" = "Note that WCPD stopped publishing to GitHub on 2026-05-30;",
        " " = "only tagged releases up to {.val v2025.0.0} remain openly available."
      ))
    }
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }
  utils::read.csv(dest, stringsAsFactors = FALSE, check.names = FALSE,
                  na.strings = c("", "NA"))
}

#' Emissions-weighted carbon prices (ECP)
#'
#' Fetches the emissions-weighted carbon price dataset published
#' alongside the World Carbon Pricing Database at
#' <https://worldcarbonpricing.org>. Unlike the raw WCPD files, these
#' endpoints remain open and are updated with each release, so this is
#' the current route to World Carbon Pricing Database derived data.
#'
#' `level = "jurisdiction"` returns average effective carbon prices by
#' jurisdiction and year and `"sector"` disaggregates by IPCC sector.
#' Coverage shares, the fraction of emissions subject to a price, come
#' from `"coverage"` (by jurisdiction) and `"coverage_sector"`.
#'
#' `"region"` is accepted because the publisher documents the endpoint,
#' but their server currently has no data file behind it for any gas;
#' the call errors with that explanation until they restore it.
#'
#' @param level Character. One of `"jurisdiction"` (default),
#'   `"sector"`, `"coverage"`, `"coverage_sector"`, or `"region"`.
#' @param gas Character. Greenhouse gas. Default `"CO2"`.
#' @param country Optional character vector of jurisdiction names to
#'   filter (matched case-insensitively, e.g. `"United Kingdom"`).
#' @param refresh Re-download? Default `FALSE`. Cached copies refresh
#'   automatically after 30 days.
#'
#' @return A data frame.
#'
#' @references
#' Dolphin, G., Xiahou, Q. (2022). "World carbon pricing database:
#' sources and methods." \emph{Scientific Data}, 9, 573.
#' <doi:10.1038/s41597-022-01659-x>
#'
#' @family aggregators
#' @export
#' @examples
#' \donttest{
#' op <- options(carbondata.cache_dir = tempdir())
#' ecp <- co2_ecp_prices(country = "United Kingdom")
#' options(op)
#' }
co2_ecp_prices <- function(level = c("jurisdiction", "sector", "coverage",
                                     "coverage_sector", "region"),
                           gas = "CO2", country = NULL, refresh = FALSE) {
  level <- match.arg(level)
  endpoint <- switch(level,
    jurisdiction    = "prices-jurisdiction",
    sector          = "prices-sector",
    region          = "prices-region",
    coverage        = "coverage-jurisdiction",
    coverage_sector = "coverage-sector"
  )
  url <- sprintf("%s/%s?gas=%s&format=csv", .ecp_api_base, endpoint,
                 utils::URLencode(gas, reserved = TRUE))
  dest <- file.path(co2_cache_dir(), sprintf("ecp_%s_%s.csv", endpoint, gas))
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading ECP {level} data..."))
  }
  ok <- tryCatch({
    co2_download(url, dest, refresh = refresh, max_age_days = 30)
    TRUE
  }, error = function(e) FALSE)
  if (!ok) {
    if (level == "region") {
      cli_abort(c(
        "The publisher has no regional data file behind this endpoint.",
        "i" = "{.url {.ecp_api_base}/prices-region} returns 404 for every gas.",
        "i" = "Use {.code level = \"jurisdiction\"} and aggregate, or retry later."
      ))
    }
    cli_abort(c(
      "Failed to fetch ECP {level} data for gas {.val {gas}}.",
      "i" = "Check the gas code, or the service may be unavailable.",
      "i" = "Endpoint: {.url {url}}"
    ))
  }

  df <- utils::read.csv(dest, stringsAsFactors = FALSE, check.names = FALSE,
                        na.strings = c("", "NA"))
  if (!is.null(country) && nrow(df) > 0L) {
    jur <- co2_pick(df, c("jurisdiction", "region", "country"), required = TRUE)
    df <- df[tolower(trimws(jur)) %in% tolower(trimws(country)), , drop = FALSE]
    if (nrow(df) == 0L) {
      cli_warn(c("!" = "No rows matched {.val {country}}."))
    }
    rownames(df) <- NULL
  }
  df
}
