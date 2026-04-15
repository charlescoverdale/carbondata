# Compliance carbon markets: UK ETS, RGGI, California.

#' UK ETS verified emissions and surrenders
#'
#' Fetches the UK Emissions Trading Scheme Section 4 compliance
#' report (verified emissions and allowance surrenders per account
#' per scheme year), published annually by the UK Emissions Trading
#' Registry after the 30 April reconciliation deadline.
#'
#' @param refresh Re-download? Default `FALSE`.
#' @return A data frame with one row per account-year.
#' @family compliance markets
#' @export
#' @examples
#' \dontrun{
#' uk <- co2_ukets()
#' }
co2_ukets <- function(refresh = FALSE) {
  index_url <- "https://reports.view-emissions-trading-registry.service.gov.uk/ets-reports/section4/section4.html"
  cli_inform(c("i" = "Resolving UK ETS Section 4 compliance report URL..."))
  hits <- co2_scrape_links(index_url,
                           "Compliance_Report_Emissions_and_Surrenders\\.xlsx$")
  if (length(hits) == 0L) {
    cli_abort(c(
      "No UK ETS compliance report found on {.url {index_url}}.",
      "i" = "The UK Emissions Trading Registry may have restructured its reports page."
    ))
  }
  url <- hits[1L]
  filename <- basename(url)
  dest <- file.path(co2_cache_dir(), filename)
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading {.file {filename}}..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }
  df <- readxl::read_excel(dest)
  as.data.frame(df, stringsAsFactors = FALSE)
}

#' UK ETS free allocations
#'
#' Fetches the UK ETS free-allocation table for stationary
#' installations (OHA) published by DESNZ on GOV.UK. Filename
#' includes a media GUID that changes when DESNZ republishes, so the
#' package scrapes the stable publications landing page.
#'
#' @param sector Character. `"installations"` (default) for stationary
#'   installations, `"aviation"` for aviation allocations.
#' @param refresh Re-download? Default `FALSE`.
#' @return A data frame.
#' @family compliance markets
#' @export
#' @examples
#' \dontrun{
#' alloc <- co2_ukets_allocations()
#' }
co2_ukets_allocations <- function(sector = c("installations", "aviation"),
                                  refresh = FALSE) {
  sector <- match.arg(sector)
  page <- switch(sector,
    installations = "https://www.gov.uk/government/publications/uk-ets-allocation-table-for-operators-of-installations",
    aviation      = "https://www.gov.uk/government/publications/uk-ets-aviation-allocation-table"
  )
  cli_inform(c("i" = "Resolving UK ETS {sector} allocation URL..."))
  pattern <- if (sector == "installations") {
    "uk-ets-allocation-table-[a-z]+-\\d{4}\\.(xlsx|csv)$"
  } else {
    "uk-ets-aviation-allocation-table-[a-z]+-\\d{4}\\.(xlsx|csv)$"
  }
  hits <- co2_scrape_links(page, pattern)
  if (length(hits) == 0L) {
    cli_abort("No UK ETS {sector} allocation file found on {.url {page}}.")
  }
  url <- hits[1L]
  filename <- basename(url)
  dest <- file.path(co2_cache_dir(), filename)
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading {.file {filename}}..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }
  ext <- tolower(tools::file_ext(filename))
  df <- if (ext == "csv") {
    utils::read.csv(dest, stringsAsFactors = FALSE, check.names = FALSE)
  } else {
    as.data.frame(readxl::read_excel(dest), stringsAsFactors = FALSE)
  }
  df
}

#' RGGI allowance distribution by state and year
#'
#' Fetches the Regional Greenhouse Gas Initiative (RGGI) annual CO2
#' allowance distribution table from the public RGGI website. Covers
#' 11 participating US states from 2009 onwards.
#'
#' Auction clearing prices are NOT returned here because RGGI
#' publishes them only as per-auction PDFs (no CSV aggregation
#' exists). For RGGI prices, use [co2_icap_prices()] with
#' `jurisdiction = "Regional Greenhouse Gas Initiative"`.
#'
#' @param year Integer year (2009-present). Default is the current
#'   year.
#' @param refresh Re-download? Default `FALSE`.
#' @return A data frame of allowance distribution by state.
#' @family compliance markets
#' @export
#' @examples
#' \dontrun{
#' a <- co2_rggi_allowances(year = 2026)
#' }
co2_rggi_allowances <- function(year = NULL, refresh = FALSE) {
  year <- year %||% as.integer(format(Sys.Date(), "%Y"))
  year <- co2_validate_year(year, min_year = 2009L)
  if (length(year) != 1L) {
    cli_abort("{.arg year} must be a single integer for RGGI allowances.")
  }

  filename <- sprintf("%d_Allowance-Distribution.xlsx", year)
  url <- sprintf("https://www.rggi.org/sites/default/files/Uploads/Allowance-Tracking/%s",
                 filename)
  dest <- file.path(co2_cache_dir(), paste0("rggi_", filename))
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading RGGI allowance distribution for {year}..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }
  df <- readxl::read_excel(dest)
  as.data.frame(df, stringsAsFactors = FALSE)
}

