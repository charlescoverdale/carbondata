test_that(".icap_match resolves short aliases to official names", {
  available <- c(
    "European Union Emissions Trading System (from 2019) ",
    "Regional Greenhouse Gas Initiative ",
    "Korean Emissions Trading System "
  )
  # ICAP spells names out in full, so "EU ETS" matches nothing without
  # the alias table.
  expect_equal(sum(.icap_match(available, "EU ETS")), 1L)
  expect_equal(sum(.icap_match(available, "RGGI")), 1L)
  expect_equal(sum(.icap_match(available, c("EU ETS", "RGGI"))), 2L)
})

test_that(".icap_match still accepts exact and partial names", {
  available <- c("Korean Emissions Trading System ", "Switzerland Emissions Trading System")
  expect_equal(sum(.icap_match(available, "Korean Emissions Trading System")), 1L)
  expect_equal(sum(.icap_match(available, "Korean")), 1L)
})

test_that(".icap_match errors informatively on an unknown name", {
  available <- c("Regional Greenhouse Gas Initiative ")
  expect_error(.icap_match(available, "Narnia ETS"), "No ICAP jurisdiction matches")
})

test_that("co2_ecp_prices validates level", {
  expect_error(co2_ecp_prices(level = "galaxy"))
})

test_that("co2_icap_prices live fetch drops (download) duplicates", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(nzchar(Sys.getenv("CARBONDATA_LIVE_TESTS")),
              "Set CARBONDATA_LIVE_TESTS=1 to run live ICAP tests.")
  # ICAP publishes a duplicate copy of several systems under a
  # "(download)" suffix, which double-counts them in any chart.
  plain <- co2_icap_prices()
  expect_false(any(grepl("download\\)$", plain$jurisdiction)))
  withdl <- co2_icap_prices(include_download = TRUE)
  expect_gt(length(unique(withdl$jurisdiction)),
            length(unique(plain$jurisdiction)))
})

test_that("co2_world_bank reads a local path without network access", {
  # The dashboard host blocks programmatic clients, so the manual-path
  # route is the supported one and must work offline.
  skip_if_not_installed("writexl")
  f <- tempfile(fileext = ".xlsx")
  writexl::write_xlsx(data.frame(jurisdiction = "UK", price = 18), f)
  df <- co2_world_bank(path = f)
  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), 1L)
})

test_that("co2_world_bank rejects a missing path", {
  expect_error(co2_world_bank(path = tempfile()), "does not exist")
})

test_that("co2_rff_pricing rejects invalid country", {
  expect_error(co2_rff_pricing(c("GBR", "USA")))
  expect_error(co2_rff_pricing())
})

test_that("co2_icap_prices accepts filter", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(nzchar(Sys.getenv("CARBONDATA_LIVE_TESTS")),
              "Set CARBONDATA_LIVE_TESTS=1 to run live ICAP tests.")
  df <- co2_icap_prices(jurisdiction = "EU ETS")
  expect_s3_class(df, "data.frame")
  expect_gt(nrow(df), 0L)
  expect_true(all(grepl("European Union", df$jurisdiction)))
})

test_that("co2_icap_systems lists systems with date ranges", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(nzchar(Sys.getenv("CARBONDATA_LIVE_TESTS")),
              "Set CARBONDATA_LIVE_TESTS=1 to run live ICAP tests.")
  df <- co2_icap_systems()
  expect_s3_class(df, "data.frame")
  expect_true(all(c("jurisdiction", "first_date", "last_date", "n_obs") %in% names(df)))
  expect_gt(nrow(df), 10L)
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

test_that("co2_ecp_prices live fetch", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(nzchar(Sys.getenv("CARBONDATA_LIVE_TESTS")),
              "Set CARBONDATA_LIVE_TESTS=1 to run live ECP tests.")
  df <- co2_ecp_prices(country = "United Kingdom")
  expect_s3_class(df, "data.frame")
  expect_gt(nrow(df), 0L)
})
