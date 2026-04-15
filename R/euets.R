# EU ETS data access via the European Environment Agency (EEA) Datahub
# and the EU Transaction Log (EUTL).
#
# EEA publishes verified emissions, allocations, and installation
# registry data as downloadable CSV/ZIP files. See
# https://www.eea.europa.eu/en/datahub for the underlying dataset
# landing pages.

.euets_base <- "https://www.eea.europa.eu"

#' EU ETS verified emissions
#'
#' Fetches verified greenhouse-gas emissions from installations
#' covered by the EU Emissions Trading System, as compiled by the
#' European Environment Agency from the EU Transaction Log (EUTL).
#'
#' Coverage: ~10,000 stationary installations plus ~1,500 aircraft
#' operators across the EU, EEA (Norway, Iceland, Liechtenstein), and
#' until 2020 the UK. Annual data from 2005. Emissions are verified
#' against annual compliance cycles and published each spring for
#' the prior year.
#'
#' @param country Optional character vector of two-letter country
#'   codes to filter by (e.g. `c("DE", "FR", "PL")`).
#' @param year Optional integer vector of years to filter by.
#' @param refresh Logical. Re-download the underlying bulk file even
#'   if cached? Default `FALSE`.
#'
#' @return A data frame with columns `country`, `year`, `installation_id`,
#'   `installation_name`, `activity`, `verified_emissions_tco2e`,
#'   plus metadata fields.
#'
#' @family EU ETS
#' @export
#' @examples
#' \dontrun{
#' op <- options(carbondata.cache_dir = tempdir())
#' de <- co2_euets_emissions(country = "DE", year = 2022)
#' head(de)
#' options(op)
#' }
co2_euets_emissions <- function(country = NULL, year = NULL,
                                refresh = FALSE) {
  year <- co2_validate_year(year, min_year = 2005L)
  path <- .euets_download("verified_emissions", refresh = refresh)
  df <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  df <- .euets_tidy_emissions(df)
  if (!is.null(country)) df <- df[df$country %in% toupper(country), , drop = FALSE]
  if (!is.null(year))    df <- df[df$year %in% year, , drop = FALSE]
  rownames(df) <- NULL
  df
}

#' EU ETS free allowance allocations
#'
#' Fetches the free allocation of EU Allowances (EUAs) to installations
#' under the EU Emissions Trading System. Free allocation has declined
#' over successive phases and is scheduled for further phase-out under
#' the Carbon Border Adjustment Mechanism (CBAM).
#'
#' @param country Optional two-letter country codes.
#' @param year Optional integer years.
#' @param refresh Re-download? Default `FALSE`.
#'
#' @return A data frame with `country`, `year`, `installation_id`,
#'   `allocated_eua`, plus metadata.
#'
#' @family EU ETS
#' @export
#' @examples
#' \dontrun{
#' op <- options(carbondata.cache_dir = tempdir())
#' alloc <- co2_euets_allocations(country = "DE", year = 2022)
#' options(op)
#' }
co2_euets_allocations <- function(country = NULL, year = NULL,
                                  refresh = FALSE) {
  year <- co2_validate_year(year, min_year = 2005L)
  path <- .euets_download("allocations", refresh = refresh)
  df <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  df <- .euets_tidy_allocations(df)
  if (!is.null(country)) df <- df[df$country %in% toupper(country), , drop = FALSE]
  if (!is.null(year))    df <- df[df$year %in% year, , drop = FALSE]
  rownames(df) <- NULL
  df
}

