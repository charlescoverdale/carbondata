# Cross-market aggregators: ICAP, World Bank, RFF.

#' ICAP Allowance Price Explorer
#'
#' Fetches allowance prices across 20+ Emissions Trading Systems from
#' the International Carbon Action Partnership (ICAP) Allowance Price
#' Explorer. Covers EU ETS, UK ETS, California, RGGI, New Zealand,
#' Korea, and other jurisdictions with auction and secondary-market
#' prices where available.
#'
#' @param jurisdiction Optional character vector. Filter by
#'   jurisdiction name (e.g. `c("Regional Greenhouse Gas Initiative",
#'   "EU ETS")`). When `NULL`, returns all.
#' @param refresh Re-download? Default `FALSE`.
#'
#' @return A data frame with `date`, `jurisdiction`, `market_type`
#'   (`"primary"` auction or `"secondary"`), `price`, and `currency`.
#'
#' @family aggregators
#' @export
#' @examples
#' \dontrun{
#' prices <- co2_icap_prices(jurisdiction = "EU ETS")
#' }
co2_icap_prices <- function(jurisdiction = NULL, refresh = FALSE) {
  url <- "https://allowancepriceexplorer.icapcarbonaction.com/api/systems"
  dest <- file.path(co2_cache_dir(), "icap_prices.json")
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading ICAP Allowance Price Explorer data..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading ICAP data from cache."))
  }

  body <- jsonlite::fromJSON(dest, simplifyVector = FALSE)
  if (length(body) == 0L) return(data.frame())

  rows <- list()
  for (sys in body) {
    name <- sys$name %||% NA_character_
    curr <- if (!is.null(sys$currency)) sys$currency[[1L]] else "USD"
    for (mt in c("primary", "secondary")) {
      vals <- sys$values[[mt]]
      if (is.null(vals)) next
      for (d in names(vals)) {
        v <- vals[[d]]
        if (is.null(v) || length(v) == 0L) next
        price <- as.numeric(v[[1L]])
        if (is.na(price)) next
        rows[[length(rows) + 1L]] <- data.frame(
          date = as.Date(d),
          jurisdiction = name,
          market_type = mt,
          price = price,
          currency = curr,
          stringsAsFactors = FALSE
        )
      }
    }
  }
  out <- if (length(rows) == 0L) data.frame() else do.call(rbind, rows)

  if (!is.null(jurisdiction) && nrow(out) > 0L) {
    out <- out[out$jurisdiction %in% jurisdiction, , drop = FALSE]
  }
  rownames(out) <- NULL
  out
}

#' World Bank Carbon Pricing Dashboard
#'
#' Fetches the World Bank Carbon Pricing Dashboard Excel file, which
#' covers 70+ carbon pricing initiatives worldwide (carbon taxes +
#' ETS) with price, coverage, and revenue data.
#'
#' The World Bank publishes a dated file every 6-12 months. This
#' function scrapes the landing page to find the latest release.
#'
#' @param refresh Re-download? Default `FALSE`.
#' @return A data frame.
#' @family aggregators
#' @export
#' @examples
#' \dontrun{
#' wb <- co2_world_bank()
#' }
co2_world_bank <- function(refresh = FALSE) {
  page_url <- "https://carbonpricingdashboard.worldbank.org/about"
  cli_inform(c("i" = "Resolving latest World Bank Carbon Pricing file..."))
  hits <- co2_scrape_links(
    page_url,
    "carbon-pricing-dashboard-data/data_\\d{2}_\\d{4}\\.xlsx$"
  )
  if (length(hits) == 0L) {
    cli_abort(c(
      "No World Bank Carbon Pricing file found on {.url {page_url}}.",
      "i" = "The dashboard may have restructured its downloads page."
    ))
  }
  url <- hits[1L]
  filename <- basename(url)
  dest <- file.path(co2_cache_dir(), paste0("wb_", filename))
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading {.file {filename}}..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }
  df <- readxl::read_excel(dest)
  as.data.frame(df, stringsAsFactors = FALSE)
}

#' RFF World Carbon Pricing Database
#'
#' Fetches the Dolphin-Pollitt-Newbery World Carbon Pricing Database
#' for one country. Covers national-level carbon pricing from 1989
#' to present, with CO2 tax and ETS instruments harmonised across
#' 200+ jurisdictions.
#'
#' @param country Character. Country name using underscores
#'   (e.g. `"United_Kingdom"`, `"Germany"`, `"Antigua_and_Barbuda"`).
#' @param version Character. Dataset version folder. Default
#'   `"v2026.1"`.
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
#' \dontrun{
#' uk <- co2_rff_pricing("United_Kingdom")
#' }
co2_rff_pricing <- function(country, version = "v2026.1", refresh = FALSE) {
  if (missing(country) || !is.character(country) || length(country) != 1L) {
    cli_abort("{.arg country} must be a single country name with underscores.")
  }
  filename <- sprintf("wcpd_co2_%s.csv", country)
  url <- sprintf(
    "https://raw.githubusercontent.com/g-dolphin/WorldCarbonPricingDatabase/main/_dataset/data/%s/CO2/national/%s",
    version, filename
  )
  dest <- file.path(co2_cache_dir(), paste0("rff_", filename))
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading RFF World Carbon Pricing Database for {country}..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }
  df <- utils::read.csv(dest, stringsAsFactors = FALSE, check.names = FALSE,
                        na.strings = c("", "NA"))
  df
}
