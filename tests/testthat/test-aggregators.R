test_that("co2_icap_prices validates dates", {
  expect_error(co2_icap_prices(from = "not-a-date"))
})

test_that("co2_world_bank validates year", {
  expect_error(co2_world_bank(year = 1800))
  expect_error(co2_world_bank(year = 3000))
})

test_that("co2_world_bank validates instrument", {
  expect_error(co2_world_bank(instrument = "invalid"))
})

test_that("co2_rff_pricing validates year", {
  expect_error(co2_rff_pricing(year = 1800))
})

test_that(".icap_tidy returns expected columns", {
  df <- data.frame(
    date = "2024-03-01", jurisdiction = "EU ETS", price_usd = 65.5,
    currency = "EUR", price_native = 60,
    stringsAsFactors = FALSE
  )
  out <- .icap_tidy(df)
  expect_named(out, c("date", "jurisdiction", "price_usd",
                      "currency_native", "price_native"))
})

test_that(".world_bank_tidy handles mixed column names", {
  df <- data.frame(
    year = 2024L, jurisdiction = "Sweden",
    instrument = "tax", instrument_name = "Swedish Carbon Tax",
    price_usd = 120, coverage = 40, revenue = 2100,
    stringsAsFactors = FALSE
  )
  out <- .world_bank_tidy(df)
  expect_equal(out$jurisdiction, "Sweden")
  expect_equal(out$price_usd_per_tco2e, 120)
})
