# EU ETS data from DG CLIMA Union Registry (bulk XLSX) and EEX
# (public auction XLSX reports).
#
# DG CLIMA publishes three families of files per compliance year:
#   - verified_emissions_YYYY_en.xlsx  (emissions + allocations)
#   - compliance_YYYY_code_en.xlsx     (cumulative surrendered totals)
#   - stationary_installations_union_registryr.xls  (registry snapshot)
#
# EEX publishes per-year primary auction reports:
#   - emission-spot-primary-market-auction-report-YYYY-data.xlsx
#
# The DG CLIMA document IDs are year-specific and change with each
# annual release; the EEX files use a stable year-parameterised URL.

.euets_dgclima_base <- "https://climate.ec.europa.eu/document/download"
.euets_eex_base <- "https://public.eex-group.com/eex/eua-auction-report"

# Verified UUIDs as of 2026-04-15. When DG CLIMA publishes a new
# annual file (usually April each year), add the new UUID here and
# bump the package version.
.euets_verified_emissions_uuids <- list(
  "2025" = "53018483-62b3-499e-9ab9-b4a831cc44f4",
  "2024" = "385daec1-0970-44ab-917d-f500658e72aa",
  "2023" = "ebb2c20e-8737-4a73-b6ba-a4b7e78ecc01",
  "2022" = "8f79885d-c567-4db2-9711-71ee8a29a037",
  "2021" = "9bcb5ebd-47bd-49af-8c19-a24df8077cf9"
)

.euets_compliance_uuids <- list(
  "2024" = "b80300cf-7608-405d-969e-8b016687640e",
  "2023" = "42495a32-cb4c-4772-9a2a-d08781c8ed61",
  "2022" = "7e7268a1-fa21-4f73-b368-6e9571262e2f",
  "2021" = "86a31a71-dff3-4729-86d0-943685c20dc1"
)

.euets_installations_uuid <- "9662827d-33a4-48ac-bf3f-d0b3712cd3f8"

#' EU ETS verified emissions
#'
#' Fetches annual verified greenhouse-gas emissions for installations
#' covered by the EU Emissions Trading System, from the DG CLIMA
#' Union Registry bulk download. Coverage: ~10,000 stationary
#' installations plus ~1,500 aircraft operators across the EU, EEA,
#' and linked Swiss ETS. Emissions data from 2005 onwards; annual
#' files published each April for the prior compliance year.
#'
#' @param country Optional character vector of two-letter registry
#'   codes to filter (e.g. `c("DE", "FR", "PL")`).
#' @param year Optional integer vector of emissions years. When
#'   `NULL`, returns all years in the latest published file. Note
#'   that the file year (e.g. "2025") refers to publication year;
#'   emissions data covers calendar years up to publication year -1.
#' @param file_year Publication year of the DG CLIMA file to use.
#'   Default is the latest year available in the package (see
#'   [co2_euets_files()]).
#' @param refresh Logical. Re-download? Default `FALSE`.
#'
#' @return A data frame with columns `country`, `installation_id`,
#'   `installation_name`, `activity`, `year`,
#'   `verified_emissions_tco2e`, `allocation_eua`.
#'
#' @family EU ETS
#' @export
#' @examples
#' \dontrun{
#' de <- co2_euets_emissions(country = "DE")
#' }
co2_euets_emissions <- function(country = NULL, year = NULL,
                                file_year = NULL, refresh = FALSE) {
  year <- co2_validate_year(year, min_year = 2005L)
  file_year <- .euets_resolve_file_year(file_year)
  path <- .euets_download_xlsx("verified_emissions", file_year, refresh)
  df <- .euets_read_wide_long(path, measure = "VERIFIED_EMISSIONS")
  df$allocation_eua <- .euets_read_wide_long(
    path, measure = "ALLOCATION"
  )$value
  df$verified_emissions_tco2e <- df$value
  df$value <- NULL

  if (!is.null(country)) df <- df[df$country %in% toupper(country), , drop = FALSE]
  if (!is.null(year))    df <- df[df$year %in% year, , drop = FALSE]
  rownames(df) <- NULL
  df
}

