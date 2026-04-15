# Cross-market aggregators: ICAP, World Bank, RFF.

#' ICAP Allowance Price Explorer
#'
#' Fetches allowance prices across the world's Emissions Trading
#' Systems from the International Carbon Action Partnership (ICAP)
#' Allowance Price Explorer. Covers 20+ jurisdictions including the
#' EU, UK, California, RGGI, New Zealand, Korea, China, and others.
#' Data is curated quarterly by ICAP.
#'
#' @param jurisdiction Optional character vector of jurisdictions
#'   (e.g. `c("EU ETS", "UK ETS", "RGGI")`). See
#'   <https://icapcarbonaction.com/en/ets-prices> for the full list.
#' @param from,to Optional. Date range (YYYY-MM-DD).
#' @param refresh Re-download? Default `FALSE`.
#'
#' @return A data frame with `date`, `jurisdiction`, `price_usd`,
#'   `currency_native`, `price_native`.
#'
#' @family aggregators
#' @export
#' @examples
#' \dontrun{
#' op <- options(carbondata.cache_dir = tempdir())
#' prices <- co2_icap_prices(jurisdiction = c("EU ETS", "UK ETS"))
#' options(op)
#' }
co2_icap_prices <- function(jurisdiction = NULL, from = NULL, to = NULL,
                            refresh = FALSE) {
  from <- co2_validate_date(from, "from")
  to   <- co2_validate_date(to, "to")

  url <- "https://icapcarbonaction.com/system/files/ape_download/ape_prices.csv"
  dest <- file.path(co2_cache_dir(), "icap_prices.csv")
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading ICAP Allowance Price Explorer data..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading ICAP data from cache."))
  }

  df <- utils::read.csv(dest, stringsAsFactors = FALSE, check.names = FALSE)
  out <- .icap_tidy(df)
  if (!is.null(jurisdiction)) {
    out <- out[out$jurisdiction %in% jurisdiction, , drop = FALSE]
  }
  if (!is.null(from)) out <- out[out$date >= as.Date(from), , drop = FALSE]
  if (!is.null(to))   out <- out[out$date <= as.Date(to), , drop = FALSE]
  rownames(out) <- NULL
  out
}

#' World Bank Carbon Pricing Dashboard
#'
#' Fetches global carbon pricing data (carbon taxes and ETS) from the
#' World Bank Carbon Pricing Dashboard. Covers instruments, prices,
#' emissions coverage, and revenue for over 70 carbon pricing
#' initiatives worldwide.
#'
#' @param year Optional integer year to filter by.
#' @param instrument Optional character: `"ets"`, `"tax"`, or NULL
#'   for both.
#' @param refresh Re-download? Default `FALSE`.
#'
#' @return A data frame with columns `year`, `jurisdiction`,
#'   `instrument_type`, `name`, `price_usd_per_tco2e`,
#'   `emissions_covered_pct`, `revenue_usd_millions`.
#'
#' @family aggregators
#' @export
#' @examples
#' \dontrun{
#' op <- options(carbondata.cache_dir = tempdir())
#' wb <- co2_world_bank(year = 2024)
#' options(op)
#' }
co2_world_bank <- function(year = NULL, instrument = NULL,
                           refresh = FALSE) {
  year <- co2_validate_year(year, min_year = 1990L)
  if (!is.null(instrument)) {
    instrument <- match.arg(instrument, c("ets", "tax"))
  }

  url <- "https://carbonpricingdashboard.worldbank.org/api/carbon_pricing_dashboard.csv"
  dest <- file.path(co2_cache_dir(), "world_bank_carbon_pricing.csv")
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading World Bank Carbon Pricing Dashboard..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading World Bank data from cache."))
  }

  df <- utils::read.csv(dest, stringsAsFactors = FALSE, check.names = FALSE)
  out <- .world_bank_tidy(df)
  if (!is.null(year)) out <- out[out$year %in% year, , drop = FALSE]
  if (!is.null(instrument)) {
    out <- out[tolower(out$instrument_type) == instrument, , drop = FALSE]
  }
  rownames(out) <- NULL
  out
}

