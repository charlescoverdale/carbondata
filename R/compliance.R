# Compliance market data for UK ETS, RGGI, and California.
# Each source publishes data in different formats (Excel, CSV) via
# government websites. URLs are documented and maintained centrally
# in this file so format shifts can be patched here.

#' UK Emissions Trading Scheme data
#'
#' Fetches data from the UK ETS, which replaced the UK's participation
#' in the EU ETS from 1 January 2021. Coverage: power sector and
#' energy-intensive industry within the UK.
#'
#' @param type Character. `"price"` for UKA auction prices,
#'   `"emissions"` for verified emissions, `"allocations"` for free
#'   allocations.
#' @param from,to Optional. Date range for price data.
#' @param refresh Logical. Re-download? Default `FALSE`.
#'
#' @return A data frame. Columns depend on `type`.
#'
#' @family compliance markets
#' @export
#' @examples
#' \dontrun{
#' op <- options(carbondata.cache_dir = tempdir())
#' uka <- co2_ukets(type = "price", from = "2024-01-01")
#' options(op)
#' }
co2_ukets <- function(type = c("price", "emissions", "allocations"),
                      from = NULL, to = NULL, refresh = FALSE) {
  type <- match.arg(type)
  from <- co2_validate_date(from, "from")
  to   <- co2_validate_date(to, "to")

  url <- switch(type,
    price       = "https://www.eex.com/fileadmin/EEX/Downloads/Trading/Specifications/Emissions_Rights/EEX_UK_Allowance_Auctions_Results_History.csv",
    emissions   = "https://assets.publishing.service.gov.uk/media/uk-ets-verified-emissions.csv",
    allocations = "https://assets.publishing.service.gov.uk/media/uk-ets-allocations.csv"
  )

  filename <- paste0("ukets_", type, ".csv")
  dest <- file.path(co2_cache_dir(), filename)
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading UK ETS {type} data..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }

  df <- utils::read.csv(dest, stringsAsFactors = FALSE, check.names = FALSE)

  if (type == "price") {
    out <- .ukets_tidy_price(df)
    if (!is.null(from)) out <- out[out$date >= as.Date(from), , drop = FALSE]
    if (!is.null(to))   out <- out[out$date <= as.Date(to), , drop = FALSE]
    return(out)
  }
  df
}

#' Regional Greenhouse Gas Initiative (RGGI) data
#'
#' Fetches data from RGGI, the power-sector cap-and-trade program
#' covering eleven US Northeast and Mid-Atlantic states. Data comes
#' from the public COATS system.
#'
#' @param type Character. `"price"` for auction clearing prices,
#'   `"emissions"` for quarterly CO2 emissions, `"allowances"` for
#'   allowance distribution.
#' @param state Optional state abbreviation (e.g. `"NY"`, `"MA"`).
#' @param from,to Optional. Date range.
#' @param refresh Re-download? Default `FALSE`.
#'
#' @return A data frame. Columns depend on `type`.
#'
#' @family compliance markets
#' @export
#' @examples
#' \dontrun{
#' op <- options(carbondata.cache_dir = tempdir())
#' prices <- co2_rggi(type = "price")
#' options(op)
#' }
co2_rggi <- function(type = c("price", "emissions", "allowances"),
                     state = NULL, from = NULL, to = NULL,
                     refresh = FALSE) {
  type <- match.arg(type)
  from <- co2_validate_date(from, "from")
  to   <- co2_validate_date(to, "to")

  url <- switch(type,
    price       = "https://www.rggi.org/sites/default/files/Uploads/Auction-Materials/Auction_Prices_Volumes.csv",
    emissions   = "https://rggi-coats.org/eats/rggi/data/RGGI_Summary_Emissions.csv",
    allowances  = "https://www.rggi.org/sites/default/files/Uploads/Allowance-Distribution/Allowance_Distribution.csv"
  )

  filename <- paste0("rggi_", type, ".csv")
  dest <- file.path(co2_cache_dir(), filename)
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading RGGI {type} data..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }

  df <- utils::read.csv(dest, stringsAsFactors = FALSE, check.names = FALSE)

  if (type == "price") {
    out <- .rggi_tidy_price(df)
    if (!is.null(from)) out <- out[out$date >= as.Date(from), , drop = FALSE]
    if (!is.null(to))   out <- out[out$date <= as.Date(to), , drop = FALSE]
    return(out)
  }

  if (!is.null(state) && "state" %in% names(df)) {
    df <- df[toupper(df$state) == toupper(state), , drop = FALSE]
  }
  df
}

