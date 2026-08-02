# Exercise every live carbondata data source and write a markdown
# report. Exits non-zero if any source that is expected to work fails,
# which is what triggers the GitHub issue in the endpoint-canary
# workflow.
#
# Run locally with:  Rscript inst/canary/check-endpoints.R

library(carbondata)

options(carbondata.cache_dir = file.path(tempdir(), "carbondata-canary"))

# Sources known to be unavailable through an automated client. These are
# reported but do not fail the run; see NEWS.md for the reasons.
known_unavailable <- c("co2_world_bank")

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
  list(name = nm, failed = failed, detail = detail, secs = secs)
})

hard_failures <- Filter(
  function(r) r$failed && !r$name %in% known_unavailable,
  results
)

lines <- c(
  sprintf("# carbondata endpoint canary, %s", format(Sys.Date())),
  "",
  sprintf("%d of %d sources responded as expected.",
          length(results) - length(hard_failures), length(results)),
  "",
  "| Source | Status | Detail | Time |",
  "|---|---|---|---|"
)
for (r in results) {
  status <- if (!r$failed) {
    "OK"
  } else if (r$name %in% known_unavailable) {
    "known-unavailable"
  } else {
    "FAIL"
  }
  lines <- c(lines, sprintf("| `%s` | %s | %s | %.1fs |",
                            r$name, status, r$detail, r$secs))
}

if (length(hard_failures) > 0L) {
  lines <- c(lines, "", "## Failures", "")
  for (r in hard_failures) {
    lines <- c(lines, sprintf("- **`%s`**: %s", r$name, r$detail))
  }
}

writeLines(lines, "endpoint-report.md")
cat(paste(lines, collapse = "\n"), "\n")

if (length(hard_failures) > 0L) {
  quit(status = 1L)
}
