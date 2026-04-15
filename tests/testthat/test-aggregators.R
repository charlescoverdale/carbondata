test_that("co2_icap_prices accepts filter", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(nzchar(Sys.getenv("CARBONDATA_LIVE_TESTS")),
              "Set CARBONDATA_LIVE_TESTS=1 to run live ICAP tests.")
  df <- co2_icap_prices(jurisdiction = "EU ETS")
  expect_s3_class(df, "data.frame")
})

test_that("co2_rff_pricing rejects invalid country", {
  expect_error(co2_rff_pricing(c("GBR", "USA")))
  expect_error(co2_rff_pricing())
})

test_that("co2_rff_pricing live fetch", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(nzchar(Sys.getenv("CARBONDATA_LIVE_TESTS")),
              "Set CARBONDATA_LIVE_TESTS=1 to run live RFF tests.")
  df <- co2_rff_pricing("United_Kingdom")
  expect_s3_class(df, "data.frame")
  expect_true(nrow(df) > 0)
})
