# Voluntary carbon market aggregators: Berkeley VROD, CarbonPlan
# OffsetsDB (via S3 parquet; REST API dead as of 2026-04).
#
# Climate Action Data Trust (CAD Trust) requires either self-hosting
# or a private partnership for API access, so not supported in v0.1.0.

#' Berkeley Voluntary Registry Offsets Database
#'
#' Fetches the Berkeley GSPP Voluntary Registry Offsets Database, an
#' aggregator of Verra, Gold Standard, ACR, CAR, and ART TREES
#' project registrations and issuances. Released bimonthly under
#' CC BY 4.0.
#'
#' @param refresh Re-download? Default `FALSE`. Each release has a
#'   date-stamped filename; the package scrapes the landing page to
#'   find the latest release on each call unless a cached copy exists.
#' @return A data frame of project-level data.
#' @family voluntary markets
#' @export
#' @examples
#' \donttest{
#' op <- options(carbondata.cache_dir = tempdir())
#' vrod <- co2_vrod()
#' options(op)
#' }
co2_vrod <- function(refresh = FALSE) {
  page_url <- "https://gspp.berkeley.edu/berkeley-carbon-trading-project/offsets-database"
  cli_inform(c("i" = "Resolving latest VROD release..."))
  hits <- co2_scrape_links(
    page_url,
    "Voluntary-Registry-Offsets-Database--v[0-9-]+(-year-end)?\\.xlsx$"
  )
  if (length(hits) == 0L) {
    cli_abort(c(
      "No VROD file found on {.url {page_url}}.",
      "i" = "Berkeley may have restructured the landing page."
    ))
  }
  url <- hits[1L]
  filename <- basename(url)
  dest <- file.path(co2_cache_dir(), paste0("vrod_", filename))
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading {.file {filename}} (~16 MB)..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }
  df <- readxl::read_excel(dest, sheet = 1L)
  as.data.frame(df, stringsAsFactors = FALSE)
}

#' CarbonPlan OffsetsDB (via S3 parquet)
#'
#' Fetches the CarbonPlan OffsetsDB daily snapshots of voluntary
#' carbon market projects and credits, stored as Parquet in a public
#' S3 bucket. Covers Verra, ART TREES, Gold Standard, American
#' Carbon Registry, and Climate Action Reserve.
#'
#' The CarbonPlan REST API at `offsets-db-api.carbonplan.org` was
#' deprecated; this function uses the S3 bucket directly. Parquet
#' reading requires an installed Parquet reader; the `arrow`
#' package is the recommended suggest.
#'
#' @param kind Character. `"projects"` (default) or `"credits"`.
#' @param date Optional character. ISO date of the snapshot to fetch
#'   (must be a day CarbonPlan published; the function walks backwards
#'   from this date up to 7 days). Default `Sys.Date()`.
#' @param refresh Re-download? Default `FALSE`.
#'
#' @return A file path to the downloaded Parquet file. The caller
#'   must have `arrow` or `nanoparquet` installed to read it.
#'
#' @family voluntary markets
#' @export
#' @examples
#' \donttest{
#' op <- options(carbondata.cache_dir = tempdir())
#' path <- co2_offsets_db("projects")
#' if (requireNamespace("arrow", quietly = TRUE)) {
#'   df <- arrow::read_parquet(path)
#' }
#' options(op)
#' }
co2_offsets_db <- function(kind = c("projects", "credits"),
                           date = NULL, refresh = FALSE) {
  kind <- match.arg(kind)
  date <- date %||% format(Sys.Date(), "%Y-%m-%d")
  date <- co2_validate_date(date, "date")

  # Walk back up to 7 days to find an available snapshot
  found_url <- NULL
  found_date <- NULL
  for (offset in 0:7) {
    try_date <- format(as.Date(date) - offset, "%Y-%m-%d")
    candidate <- sprintf(
      "https://carbonplan-offsets-db.s3.amazonaws.com/final/%s/%s-augmented.parquet",
      try_date, kind
    )
    req <- co2_request(candidate)
    req <- httr2::req_method(req, "HEAD")
    resp <- tryCatch(httr2::req_perform(req), error = function(e) NULL)
    if (!is.null(resp) && httr2::resp_status(resp) == 200L) {
      found_url <- candidate
      found_date <- try_date
      break
    }
  }
  if (is.null(found_url)) {
    cli_abort(c(
      "No CarbonPlan OffsetsDB snapshot found within 7 days of {date}.",
      "i" = "Try a different {.arg date} or check the bucket status."
    ))
  }

  filename <- sprintf("offsetsdb_%s_%s-augmented.parquet", found_date, kind)
  dest <- file.path(co2_cache_dir(), filename)
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading OffsetsDB {kind} snapshot from {found_date}..."))
    co2_download(found_url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }
  if (!requireNamespace("arrow", quietly = TRUE) &&
      !requireNamespace("nanoparquet", quietly = TRUE)) {
    cli_warn(c(
      "!" = "Install the {.pkg arrow} or {.pkg nanoparquet} package to read the returned Parquet file.",
      "i" = "Returning file path only."
    ))
  }
  dest
}

#' Climate Action Data Trust (not supported in v0.1.0)
#'
#' CAD Trust is the Chia-Network "cadt" software designed to be
#' self-hosted. There is no unauthenticated public API. To use CAD
#' Trust data you must either:
#' \itemize{
#'   \item Self-host a cadt node, or
#'   \item Arrange a private partnership for API access via
#'     <https://climateactiondata.org/how-to-connect/>
#' }
#'
#' This function is a placeholder that errors with guidance. CAD Trust
#' support is deferred to carbondata v0.2.0 once CAD Trust offers a
#' stable public endpoint.
#'
#' @param ... Ignored.
#' @return Never returns (always errors).
#' @family voluntary markets
#' @export
#' @examples
#' \dontrun{
#' co2_cad_trust()
#' }
co2_cad_trust <- function(...) {
  cli_abort(c(
    "CAD Trust is not supported in carbondata v0.1.0.",
    "i" = "CAD Trust has no unauthenticated public API.",
    "i" = "Self-host a cadt node from https://github.com/Chia-Network/cadt, or",
    " " = "request partnership access at https://climateactiondata.org/how-to-connect/",
    " " = "Follow https://github.com/charlescoverdale/carbondata for v0.2.0 support."
  ))
}
