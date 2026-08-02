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

test_that("co2_euets_emissions rejects an unknown scheme", {
  expect_error(co2_euets_emissions(scheme = "ets3"))
})

test_that(".euets_filter_scheme separates ETS1 from ETS2", {
  df <- data.frame(
    scheme = c("ets1", "ets1", "ets2"),
    value = c(1, 2, 100),
    stringsAsFactors = FALSE
  )
  expect_equal(nrow(.euets_filter_scheme(df, "ets1")), 2L)
  expect_equal(nrow(.euets_filter_scheme(df, "ets2")), 1L)
  expect_equal(nrow(.euets_filter_scheme(df, "all")), 3L)
})

test_that("co2_euets_emissions live fetch", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(nzchar(Sys.getenv("CARBONDATA_LIVE_TESTS")),
              "Set CARBONDATA_LIVE_TESTS=1 to run live EU ETS tests.")
  df <- co2_euets_emissions(country = "DE")
  expect_s3_class(df, "data.frame")
  expect_true(nrow(df) > 0)
  expect_true(all(c("scheme", "verified_emissions_tco2e", "allocation_eua") %in% names(df)))
  # Default must exclude the ETS2 national accounts, which otherwise
  # roughly double any country-year total from 2024 onwards.
  expect_true(all(df$scheme == "ets1"))
})

test_that("co2_euets_emissions parses every published vintage", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(nzchar(Sys.getenv("CARBONDATA_LIVE_TESTS")),
              "Set CARBONDATA_LIVE_TESTS=1 to run live EU ETS tests.")
  # Vintages differ in sheet name, preamble depth, and allocation column
  # spelling. 2015 emissions should agree across files that report them.
  for (fy in c(2025L, 2021L, 2016L)) {
    df <- co2_euets_emissions(country = "DE", year = 2015L, file_year = fy)
    mt <- sum(df$verified_emissions_tco2e, na.rm = TRUE) / 1e6
    expect_gt(mt, 400, label = paste("file_year", fy))
    expect_lt(mt, 500, label = paste("file_year", fy))
  }
})

test_that("co2_euets_surrendered parses older compliance vintages", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(nzchar(Sys.getenv("CARBONDATA_LIVE_TESTS")),
              "Set CARBONDATA_LIVE_TESTS=1 to run live EU ETS tests.")
  # The 2015 file puts its header below a preamble, which used to yield
  # NA identifiers and therefore zero rows after filtering.
  df <- co2_euets_surrendered(country = "FR", file_year = 2015L)
  expect_gt(nrow(df), 100L)
  expect_true(all(df$country == "FR"))
})

test_that("co2_euets_emissions keeps ETS1 country totals plausible", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(nzchar(Sys.getenv("CARBONDATA_LIVE_TESTS")),
              "Set CARBONDATA_LIVE_TESTS=1 to run live EU ETS tests.")
  df <- co2_euets_emissions(country = "DE", year = 2024L)
  total_mt <- sum(df$verified_emissions_tco2e, na.rm = TRUE) / 1e6
  # German ETS1 emissions have run 250-400 Mt across recent years; the
  # ETS2 leak pushed this above 550 Mt.
  expect_gt(total_mt, 150)
  expect_lt(total_mt, 450)
})
