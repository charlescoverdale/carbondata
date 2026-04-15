test_that("co2_euets_emissions validates year", {
  expect_error(co2_euets_emissions(year = 1900))
  expect_error(co2_euets_emissions(year = "2020"))
})

test_that("co2_euets_files returns valid data frame", {
  f <- co2_euets_files()
  expect_s3_class(f, "data.frame")
  expect_true(nrow(f) >= 5)
  expect_named(f, c("kind", "file_year", "uuid"))
  expect_true(all(f$kind %in% c("verified_emissions", "compliance")))
})

test_that(".euets_resolve_file_year picks latest by default", {
  expect_true(.euets_resolve_file_year(NULL) >= 2024L)
})

test_that(".euets_resolve_file_year rejects unknown year", {
  expect_error(.euets_resolve_file_year(1900))
})

test_that("co2_euets_emissions live fetch", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(nzchar(Sys.getenv("CARBONDATA_LIVE_TESTS")),
              "Set CARBONDATA_LIVE_TESTS=1 to run live EU ETS tests.")
  df <- co2_euets_emissions(country = "DE")
  expect_s3_class(df, "data.frame")
  expect_true(nrow(df) > 0)
})
