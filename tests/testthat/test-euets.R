test_that("co2_euets_emissions validates year", {
  expect_error(co2_euets_emissions(year = 1900))
  expect_error(co2_euets_emissions(year = "2020"))
})

test_that(".euets_urls has all expected datasets", {
  expected <- c("verified_emissions", "allocations", "surrendered",
                "installations", "prices")
  expect_true(all(expected %in% names(.euets_urls)))
})

test_that(".euets_pick finds columns flexibly", {
  df <- data.frame(Country = "DE", Year = 2020, verified_emissions = 100)
  expect_equal(as.character(.euets_pick(df, c("country"))), "DE")
  expect_equal(as.integer(.euets_pick(df, c("year"))), 2020L)
  expect_equal(as.numeric(.euets_pick(df, c("verified_emissions"))), 100)
})

test_that(".euets_pick returns default when nothing matches", {
  df <- data.frame(a = 1)
  expect_equal(.euets_pick(df, c("nonexistent"), default = "X"), rep("X", 1))
})

test_that(".euets_tidy_emissions returns expected columns", {
  df <- data.frame(
    country = "DE", year = 2020, installation_id = "DE001",
    installation_name = "Test", activity = "Combustion",
    verified_emissions = 1000,
    stringsAsFactors = FALSE
  )
  out <- .euets_tidy_emissions(df)
  expect_named(out, c("country", "year", "installation_id",
                      "installation_name", "activity",
                      "verified_emissions_tco2e"))
  expect_equal(out$verified_emissions_tco2e, 1000)
})

test_that("co2_euets_emissions live fetch", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(nzchar(Sys.getenv("CARBONDATA_LIVE_TESTS")),
              "Set CARBONDATA_LIVE_TESTS=1 to run live EU ETS tests.")
  df <- co2_euets_emissions(country = "DE", year = 2022)
  expect_s3_class(df, "data.frame")
})
