# Voluntary carbon market data: Berkeley VROD, CarbonPlan OffsetsDB,
# CAD Trust. These aggregate data from Verra, Gold Standard, ACR,
# CAR, and other registries.

.offsets_db_base <- "https://offsets-db-api.carbonplan.org/api/v1"
.cad_trust_base <- "https://api.climateactiondata.org/v1"

#' Berkeley Voluntary Registry Offsets Database
#'
#' Fetches the Berkeley Voluntary Registry Offsets Database, a
#' project-level aggregator covering Verra (VCS), Gold Standard,
#' American Carbon Registry (ACR), Climate Action Reserve (CAR), and
#' ART TREES. Data is released quarterly under CC BY 4.0.
#'
#' @param registry Optional character. Filter by one or more
#'   registries: `"Verra"`, `"Gold Standard"`, `"ACR"`, `"CAR"`,
#'   `"ART TREES"`.
#' @param project_type Optional character. Filter by project type
#'   (e.g. `"Forestry"`, `"Renewable Energy"`, `"Household Devices"`).
#' @param country Optional character vector of country names.
#' @param refresh Re-download? Default `FALSE`.
#'
#' @return A data frame with project-level fields: `project_id`,
#'   `registry`, `project_name`, `country`, `project_type`,
#'   `methodology`, `total_issuances`, `total_retirements`, plus
#'   metadata.
#'
#' @family voluntary markets
#' @export
#' @examples
#' \dontrun{
#' op <- options(carbondata.cache_dir = tempdir())
#' vrod <- co2_vrod(registry = "Verra", project_type = "Forestry")
#' options(op)
#' }
co2_vrod <- function(registry = NULL, project_type = NULL,
                     country = NULL, refresh = FALSE) {
  # Berkeley VROD is published as an Excel file with a version suffix
  # that updates quarterly. We use the "latest" alias URL where
  # available, and fall back to scraping the landing page.
  url <- "https://gspp.berkeley.edu/assets/uploads/research/xlsx/GSPP_VRO_database_latest.xlsx"
  dest <- file.path(co2_cache_dir(), "vrod.xlsx")
  if (!file.exists(dest) || refresh) {
    cli_inform(c("i" = "Downloading Berkeley Voluntary Registry Offsets Database..."))
    co2_download(url, dest, refresh = refresh)
  } else {
    cli_inform(c("i" = "Loading VROD from cache."))
  }

  df <- tryCatch(
    readxl::read_excel(dest, sheet = 1),
    error = function(e) {
      cli_abort(c(
        "Failed to read VROD Excel file.",
        "x" = conditionMessage(e),
        "i" = "Try {.code co2_vrod(refresh = TRUE)} to re-download."
      ))
    }
  )
  df <- as.data.frame(df, stringsAsFactors = FALSE)
  out <- .vrod_tidy(df)

  if (!is.null(registry)) {
    out <- out[out$registry %in% registry, , drop = FALSE]
  }
  if (!is.null(project_type)) {
    out <- out[out$project_type %in% project_type, , drop = FALSE]
  }
  if (!is.null(country)) {
    out <- out[out$country %in% country, , drop = FALSE]
  }
  rownames(out) <- NULL
  out
}

