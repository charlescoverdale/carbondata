test_that("co2_offsets_db validates kind", {
  expect_error(co2_offsets_db(kind = "invalid"))
})

test_that("co2_offsets_db validates date", {
  expect_error(co2_offsets_db(date = "not-a-date"))
})

test_that("co2_cad_trust always errors with guidance", {
  expect_error(co2_cad_trust(), "not supported")
})

test_that("co2_vrod live fetch returns the PROJECTS sheet", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(nzchar(Sys.getenv("CARBONDATA_LIVE_TESTS")),
              "Set CARBONDATA_LIVE_TESTS=1 to run live VROD tests.")
  df <- co2_vrod()
  expect_s3_class(df, "data.frame")
  # Sheet 1 is a "READ FIRST" cover sheet; reading it yielded a
  # single-column frame of prose rather than project records.
  expect_gt(ncol(df), 50L)
  expect_true("Project ID" %in% names(df))
  expect_gt(nrow(df), 10000L)
  # Columns that stay blank past readxl's default type-guessing window
  # were typed as logical and silently emptied.
  expect_false(is.logical(df[["Project Registered"]]))
  expect_gt(sum(!is.na(df[["Project Registered"]])), 0L)
  # Wrapped headers arrive with an embedded CRLF from the spreadsheet.
  expect_true("Total Credits Issued" %in% names(df))
  expect_false(any(grepl("[\r\n]", names(df))))
})

test_that("co2_vrod rejects an unknown sheet", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(nzchar(Sys.getenv("CARBONDATA_LIVE_TESTS")),
              "Set CARBONDATA_LIVE_TESTS=1 to run live VROD tests.")
  expect_error(co2_vrod(sheet = "NOT_A_SHEET"), "not found")
})