#' EU ETS free allowance allocations
#'
#' Returns free allowance allocations per installation per year.
#' Same source file as [co2_euets_emissions()].
#'
#' @inheritParams co2_euets_emissions
#' @return A data frame with `country`, `installation_id`, `year`,
#'   `allocation_eua`.
#' @family EU ETS
#' @export
#' @examples
#' \dontrun{
#' alloc <- co2_euets_allocations(country = "DE")
#' }
co2_euets_allocations <- function(country = NULL, year = NULL,
                                  file_year = NULL, refresh = FALSE) {
  year <- co2_validate_year(year, min_year = 2005L)
  file_year <- .euets_resolve_file_year(file_year)
  path <- .euets_download_xlsx("verified_emissions", file_year, refresh)
  df <- .euets_read_wide_long(path, measure = "ALLOCATION")
  names(df)[names(df) == "value"] <- "allocation_eua"
  if (!is.null(country)) df <- df[df$country %in% toupper(country), , drop = FALSE]
  if (!is.null(year))    df <- df[df$year %in% year, , drop = FALSE]
  rownames(df) <- NULL
  df
}

#' EU ETS compliance status and cumulative surrendered units
#'
#' Returns cumulative total surrendered allowances per installation,
#' compliance code, and account closure date. Per-year surrender events
#' require the EUTL transaction log ZIP, which is deferred to v0.2.0
#' because it is ~1.5 GB uncompressed and requires LZMA extraction.
#'
#' @param country Optional two-letter registry codes.
#' @param file_year Publication year of the compliance file. Default
#'   is the latest in the package.
#' @param refresh Re-download? Default `FALSE`.
#'
#' @return A data frame with `country`, `installation_id`,
#'   `installation_name`, `compliance_code`, `compliance_status`,
#'   `total_verified_emissions`, `total_surrendered_allowances`,
#'   `year_of_first_emissions`, `year_of_last_emissions`,
#'   `account_closure`.
#'
#' @family EU ETS
#' @export
#' @examples
#' \dontrun{
#' comp <- co2_euets_surrendered(country = "FR")
#' }
co2_euets_surrendered <- function(country = NULL, file_year = NULL,
                                  refresh = FALSE) {
  file_year <- .euets_resolve_file_year(file_year,
                                        kind = "compliance")
  uuid <- .euets_compliance_uuids[[as.character(file_year)]]
  if (is.null(uuid)) {
    cli_abort(c(
      "No compliance file available for year {file_year}.",
      "i" = "Available: {.val {names(.euets_compliance_uuids)}}"
    ))
  }
  filename <- sprintf("compliance_%d_code_en.xlsx", file_year)
  url <- sprintf("%s/%s_en?filename=%s",
                 .euets_dgclima_base, uuid, filename)
  dest <- file.path(co2_cache_dir(), filename)
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading DG CLIMA compliance file for {file_year}..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }

  df <- readxl::read_excel(dest)
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  out <- data.frame(
    country = toupper(as.character(co2_pick(df, c("REGISTRY_CODE", "REGISTRY", "country")))),
    installation_id = as.character(co2_pick(df, c("INSTALLATION_IDENTIFIER", "INSTALLATION_ID"))),
    installation_name = as.character(co2_pick(df, c("INSTALLATION_NAME", "NAME"))),
    compliance_code = as.character(co2_pick(df, c("COMPLIANCE_CODE"))),
    compliance_status = as.character(co2_pick(df, c("COMPLIANCE_STATUS_LATEST_YEAR", "COMPLIANCE_STATUS"))),
    total_verified_emissions = suppressWarnings(as.numeric(
      co2_pick(df, c("TOTAL_VERIFIED_EMISSIONS"))
    )),
    total_surrendered_allowances = suppressWarnings(as.numeric(
      co2_pick(df, c("TOTAL_SURRENDERED_ALLOWANCES"))
    )),
    year_of_first_emissions = suppressWarnings(as.integer(
      co2_pick(df, c("YEAR_OF_FIRST_EMISSIONS"))
    )),
    year_of_last_emissions = suppressWarnings(as.integer(
      co2_pick(df, c("YEAR_OF_LAST_EMISSIONS"))
    )),
    account_closure = as.character(co2_pick(df, c("ACCOUNT_CLOSURE"))),
    stringsAsFactors = FALSE
  )
  if (!is.null(country)) out <- out[out$country %in% toupper(country), , drop = FALSE]
  rownames(out) <- NULL
  out
}