#' CarbonPlan OffsetsDB
#'
#' Queries the CarbonPlan OffsetsDB REST API for voluntary carbon
#' market data. OffsetsDB aggregates project and credit data from
#' Verra, Gold Standard, ACR, CAR, ART, and Plan Vivo, with daily
#' updates.
#'
#' @param endpoint Character. One of `"projects"`, `"credits"`, or
#'   `"retirements"`. Default `"projects"`.
#' @param filters Named list of query parameters to pass through to
#'   the API. See the OffsetsDB API docs.
#' @param limit Integer. Max records to fetch. Default `1000`.
#'
#' @return A data frame of results.
#'
#' @family voluntary markets
#' @export
#' @examples
#' \dontrun{
#' offsets <- co2_offsets_db("projects", filters = list(registry = "Verra"))
#' }
co2_offsets_db <- function(endpoint = c("projects", "credits", "retirements"),
                           filters = list(), limit = 1000L) {
  endpoint <- match.arg(endpoint)
  if (!is.numeric(limit) || limit < 1L) {
    cli_abort("{.arg limit} must be a positive integer.")
  }

  url <- paste0(.offsets_db_base, "/", endpoint, "/")
  params <- c(filters, list(per_page = as.integer(limit)))

  req <- co2_request(url)
  req <- httr2::req_headers(req, Accept = "application/json")
  if (length(params) > 0L) {
    req <- httr2::req_url_query(req, !!!params)
  }
  resp <- tryCatch(
    httr2::req_perform(req),
    error = function(e) {
      cli_abort(c(
        "Failed to query OffsetsDB API.",
        "x" = conditionMessage(e)
      ))
    }
  )
  if (httr2::resp_status(resp) >= 400L) {
    cli_abort("OffsetsDB API returned HTTP {httr2::resp_status(resp)}.")
  }

  body <- httr2::resp_body_json(resp)
  items <- body$data %||% body$results %||% body
  if (!is.list(items) || length(items) == 0L) return(data.frame())
  co2_list_to_df(items)
}

#' Climate Action Data Trust (CAD Trust)
#'
#' Queries the Climate Action Data Trust API for metadata on
#' Article 6-aligned carbon credits. CAD Trust is a harmonised
#' registry-of-registries launched by the World Bank, IETA, and
#' partners. Public API access launched October 2025.
#'
#' @param project_id Optional character. Specific CAD Trust project ID.
#' @param refresh Re-download? Default `FALSE`.
#'
#' @return A data frame.
#'
#' @family voluntary markets
#' @export
#' @examples
#' \dontrun{
#' cad <- co2_cad_trust()
#' }
co2_cad_trust <- function(project_id = NULL, refresh = FALSE) {
  url <- if (is.null(project_id)) {
    paste0(.cad_trust_base, "/projects")
  } else {
    paste0(.cad_trust_base, "/projects/",
           utils::URLencode(project_id, reserved = TRUE))
  }

  req <- co2_request(url)
  req <- httr2::req_headers(req, Accept = "application/json")

  resp <- tryCatch(
    httr2::req_perform(req),
    error = function(e) {
      cli_abort(c(
        "Failed to query CAD Trust API.",
        "x" = conditionMessage(e),
        "i" = "CAD Trust API requires registration at https://climateactiondata.org/."
      ))
    }
  )
  if (httr2::resp_status(resp) >= 400L) {
    cli_abort("CAD Trust API returned HTTP {httr2::resp_status(resp)}.")
  }

  body <- httr2::resp_body_json(resp)
  items <- body$data %||% body$results %||% list(body)
  if (!is.list(items) || length(items) == 0L) return(data.frame())
  co2_list_to_df(items)
}

#' @noRd
.vrod_tidy <- function(df) {
  data.frame(
    project_id = as.character(.euets_pick(df, c("project_id", "id"))),
    registry = as.character(.euets_pick(df, c("registry", "standard"))),
    project_name = as.character(.euets_pick(df, c("project_name", "name", "project$"))),
    country = as.character(.euets_pick(df, c("country", "location"))),
    project_type = as.character(.euets_pick(df, c("project_type", "type", "scope", "category"))),
    methodology = as.character(.euets_pick(df, c("methodology", "protocol"))),
    total_issuances = suppressWarnings(as.numeric(
      .euets_pick(df, c("total_issuances", "total_credits_issued", "issuances"))
    )),
    total_retirements = suppressWarnings(as.numeric(
      .euets_pick(df, c("total_retirements", "total_credits_retired", "retirements"))
    )),
    first_issuance_date = suppressWarnings(as.Date(
      .euets_pick(df, c("first_issuance", "first_issued"))
    )),
    stringsAsFactors = FALSE
  )
}
