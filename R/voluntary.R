# Voluntary carbon market aggregators: Berkeley VROD, CarbonPlan
# OffsetsDB (via S3 parquet; REST API dead as of 2026-04, and daily
# snapshots stopped after 2026-06-01).
#
# Climate Action Data Trust (CAD Trust) requires either self-hosting
# or a private partnership for API access, so it is not supported.

#' Berkeley Voluntary Registry Offsets Database
#'
#' Fetches the Berkeley GSPP Voluntary Registry Offsets Database, an
#' aggregator of Verra, Gold Standard, ACR, CAR, and ART TREES
#' project registrations and issuances. Released bimonthly under
#' CC BY 4.0.
#'
#' @param sheet Character. Which workbook sheet to read. `"PROJECTS"`
#'   (default) is the project register and the only sheet that is a
#'   tidy table: it is parsed properly, with the header row located and
#'   tally rows dropped. The workbook's other sheets are charts,
#'   documentation, and drop-down lookups rather than datasets; naming
#'   one reads it verbatim and you get whatever layout it happens to
#'   have.
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
co2_vrod <- function(sheet = "PROJECTS", refresh = FALSE) {
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
  # The archive mixes numbering schemes (v4-2021-year-end alongside
  # v2026-06), so rank by the date in the filename, not lexically.
  url <- co2_latest_release(hits)
  filename <- co2_safe_filename(basename(url))
  dest <- file.path(co2_cache_dir(), paste0("vrod_", filename))
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading {.file {filename}} (~16 MB)..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading {.file {filename}} from cache."))
  }

  sheets <- readxl::excel_sheets(dest)
  if (!sheet %in% sheets) {
    cli_abort(c(
      "Sheet {.val {sheet}} not found in the VROD workbook.",
      "i" = "Available sheets: {.val {sheets}}"
    ))
  }
  # Only PROJECTS is a tidy table. Reading any other sheet is an escape
  # hatch, so parse it verbatim rather than imposing this layout on it.
  if (!identical(sheet, "PROJECTS")) {
    df <- readxl::read_excel(dest, sheet = sheet, guess_max = 1048576L)
    return(co2_clean_names(as.data.frame(df, stringsAsFactors = FALSE)))
  }

  # Sheet 1 is a "READ FIRST" cover sheet, and PROJECTS carries three
  # banner rows above its header, so locate the header row.
  skip <- co2_find_header_row(dest, marker = "^Project ID$", sheet = sheet)
  # Several columns are blank for well over readxl's default 1000-row
  # type-guessing window and only fill in later. Guessing from that
  # window types them as logical and discards every later value: 9
  # columns and 13,156 values in the 2026-06 release, including all
  # project registration dates. Guess from the whole sheet instead.
  df <- readxl::read_excel(dest, sheet = sheet, skip = skip,
                           guess_max = 1048576L)
  df <- co2_clean_names(as.data.frame(df, stringsAsFactors = FALSE))
  # Drop trailing tally rows, which carry no project identifier.
  id <- as.character(co2_pick(df, c("Project ID"), required = TRUE))
  df <- df[!is.na(id) & nzchar(trimws(id)), , drop = FALSE]
  rownames(df) <- NULL
  df
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
#' @param date Optional character. ISO date of the snapshot to fetch.
#'   The function walks backwards from this date to find a published
#'   snapshot. Default `Sys.Date()`.
#' @param max_lookback Integer. How many days to walk back before
#'   giving up. Default 180, because CarbonPlan's publication cadence
#'   became irregular during 2026 and the last snapshot seen was
#'   1 June 2026.
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
                           date = NULL, max_lookback = 180L,
                           refresh = FALSE) {
  kind <- match.arg(kind)
  date <- date %||% format(Sys.Date(), "%Y-%m-%d")
  date <- co2_validate_date(date, "date")

  # Publication went from daily to irregular during 2026, so a coarse
  # step can jump straight over an isolated snapshot. Probe every day:
  # when the bucket is healthy this stops within one or two requests,
  # and the long walk only runs when the source has gone quiet.
  found_url <- NULL
  found_date <- NULL
  for (offset in seq.int(0L, as.integer(max_lookback))) {
    try_date <- format(as.Date(date) - offset, "%Y-%m-%d")
    candidate <- sprintf(
      "https://carbonplan-offsets-db.s3.amazonaws.com/final/%s/%s-augmented.parquet",
      try_date, kind
    )
    # Bare request: these are tiny HEAD probes against S3 and there may
    # be a lot of them, so skip the shared throttle and retry policy.
    req <- httr2::req_error(
      httr2::req_user_agent(httr2::request(candidate), .co2_user_agent),
      is_error = function(resp) FALSE
    )
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
      "No CarbonPlan OffsetsDB snapshot found within {max_lookback} days of {date}.",
      "i" = "CarbonPlan stopped publishing daily snapshots during 2026.",
      "i" = "Try {.code co2_vrod()} for an actively maintained voluntary market dataset."
    ))
  }
  stale_days <- as.integer(as.Date(date) - as.Date(found_date))
  if (stale_days > 14L) {
    cli_warn(c(
      "!" = "Newest OffsetsDB snapshot is {stale_days} days old ({found_date}).",
      "i" = "CarbonPlan's publication cadence became irregular in 2026."
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

#' Climate Action Data Trust (not supported)
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
#' This function is a placeholder that errors with guidance. It will
#' gain an implementation once CAD Trust offers a stable public
#' endpoint.
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
    "CAD Trust is not supported by carbondata.",
    "i" = "CAD Trust has no unauthenticated public API.",
    "i" = "Self-host a cadt node from https://github.com/Chia-Network/cadt, or",
    " " = "request partnership access at https://climateactiondata.org/how-to-connect/",
    " " = "Follow https://github.com/charlescoverdale/carbondata for v0.2.0 support."
  ))
}