#' EU ETS installation registry
#'
#' Returns the registry of stationary EU ETS installations with
#' operator name, activity type, country, city, and permit details.
#' Sourced from the DG CLIMA Union Registry snapshot.
#'
#' @param country Optional two-letter registry codes.
#' @param refresh Re-download? Default `FALSE`.
#' @return A data frame.
#' @family EU ETS
#' @export
#' @examples
#' \dontrun{
#' inst <- co2_euets_installations(country = "PL")
#' }
co2_euets_installations <- function(country = NULL, refresh = FALSE) {
  uuid <- .euets_installations_uuid
  filename <- "stationary_installations_union_registry.xls"
  url <- sprintf("%s/%s_en?filename=%s",
                 .euets_dgclima_base, uuid, filename)
  dest <- file.path(co2_cache_dir(), filename)
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading EU ETS installation registry..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }

  df <- readxl::read_excel(dest)
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  out <- data.frame(
    country = toupper(as.character(co2_pick(df, c("MS Registry", "country", "REGISTRY")))),
    installation_id = as.character(co2_pick(df, c("Installation ID", "installation_id"))),
    installation_name = as.character(co2_pick(df, c("Installation Name", "installation_name"))),
    account_holder = as.character(co2_pick(df, c("Account Holder Name", "account_holder"))),
    activity = as.character(co2_pick(df, c("Activity Type", "activity"))),
    permit_id = as.character(co2_pick(df, c("Permit ID", "permit"))),
    permit_status = as.character(co2_pick(df, c("Permit Status"))),
    city = as.character(co2_pick(df, c("Contact City", "city"))),
    postcode = as.character(co2_pick(df, c("Contact PCode", "postcode"))),
    stringsAsFactors = FALSE
  )
  if (!is.null(country)) out <- out[out$country %in% toupper(country), , drop = FALSE]
  rownames(out) <- NULL
  out
}

#' EU ETS allowance (EUA) auction settlement prices
#'
#' Fetches EU Allowance (EUA) primary-auction settlement prices from
#' the EEX public auction report. Auctions are held several times per
#' week; each year's file accumulates all auctions for that year.
#'
#' @param from,to Optional character or Date. Date range.
#' @param year Optional integer year. If supplied, only the file for
#'   that year is fetched (faster than `from`/`to`).
#' @param refresh Re-download? Default `FALSE`.
#' @return A data frame with `date`, `auction_name`, `contract`,
#'   `status`, `price_eur`, `min_bid_eur`, `max_bid_eur`, `volume_t`.
#' @family EU ETS
#' @export
#' @examples
#' \dontrun{
#' prices <- co2_euets_price(year = 2025)
#' }
co2_euets_price <- function(from = NULL, to = NULL, year = NULL,
                            refresh = FALSE) {
  from <- co2_validate_date(from, "from")
  to   <- co2_validate_date(to, "to")

  if (is.null(year)) {
    years <- if (!is.null(from)) {
      seq(as.integer(substr(from, 1L, 4L)),
          as.integer(substr(to %||% format(Sys.Date(), "%Y-%m-%d"), 1L, 4L)))
    } else {
      as.integer(format(Sys.Date(), "%Y"))
    }
  } else {
    years <- co2_validate_year(year, min_year = 2017L)
  }

  results <- lapply(years, function(y) {
    ext <- if (y < 2020L) "xls" else "xlsx"
    filename <- sprintf("emission-spot-primary-market-auction-report-%d-data.%s", y, ext)
    url <- paste0(.euets_eex_base, "/", filename)
    dest <- file.path(co2_cache_dir(), filename)
    if (!file.exists(dest) || refresh) {
      cli_inform(c("i" = "Downloading EEX EUA auction report for {y}..."))
      co2_download(url, dest, refresh = refresh)
    }
    df <- readxl::read_excel(dest, skip = 5L)
    as.data.frame(df, stringsAsFactors = FALSE)
  })
  df <- do.call(rbind, lapply(results, .euets_tidy_price))
  if (!is.null(from)) df <- df[df$date >= as.Date(from), , drop = FALSE]
  if (!is.null(to))   df <- df[df$date <= as.Date(to), , drop = FALSE]
  rownames(df) <- NULL
  df
}

