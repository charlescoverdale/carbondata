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
#' \donttest{
#' op <- options(carbondata.cache_dir = tempdir())
#' try({
#'   uk <- co2_ukets()
#' })
#' options(op)
#' }
co2_ukets <- function(refresh = FALSE) {
  # The registry moved this report from section 4 to section 5 during
  # 2026 and renamed it (" and " became " & ", scheme year appended),
  # so try both sections and match the filename loosely.
  index_urls <- c(
    "https://reports.view-emissions-trading-registry.service.gov.uk/ets-reports/section5/section5.html",
    "https://reports.view-emissions-trading-registry.service.gov.uk/ets-reports/section4/section4.html"
  )
  cli_inform(c("i" = "Resolving UK ETS compliance report URL..."))
  pattern <- "Compliance_Report_Emissions_(and|&|%26)_Surrenders[^/]*\\.xlsx$"
  hits <- character(0L)
  for (index_url in index_urls) {
    hits <- tryCatch(co2_scrape_links(index_url, pattern),
                     error = function(e) character(0L))
    if (length(hits) > 0L) break
  }
  if (length(hits) == 0L) {
    cli_abort(c(
      "No UK ETS compliance report found on {.url {index_urls}}.",
      "i" = "The UK Emissions Trading Registry may have restructured its reports page.",
      "i" = "Please report at https://github.com/charlescoverdale/carbondata/issues."
    ))
  }
  # Prefer the most recent scheme year when several are listed.
  url <- co2_latest_release(hits)
  filename <- co2_safe_filename(basename(url))
  dest <- file.path(co2_cache_dir(), filename)
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading {.file {filename}}..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }
  # Sheet 1 is an empty "Information" cover sheet; the table lives in
  # the "Data" sheet.
  sheets <- readxl::excel_sheets(dest)
  sheet <- if ("Data" %in% sheets) "Data" else sheets[length(sheets)]
  df <- readxl::read_excel(dest, sheet = sheet, guess_max = 1048576L)
  co2_clean_names(as.data.frame(df, stringsAsFactors = FALSE))
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
#' \donttest{
#' op <- options(carbondata.cache_dir = tempdir())
#' try({
#'   alloc <- co2_ukets_allocations()
#' })
#' options(op)
#' }
co2_ukets_allocations <- function(sector = c("installations", "aviation"),
                                  refresh = FALSE) {
  sector <- match.arg(sector)
  page <- switch(sector,
    installations = "https://www.gov.uk/government/publications/uk-ets-allocation-table-for-operators-of-installations",
    aviation      = "https://www.gov.uk/government/publications/uk-ets-aviation-allocation-table"
  )
  cli_inform(c("i" = "Resolving UK ETS {sector} allocation URL..."))
  # DESNZ dropped the month word from the filename in 2026
  # ("...-table-march-2025.xlsx" became "...-table-2026.xlsx"), so the
  # month segment is optional.
  pattern <- if (sector == "installations") {
    "uk-ets-allocation-table-([a-z]+-)?\\d{4}[a-z0-9-]*\\.(xlsx|csv|ods)$"
  } else {
    "uk-ets-aviation-allocation-table-([a-z]+-)?\\d{4}[a-z0-9-]*\\.(xlsx|csv|ods)$"
  }
  hits <- co2_scrape_links(page, pattern)
  if (length(hits) == 0L) {
    cli_abort(c(
      "No UK ETS {sector} allocation file found on {.url {page}}.",
      "i" = "DESNZ may have renamed the published file.",
      "i" = "Please report at https://github.com/charlescoverdale/carbondata/issues."
    ))
  }
  url <- co2_latest_release(hits)
  filename <- co2_safe_filename(basename(url))
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
    as.data.frame(readxl::read_excel(dest, guess_max = 1048576L),
                  stringsAsFactors = FALSE)
  }
  co2_clean_names(df)
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
#' @return A data frame with one row per participating state plus a
#'   `"Total"` row: `state` and one numeric column per measure in RGGI's
#'   table (allowance budget, sold at auction, cost containment reserve,
#'   and so on; the set varies a little by year). Cells RGGI marks `N/A`
#'   are `NA`.
#' @family compliance markets
#' @export
#' @examples
#' \donttest{
#' op <- options(carbondata.cache_dir = tempdir())
#' try({
#'   a <- co2_rggi_allowances(year = 2026)
#' })
#' options(op)
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
  co2_parse_rggi_allowances(dest, year)
}

# The RGGI workbook opens with a title block (title, date, a note and a
# sub-title), so the header is the row whose first cell is "State", not
# row 1. States follow, then a "Total" row (with a footnote digit in older
# years, e.g. "Total3"), then notes and a legend.
co2_parse_rggi_allowances <- function(path, year) {
  raw <- readxl::read_excel(path, col_names = FALSE, col_types = "text",
                            .name_repair = "minimal")
  first <- trimws(as.character(raw[[1]]))
  hdr <- which(first == "State")[1]
  if (is.na(hdr)) {
    cli_abort(c(
      "Could not find the header row of the RGGI allowance table for {year}.",
      "i" = "RGGI may have changed the workbook layout."
    ))
  }
  header <- as.character(unlist(raw[hdr, ], use.names = FALSE))
  rows <- seq.int(hdr + 1L, nrow(raw))
  label <- first[rows]
  total <- grep("^Total[0-9]*$", label)[1]
  if (!is.na(total)) {
    rows <- rows[seq_len(total)]
    label <- label[seq_len(total)]
  }
  keep <- !is.na(label) & nzchar(label)
  rows <- rows[keep]
  # Footnote markers are a digit glued to the last word ("Delaware1",
  # "Sold at Auction5"); a digit after a lowercase letter is never part of
  # a name here, while "CO2" (after a capital) is left alone.
  strip_note <- function(x) sub("(?<=[a-z])[0-9]$", "", x, perl = TRUE)
  label <- strip_note(sub("^Total[0-9]*$", "Total", label[keep]))

  cols <- which(!is.na(header) & nzchar(header))
  cols <- cols[cols > 1L]
  values <- lapply(cols, function(j) {
    v <- trimws(as.character(raw[[j]][rows]))
    v[toupper(v) %in% c("N/A", "NA", "")] <- NA
    suppressWarnings(as.numeric(gsub(",", "", v, fixed = TRUE)))
  })
  names(values) <- strip_note(trimws(header[cols]))
  df <- data.frame(state = label, values, check.names = FALSE,
                   stringsAsFactors = FALSE)
  co2_clean_names(df)
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
#' \donttest{
#' op <- options(carbondata.cache_dir = tempdir())
#' try({
#'   ny <- co2_rggi_state_proceeds("NY")
#' })
#' options(op)
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
  out <- co2_clean_names(as.data.frame(df, stringsAsFactors = FALSE))
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
#' \donttest{
#' op <- options(carbondata.cache_dir = tempdir())
#' try({
#'   prices <- co2_california_prices()
#' })
#' options(op)
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
#' \donttest{
#' op <- options(carbondata.cache_dir = tempdir())
#' try({
#'   caps <- co2_california_caps()
#' })
#' options(op)
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