#' California Cap-and-Trade data
#'
#' Fetches data from the California Cap-and-Trade program operated
#' by the California Air Resources Board (CARB). The program covers
#' multi-sector emissions and holds quarterly joint auctions with
#' Quebec under the Western Climate Initiative.
#'
#' @param type Character. `"price"` for joint CA/QC auction settlement
#'   prices, `"emissions"` for covered-entity emissions,
#'   `"auction"` for auction volumes.
#' @param from,to Optional. Date range.
#' @param refresh Re-download? Default `FALSE`.
#'
#' @return A data frame.
#'
#' @family compliance markets
#' @export
#' @examples
#' \dontrun{
#' op <- options(carbondata.cache_dir = tempdir())
#' cca <- co2_california(type = "price")
#' options(op)
#' }
co2_california <- function(type = c("price", "emissions", "auction"),
                           from = NULL, to = NULL, refresh = FALSE) {
  type <- match.arg(type)
  from <- co2_validate_date(from, "from")
  to   <- co2_validate_date(to, "to")

  url <- switch(type,
    price     = "https://ww2.arb.ca.gov/sites/default/files/classic/cc/capandtrade/auction/auction-settlement-results.csv",
    emissions = "https://ww2.arb.ca.gov/sites/default/files/classic/cc/reporting/ghg-rep/ghg-reports/ghg-reports-emissions.csv",
    auction   = "https://ww2.arb.ca.gov/sites/default/files/classic/cc/capandtrade/auction/auction-summary.csv"
  )

  filename <- paste0("california_", type, ".csv")
  dest <- file.path(co2_cache_dir(), filename)
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading California Cap-and-Trade {type} data..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }

  df <- utils::read.csv(dest, stringsAsFactors = FALSE, check.names = FALSE)

  if (type == "price") {
    out <- .california_tidy_price(df)
    if (!is.null(from)) out <- out[out$date >= as.Date(from), , drop = FALSE]
    if (!is.null(to))   out <- out[out$date <= as.Date(to), , drop = FALSE]
    return(out)
  }
  df
}

#' @noRd
.ukets_tidy_price <- function(df) {
  date_raw <- .euets_pick(df, c("^date$", "auction_date"))
  data.frame(
    date = suppressWarnings(as.Date(date_raw)),
    price_gbp = suppressWarnings(as.numeric(.euets_pick(df, c("price", "settlement_price", "clearing_price")))),
    volume_t = suppressWarnings(as.numeric(.euets_pick(df, c("volume", "allocated_volume")))),
    stringsAsFactors = FALSE
  )
}

#' @noRd
.rggi_tidy_price <- function(df) {
  date_raw <- .euets_pick(df, c("^date$", "auction_date"))
  data.frame(
    date = suppressWarnings(as.Date(date_raw)),
    auction_number = as.character(.euets_pick(df, c("auction", "auction_number", "^number$"))),
    price_usd = suppressWarnings(as.numeric(.euets_pick(df, c("clearing_price", "price", "settlement_price")))),
    volume_t = suppressWarnings(as.numeric(.euets_pick(df, c("volume", "allowances_sold", "sold")))),
    stringsAsFactors = FALSE
  )
}

#' @noRd
.california_tidy_price <- function(df) {
  date_raw <- .euets_pick(df, c("^date$", "auction_date"))
  data.frame(
    date = suppressWarnings(as.Date(date_raw)),
    auction_number = as.character(.euets_pick(df, c("auction", "auction_number"))),
    price_usd = suppressWarnings(as.numeric(.euets_pick(df, c("settlement_price", "price", "clearing_price")))),
    volume_t = suppressWarnings(as.numeric(.euets_pick(df, c("volume", "allowances_sold", "sold")))),
    stringsAsFactors = FALSE
  )
}