#' EU ETS surrendered units
#'
#' Fetches the allowances surrendered by installations to cover their
#' verified emissions. Compliance requires surrendering allowances
#' equal to verified emissions by 30 April each year.
#'
#' @param country Optional two-letter country codes.
#' @param year Optional integer years.
#' @param refresh Re-download? Default `FALSE`.
#'
#' @return A data frame with `country`, `year`, `installation_id`,
#'   `surrendered_units`, `unit_type`.
#'
#' @family EU ETS
#' @export
#' @examples
#' \dontrun{
#' op <- options(carbondata.cache_dir = tempdir())
#' s <- co2_euets_surrendered(country = "FR", year = 2022)
#' options(op)
#' }
co2_euets_surrendered <- function(country = NULL, year = NULL,
                                  refresh = FALSE) {
  year <- co2_validate_year(year, min_year = 2005L)
  path <- .euets_download("surrendered", refresh = refresh)
  df <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  df <- .euets_tidy_surrendered(df)
  if (!is.null(country)) df <- df[df$country %in% toupper(country), , drop = FALSE]
  if (!is.null(year))    df <- df[df$year %in% year, , drop = FALSE]
  rownames(df) <- NULL
  df
}

#' EU ETS installation registry
#'
#' Returns the registry of EU ETS installations with metadata:
#' operator name, activity type, country, permitted since, etc.
#'
#' @param country Optional two-letter country codes.
#' @param refresh Re-download? Default `FALSE`.
#'
#' @return A data frame of installations.
#'
#' @family EU ETS
#' @export
#' @examples
#' \dontrun{
#' op <- options(carbondata.cache_dir = tempdir())
#' inst <- co2_euets_installations(country = "PL")
#' options(op)
#' }
co2_euets_installations <- function(country = NULL, refresh = FALSE) {
  path <- .euets_download("installations", refresh = refresh)
  df <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  df <- .euets_tidy_installations(df)
  if (!is.null(country)) df <- df[df$country %in% toupper(country), , drop = FALSE]
  rownames(df) <- NULL
  df
}

#' EU ETS allowance (EUA) price
#'
#' Fetches EU Allowance (EUA) auction settlement prices from the
#' European Energy Exchange (EEX). Primary market auctions are held
#' several times per week; spot and futures prices trade continuously
#' on ICE ECX and EEX.
#'
#' Only settlement prices from the free auction reports are returned
#' here; intraday and futures curves require paid data feeds.
#'
#' @param from,to Optional character or Date. Date range
#'   (YYYY-MM-DD).
#' @param type Character. `"auction"` (default) returns primary market
#'   auction settlement prices. Future versions may support additional
#'   types.
#' @param refresh Re-download? Default `FALSE`.
#'
#' @return A data frame with columns `date`, `price_eur`, `venue`,
#'   `volume_t`.
#'
#' @family EU ETS
#' @export
#' @examples
#' \dontrun{
#' op <- options(carbondata.cache_dir = tempdir())
#' prices <- co2_euets_price(from = "2024-01-01")
#' options(op)
#' }
co2_euets_price <- function(from = NULL, to = NULL,
                            type = c("auction"), refresh = FALSE) {
  type <- match.arg(type)
  from <- co2_validate_date(from, "from")
  to   <- co2_validate_date(to, "to")

  path <- .euets_download("prices", refresh = refresh)
  df <- utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
  df <- .euets_tidy_prices(df)
  if (!is.null(from)) df <- df[df$date >= as.Date(from), , drop = FALSE]
  if (!is.null(to))   df <- df[df$date <= as.Date(to), , drop = FALSE]
  rownames(df) <- NULL
  df
}

#' @noRd
.euets_urls <- list(
  verified_emissions = "https://www.euets.info/download/installations_emissions.csv",
  allocations        = "https://www.euets.info/download/installations_allocations.csv",
  surrendered        = "https://www.euets.info/download/installations_surrendered.csv",
  installations      = "https://www.euets.info/download/installations.csv",
  prices             = "https://www.euets.info/download/auction_prices.csv"
)

#' @noRd
.euets_download <- function(dataset, refresh = FALSE) {
  url <- .euets_urls[[dataset]]
  if (is.null(url)) cli_abort("Unknown EU ETS dataset: {.val {dataset}}.")
  filename <- paste0("euets_", dataset, ".csv")
  dest <- file.path(co2_cache_dir(), filename)
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading EU ETS {dataset} data..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }
  dest
}

