# Exercise every live carbondata data source and write a markdown
# report. Exits non-zero if any source that is expected to work fails,
# which is what triggers the GitHub issue in the endpoint-canary
# workflow.
#
# Run locally with:  Rscript inst/canary/check-endpoints.R

library(carbondata)

options(carbondata.cache_dir = file.path(tempdir(), "carbondata-canary"))

# Publishers increasingly gate their files by network rather than by URL.
# Some answer an automated client with 403; others sit behind a CDN that
# returns an empty 200. Which side of that gate a machine falls on is not
# a property of this package, and the two environments disagree: CARB
# serves a laptop in London but not the GitHub runner, and the World Bank
# dashboard does the reverse. Errors carrying that signature are reported
# as blocked and do not fail the run. A moved URL, a changed layout or an
# empty result still fails, which is the drift the canary exists to catch.
network_refusal <- function(msg) {
  grepl("empty body|HTTP (401|403|429)", msg)
}

# Manual override for a source that has to be exempted for a reason the
# signature above cannot see. Normally empty.
known_unavailable <- character(0)

checks <- list(
  co2_euets_files        = function() co2_euets_files(),
  co2_euets_emissions    = function() co2_euets_emissions(country = "DE", year = 2024L),
  co2_euets_allocations  = function() co2_euets_allocations(country = "DE", year = 2024L),
  co2_euets_surrendered  = function() co2_euets_surrendered(country = "FR"),
  co2_euets_installations = function() co2_euets_installations(country = "PL"),
  co2_euets_price        = function() co2_euets_price(year = as.integer(format(Sys.Date(), "%Y"))),
  co2_ukets              = function() co2_ukets(),
  co2_ukets_allocations  = function() co2_ukets_allocations(),
  co2_rggi_allowances    = function() co2_rggi_allowances(year = as.integer(format(Sys.Date(), "%Y"))),
  co2_rggi_state_proceeds = function() co2_rggi_state_proceeds("NY"),
  co2_california_prices  = function() co2_california_prices(),
  co2_california_caps    = function() co2_california_caps(),
  co2_icap_prices        = function() co2_icap_prices(jurisdiction = "EU ETS"),
  co2_icap_systems       = function() co2_icap_systems(),
  co2_world_bank         = function() co2_world_bank(),
  co2_rff_pricing        = function() co2_rff_pricing("United_Kingdom"),
  co2_ecp_prices         = function() co2_ecp_prices(country = "United Kingdom"),
  co2_vrod               = function() co2_vrod(),
  co2_offsets_db         = function() co2_offsets_db("projects")
)

results <- lapply(names(checks), function(nm) {
  t0 <- Sys.time()
  out <- tryCatch(
    suppressMessages(suppressWarnings(checks[[nm]]())),
    error = function(e) e
  )
  secs <- round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 1)
  failed <- inherits(out, "error")
  detail <- if (failed) {
    gsub("\\s+", " ", conditionMessage(out))
  } else if (is.data.frame(out)) {
    sprintf("%d rows x %d cols", nrow(out), ncol(out))
  } else {
    paste(class(out)[1], "returned")
  }
  # An empty data frame means the parser silently stopped matching the
  # published layout, which is exactly the failure mode this catches.
  if (!failed && is.data.frame(out) && nrow(out) == 0L) {
    failed <- TRUE
    detail <- "returned 0 rows (parser or layout drift)"
  }
  status <- if (!failed) {
    "OK"
  } else if (nm %in% known_unavailable || network_refusal(detail)) {
    "blocked"
  } else {
    "FAIL"
  }
  list(name = nm, status = status, detail = detail, secs = secs)
})

status_of <- function(x) vapply(results, function(r) r$status == x, logical(1))
hard_failures <- results[status_of("FAIL")]
blocked <- results[status_of("blocked")]

lines <- c(
  sprintf("# carbondata endpoint canary, %s", format(Sys.Date())),
  "",
  sprintf(
    "%d of %d sources responded as expected, %d blocked from this network, %d failed.",
    sum(status_of("OK")), length(results), length(blocked), length(hard_failures)
  ),
  "",
  "| Source | Status | Detail | Time |",
  "|---|---|---|---|"
)
for (r in results) {
  lines <- c(lines, sprintf("| `%s` | %s | %s | %.1fs |",
                            r$name, r$status, r$detail, r$secs))
}

if (length(hard_failures) > 0L) {
  lines <- c(lines, "", "## Failures", "")
  for (r in hard_failures) {
    lines <- c(lines, sprintf("- **`%s`**: %s", r$name, r$detail))
  }
}

if (length(blocked) > 0L) {
  lines <- c(
    lines, "", "## Blocked from this network", "",
    "The publisher refused an automated client rather than the file having",
    "moved. These are reported, not failed: the same call may well work",
    "from a different machine.", ""
  )
  for (r in blocked) {
    lines <- c(lines, sprintf("- **`%s`**: %s", r$name, r$detail))
  }
}

writeLines(lines, "endpoint-report.md")
cat(paste(lines, collapse = "\n"), "\n")

# Put the table on the run page too, so a green run stays readable
# without downloading the artifact.
step_summary <- Sys.getenv("GITHUB_STEP_SUMMARY")
if (nzchar(step_summary)) {
  writeLines(lines, step_summary)
}

if (length(hard_failures) > 0L) {
  quit(status = 1L)
}
