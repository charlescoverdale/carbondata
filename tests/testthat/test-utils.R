test_that("co2_validate_year accepts valid years and rejects invalid", {
  expect_null(co2_validate_year(NULL))
  expect_equal(co2_validate_year(2020L), 2020L)
  expect_equal(co2_validate_year(c(2020, 2021)), c(2020L, 2021L))
  expect_error(co2_validate_year("2020"))
  expect_error(co2_validate_year(1800L))
  expect_error(co2_validate_year(3000L))
})

test_that("co2_validate_date parses and rejects", {
  expect_null(co2_validate_date(NULL))
  expect_equal(co2_validate_date("2020-01-01"), "2020-01-01")
  expect_equal(co2_validate_date(as.Date("2020-01-01")), "2020-01-01")
  expect_error(co2_validate_date("not-a-date"))
})

test_that("co2_format_bytes returns human-readable", {
  expect_equal(co2_format_bytes(500), "500 B")
  expect_equal(co2_format_bytes(1500), "1.5 KB")
  expect_equal(co2_format_bytes(1.5e6), "1.4 MB")
  expect_equal(co2_format_bytes(1.5e9), "1.4 GB")
})

test_that("co2_list_to_df handles empty input", {
  expect_equal(nrow(co2_list_to_df(list())), 0)
})

test_that("co2_list_to_df handles heterogeneous records", {
  items <- list(
    list(a = 1, b = "x"),
    list(a = 2, c = "y")
  )
  df <- co2_list_to_df(items)
  expect_equal(nrow(df), 2L)
  expect_true(all(c("a", "b", "c") %in% names(df)))
})

test_that("co2_cache_dir creates a directory", {
  op <- options(carbondata.cache_dir = tempfile("co2_test_"))
  on.exit(options(op))
  d <- co2_cache_dir()
  expect_true(dir.exists(d))
})

test_that("%||% returns left if non-null else right", {
  expect_equal("a" %||% "b", "a")
  expect_equal(NULL %||% "b", "b")
  expect_null(NULL %||% NULL)
})

test_that("co2_pick finds columns case-insensitively", {
  df <- data.frame(REGISTRY_CODE = c("DE", "FR"), other = 1:2)
  expect_equal(co2_pick(df, "registry_code"), c("DE", "FR"))
})

test_that("co2_pick fills the default when not required", {
  df <- data.frame(a = 1:2)
  expect_equal(co2_pick(df, "missing_col"), rep(NA_character_, 2L))
})

test_that("co2_pick aborts when a required column is absent", {
  # A silent NA column turns a downstream filter into an empty result
  # with no explanation, so required columns must error instead.
  df <- data.frame(a = 1:2)
  expect_error(co2_pick(df, "installation_id", required = TRUE),
               "Expected a column")
})

test_that("co2_latest_release ranks by embedded date, not lexically", {
  urls <- c(
    "https://x/Voluntary-Registry-Offsets-Database--v4-2021-year-end.xlsx",
    "https://x/Voluntary-Registry-Offsets-Database--v2026-06.xlsx",
    "https://x/Voluntary-Registry-Offsets-Database--v9-2023.xlsx"
  )
  # Lexical sorting picks "v9"/"v4" over "v2026"; date ranking must not.
  expect_match(co2_latest_release(urls), "v2026-06")
})

test_that("co2_latest_release falls back to lexical order without dates", {
  urls <- c("https://x/report-a.xlsx", "https://x/report-b.xlsx")
  expect_equal(co2_latest_release(urls), "https://x/report-b.xlsx")
})

test_that("co2_latest_release handles a single URL and none", {
  expect_equal(co2_latest_release("https://x/data_08_2025.xlsx"),
               "https://x/data_08_2025.xlsx")
  expect_length(co2_latest_release(character(0L)), 0L)
})

test_that("co2_safe_filename strips characters publishers use", {
  expect_equal(
    co2_safe_filename("UK_ETS_Compliance_Report_Emissions_%26_Surrenders_2026.xlsx"),
    "UK_ETS_Compliance_Report_Emissions_Surrenders_2026.xlsx"
  )
  expect_equal(co2_safe_filename("plain-name_2026.csv"), "plain-name_2026.csv")
})

test_that("co2_clean_names flattens wrapped spreadsheet headers", {
  # VROD ships a column literally named "Total Credits \r\nIssued";
  # nobody can guess that, and it makes every reference unreadable.
  df <- data.frame(check.names = FALSE, x = 1)
  names(df) <- "Total Credits \r\nIssued"
  expect_equal(names(co2_clean_names(df)), "Total Credits Issued")
})

test_that("co2_clean_names leaves tidy names alone", {
  df <- data.frame(check.names = FALSE, `Project ID` = "a", price_eur = 1)
  names(df) <- c("Project ID", "price_eur")
  expect_equal(names(co2_clean_names(df)), c("Project ID", "price_eur"))
})

test_that("a failed download leaves no file behind", {
  # httr2 writes the response body to `path` before raising on an HTTP
  # error, so writing straight to the destination left the error page
  # in the cache for every later call to serve.
  skip_if_offline()
  op <- options(carbondata.cache_dir = tempfile("co2_fail_"))
  on.exit(options(op))
  dest <- file.path(co2_cache_dir(), "should-not-exist.xlsx")
  expect_error(suppressMessages(
    co2_download("https://httpbin.org/status/404", dest)
  ))
  expect_false(file.exists(dest))
})

test_that("co2_find_header_row finds a header below a preamble", {
  skip_if_not_installed("writexl")
  f <- tempfile(fileext = ".xlsx")
  # Mimic the DG CLIMA layout: notes above the real header row.
  writexl::write_xlsx(
    data.frame(a = c("Date of Extraction", NA, "REGISTRY_CODE", "DE"),
               b = c("1 April 2024", NA, "INSTALLATION_NAME", "Werk"),
               stringsAsFactors = FALSE),
    f
  )
  # Row 1 is the written header, so the marker lands on sheet row 4.
  expect_equal(co2_find_header_row(f, "^REGISTRY_CODE$"), 3L)
})

test_that("co2_find_header_row errors when the marker is absent", {
  skip_if_not_installed("writexl")
  f <- tempfile(fileext = ".xlsx")
  writexl::write_xlsx(data.frame(a = 1:3), f)
  expect_error(co2_find_header_row(f, "^REGISTRY_CODE$"), "Could not find")
})

test_that("co2_download honours max_age_days", {
  op <- options(carbondata.cache_dir = tempfile("co2_ttl_"))
  on.exit(options(op))
  dest <- file.path(co2_cache_dir(), "cached.txt")
  writeLines("stale", dest)
  # Fresh enough to serve from cache without touching the network.
  expect_equal(co2_download("https://invalid.invalid/x", dest,
                            max_age_days = 30), dest)
  # Older than the TTL, so it must attempt a download and fail loudly
  # rather than silently serving a stale file.
  Sys.setFileTime(dest, Sys.time() - 60 * 60 * 24 * 40)
  expect_error(suppressMessages(
    co2_download("https://invalid.invalid/x", dest, max_age_days = 30)
  ))
})