#' @noRd
.euets_pick <- function(df, patterns, default = NA_character_) {
  n <- names(df)
  for (p in patterns) {
    hit <- n[tolower(n) == tolower(p)]
    if (length(hit) > 0L) return(df[[hit[1L]]])
    hit <- n[grepl(p, n, ignore.case = TRUE)]
    if (length(hit) > 0L) return(df[[hit[1L]]])
  }
  rep(default, nrow(df))
}

#' @noRd
.euets_tidy_emissions <- function(df) {
  data.frame(
    country = toupper(as.character(.euets_pick(df, c("country", "registry", "^mscode$")))),
    year = suppressWarnings(as.integer(.euets_pick(df, c("year", "reporting_year")))),
    installation_id = as.character(.euets_pick(df, c("installation_id", "^id$", "eutl_id"))),
    installation_name = as.character(.euets_pick(df, c("installation_name", "^name$", "installation$"))),
    activity = as.character(.euets_pick(df, c("activity", "main_activity"))),
    verified_emissions_tco2e = suppressWarnings(as.numeric(
      .euets_pick(df, c("verified_emissions", "emissions", "verified"))
    )),
    stringsAsFactors = FALSE
  )
}

#' @noRd
.euets_tidy_allocations <- function(df) {
  data.frame(
    country = toupper(as.character(.euets_pick(df, c("country", "registry")))),
    year = suppressWarnings(as.integer(.euets_pick(df, c("year")))),
    installation_id = as.character(.euets_pick(df, c("installation_id", "^id$"))),
    installation_name = as.character(.euets_pick(df, c("installation_name", "^name$"))),
    allocated_eua = suppressWarnings(as.numeric(
      .euets_pick(df, c("allocated", "allocation", "freely_allocated"))
    )),
    stringsAsFactors = FALSE
  )
}

#' @noRd
.euets_tidy_surrendered <- function(df) {
  data.frame(
    country = toupper(as.character(.euets_pick(df, c("country", "registry")))),
    year = suppressWarnings(as.integer(.euets_pick(df, c("year")))),
    installation_id = as.character(.euets_pick(df, c("installation_id", "^id$"))),
    surrendered_units = suppressWarnings(as.numeric(
      .euets_pick(df, c("surrendered", "units_surrendered"))
    )),
    unit_type = as.character(.euets_pick(df, c("unit_type", "^type$"))),
    stringsAsFactors = FALSE
  )
}

#' @noRd
.euets_tidy_installations <- function(df) {
  data.frame(
    country = toupper(as.character(.euets_pick(df, c("country", "registry")))),
    installation_id = as.character(.euets_pick(df, c("installation_id", "^id$"))),
    installation_name = as.character(.euets_pick(df, c("installation_name", "^name$"))),
    activity = as.character(.euets_pick(df, c("activity", "main_activity"))),
    permit_id = as.character(.euets_pick(df, c("permit_id", "^permit$"))),
    city = as.character(.euets_pick(df, c("city", "address_city"))),
    postcode = as.character(.euets_pick(df, c("postcode", "postal_code"))),
    stringsAsFactors = FALSE
  )
}

#' @noRd
.euets_tidy_prices <- function(df) {
  date_raw <- .euets_pick(df, c("^date$", "auction_date", "trading_date"))
  date <- suppressWarnings(as.Date(date_raw))
  data.frame(
    date = date,
    price_eur = suppressWarnings(as.numeric(.euets_pick(df, c("price", "settlement_price", "mean_price")))),
    venue = as.character(.euets_pick(df, c("venue", "exchange"), default = "EEX")),
    volume_t = suppressWarnings(as.numeric(.euets_pick(df, c("volume", "allocated_volume")))),
    stringsAsFactors = FALSE
  )
}