#' List the EU ETS data file versions bundled with this package
#'
#' Returns a data frame of the DG CLIMA file vintages supported.
#' When DG CLIMA publishes a newer file, upgrade the package.
#'
#' @return A data frame.
#' @family EU ETS
#' @export
#' @examples
#' co2_euets_files()
co2_euets_files <- function() {
  data.frame(
    kind = c(rep("verified_emissions", length(.euets_verified_emissions_uuids)),
             rep("compliance", length(.euets_compliance_uuids))),
    file_year = c(as.integer(names(.euets_verified_emissions_uuids)),
                  as.integer(names(.euets_compliance_uuids))),
    uuid = c(unlist(.euets_verified_emissions_uuids),
             unlist(.euets_compliance_uuids)),
    stringsAsFactors = FALSE
  )
}

#' @noRd
.euets_resolve_file_year <- function(file_year, kind = "verified_emissions") {
  uuids <- if (kind == "verified_emissions") {
    .euets_verified_emissions_uuids
  } else {
    .euets_compliance_uuids
  }
  if (is.null(file_year)) {
    return(max(as.integer(names(uuids))))
  }
  if (!as.character(file_year) %in% names(uuids)) {
    cli_abort(c(
      "No {kind} file available for year {file_year}.",
      "i" = "Available: {.val {names(uuids)}}"
    ))
  }
  as.integer(file_year)
}

#' @noRd
.euets_download_xlsx <- function(kind, file_year, refresh) {
  uuid <- if (kind == "verified_emissions") {
    .euets_verified_emissions_uuids[[as.character(file_year)]]
  } else {
    .euets_compliance_uuids[[as.character(file_year)]]
  }
  filename <- if (kind == "verified_emissions") {
    sprintf("verified_emissions_%d_en.xlsx", file_year)
  } else {
    sprintf("compliance_%d_code_en.xlsx", file_year)
  }
  url <- sprintf("%s/%s_en?filename=%s",
                 .euets_dgclima_base, uuid, filename)
  dest <- file.path(co2_cache_dir(), filename)
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading DG CLIMA {kind} file for {file_year}..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }
  dest
}

#' @noRd
.euets_read_wide_long <- function(path, measure) {
  df <- readxl::read_excel(path, sheet = "data")
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  # Columns are e.g. VERIFIED_EMISSIONS_2005, ALLOCATION_2005, etc.
  # Reshape to long.
  meas_cols <- grep(paste0("^", measure, "_\\d{4}$"), names(df), value = TRUE)
  if (length(meas_cols) == 0L) {
    cli_abort("No {.val {measure}} columns found in DG CLIMA file.")
  }
  id_cols <- list(
    country = as.character(co2_pick(df, c("REGISTRY_CODE", "country"))),
    installation_id = as.character(co2_pick(df, c("INSTALLATION_IDENTIFIER", "INSTALLATION_ID"))),
    installation_name = as.character(co2_pick(df, c("INSTALLATION_NAME", "NAME"))),
    activity = as.character(co2_pick(df, c("MAIN_ACTIVITY_TYPE_CODE", "ACTIVITY")))
  )
  long_parts <- lapply(meas_cols, function(col) {
    yr <- as.integer(sub(paste0("^", measure, "_"), "", col))
    val <- suppressWarnings(as.numeric(df[[col]]))
    data.frame(
      country = toupper(id_cols$country),
      installation_id = id_cols$installation_id,
      installation_name = id_cols$installation_name,
      activity = id_cols$activity,
      year = yr,
      value = val,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, long_parts)
}

#' @noRd
.euets_tidy_price <- function(df) {
  data.frame(
    date = suppressWarnings(as.Date(co2_pick(df, c("Date", "^date$")))),
    auction_name = as.character(co2_pick(df, c("Auction Name", "auction"))),
    contract = as.character(co2_pick(df, c("Contract", "contract"))),
    status = as.character(co2_pick(df, c("Status", "status"))),
    price_eur = suppressWarnings(as.numeric(co2_pick(df, c("Auction Price", "Mean", "price")))),
    min_bid_eur = suppressWarnings(as.numeric(co2_pick(df, c("Minimum Bid", "Minimum")))),
    max_bid_eur = suppressWarnings(as.numeric(co2_pick(df, c("Maximum Bid", "Maximum")))),
    volume_t = suppressWarnings(as.numeric(co2_pick(df, c("Auction Volume", "Volume")))),
    stringsAsFactors = FALSE
  )
}