#' RGGI cumulative state proceeds by auction
#'
#' Fetches cumulative auction proceeds time series for one RGGI state,
#' indexed by auction number. Derived from the per-state XLSX files on
#' rggi.org. Combining all states gives the full RGGI auction time
#' series.
#'
#' @param state Two-letter state code (one of: CT, DE, MA, MD, ME, NH,
#'   NJ, NY, RI, VA, VT).
#' @param refresh Re-download? Default `FALSE`.
#' @return A data frame.
#' @family compliance markets
#' @export
#' @examples
#' \dontrun{
#' ny <- co2_rggi_state_proceeds("NY")
#' }
co2_rggi_state_proceeds <- function(state, refresh = FALSE) {
  valid_states <- c("CT", "DE", "MA", "MD", "ME", "NH",
                    "NJ", "NY", "RI", "VA", "VT")
  state <- toupper(state)
  if (!state %in% valid_states) {
    cli_abort(c(
      "{.arg state} must be one of {.val {valid_states}}.",
      "x" = "Got {.val {state}}."
    ))
  }
  filename <- sprintf("%s_Proceeds_by_Auction.xlsx", state)
  url <- sprintf("https://www.rggi.org/sites/default/files/Uploads/Auction-Materials/Cumulative-State-Charts/%s",
                 filename)
  dest <- file.path(co2_cache_dir(), paste0("rggi_", filename))
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading RGGI {state} cumulative proceeds..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }
  df <- readxl::read_excel(dest)
  out <- as.data.frame(df, stringsAsFactors = FALSE)
  out$state <- state
  out
}

#' California Cap-and-Trade auction settlement prices
#'
#' Fetches the California Air Resources Board auction settlement
#' price time series, updated quarterly after each joint California-
#' Quebec auction.
#'
#' @param refresh Re-download? Default `FALSE`.
#' @return A data frame with `joint_auction`, `quarter`,
#'   `settlement_price_usd`, `reserve_price_usd`.
#' @family compliance markets
#' @export
#' @examples
#' \dontrun{
#' prices <- co2_california_prices()
#' }
co2_california_prices <- function(refresh = FALSE) {
  url <- "https://ww2.arb.ca.gov/sites/default/files/2022-12/nc-allowance_prices.csv"
  dest <- file.path(co2_cache_dir(), "california_allowance_prices.csv")
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading California Cap-and-Trade auction prices..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading California prices from cache."))
  }
  df <- utils::read.csv(dest, stringsAsFactors = FALSE, check.names = FALSE)
  data.frame(
    joint_auction = as.character(co2_pick(df, c("Joint Auction", "auction"))),
    quarter_year = as.character(co2_pick(df, c("Quarter Year", "quarter"))),
    settlement_price_usd = suppressWarnings(as.numeric(gsub("[$,]", "",
      co2_pick(df, c("Current Auction Settlement Price", "settlement_price"))
    ))),
    reserve_price_usd = suppressWarnings(as.numeric(gsub("[$,]", "",
      co2_pick(df, c("Auction Reserve Price", "reserve_price"))
    ))),
    stringsAsFactors = FALSE
  )
}

#' California overall emissions caps
#'
#' Fetches the California Cap-and-Trade program overall cap and
#' allocation channels, by vintage year.
#'
#' @param refresh Re-download? Default `FALSE`.
#' @return A data frame.
#' @family compliance markets
#' @export
#' @examples
#' \dontrun{
#' caps <- co2_california_caps()
#' }
co2_california_caps <- function(refresh = FALSE) {
  url <- "https://ww2.arb.ca.gov/sites/default/files/2025-06/nc-OverallCaps.csv"
  dest <- file.path(co2_cache_dir(), "california_overall_caps.csv")
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading California overall caps..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading California caps from cache."))
  }
  df <- utils::read.csv(dest, stringsAsFactors = FALSE, check.names = FALSE)
  df
}