#' RFF World Carbon Pricing Database
#'
#' Fetches the Resources for the Future (RFF) World Carbon Pricing
#' Database compiled by Dolphin, Pollitt and Newbery (2020). Provides
#' harmonised subnational and national carbon pricing from 1990 to
#' 2020 across 200+ jurisdictions. Published in Nature Scientific
#' Data.
#'
#' @param country Optional ISO 3-letter country codes.
#' @param year Optional integer years.
#' @param refresh Re-download? Default `FALSE`.
#'
#' @return A data frame.
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
#' \dontrun{
#' op <- options(carbondata.cache_dir = tempdir())
#' rff <- co2_rff_pricing(country = "GBR")
#' options(op)
#' }
co2_rff_pricing <- function(country = NULL, year = NULL,
                            refresh = FALSE) {
  year <- co2_validate_year(year, min_year = 1990L)

  url <- "https://github.com/g-dolphin/WorldCarbonPricingDatabase/raw/master/_dataset/data/CO2/national/CO2_national_emissions.csv"
  dest <- file.path(co2_cache_dir(), "rff_carbon_pricing.csv")
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading RFF World Carbon Pricing Database..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading RFF data from cache."))
  }

  df <- utils::read.csv(dest, stringsAsFactors = FALSE, check.names = FALSE)
  out <- .rff_tidy(df)
  if (!is.null(country)) {
    out <- out[toupper(out$country) %in% toupper(country), , drop = FALSE]
  }
  if (!is.null(year)) out <- out[out$year %in% year, , drop = FALSE]
  rownames(out) <- NULL
  out
}

#' @noRd
.icap_tidy <- function(df) {
  date_raw <- .euets_pick(df, c("^date$", "period"))
  data.frame(
    date = suppressWarnings(as.Date(date_raw)),
    jurisdiction = as.character(.euets_pick(df, c("jurisdiction", "^ets$", "scheme"))),
    price_usd = suppressWarnings(as.numeric(.euets_pick(df, c("price_usd", "usd")))),
    currency_native = as.character(.euets_pick(df, c("currency", "native_currency"), default = "USD")),
    price_native = suppressWarnings(as.numeric(.euets_pick(df, c("price_native", "^price$")))),
    stringsAsFactors = FALSE
  )
}

#' @noRd
.world_bank_tidy <- function(df) {
  data.frame(
    year = suppressWarnings(as.integer(.euets_pick(df, c("^year$")))),
    jurisdiction = as.character(.euets_pick(df, c("jurisdiction", "country", "region"))),
    instrument_type = as.character(.euets_pick(df, c("instrument", "^type$"))),
    name = as.character(.euets_pick(df, c("instrument_name", "^name$"))),
    price_usd_per_tco2e = suppressWarnings(as.numeric(.euets_pick(df, c("price_usd", "price")))),
    emissions_covered_pct = suppressWarnings(as.numeric(.euets_pick(df, c("coverage", "emissions_covered")))),
    revenue_usd_millions = suppressWarnings(as.numeric(.euets_pick(df, c("revenue", "revenue_usd")))),
    stringsAsFactors = FALSE
  )
}

#' @noRd
.rff_tidy <- function(df) {
  data.frame(
    country = as.character(.euets_pick(df, c("jurisdiction", "country", "iso", "^code$"))),
    year = suppressWarnings(as.integer(.euets_pick(df, c("^year$")))),
    sector = as.character(.euets_pick(df, c("sector", "industry"))),
    instrument_type = as.character(.euets_pick(df, c("instrument", "^type$"))),
    price_usd_per_tco2e = suppressWarnings(as.numeric(.euets_pick(df, c("price", "price_usd")))),
    stringsAsFactors = FALSE
  )
}
