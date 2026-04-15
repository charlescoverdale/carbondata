test_that("co2_ukets validates type", {
  expect_error(co2_ukets(type = "invalid"))
})

test_that("co2_ukets validates dates", {
  expect_error(co2_ukets(type = "price", from = "not-a-date"))
})

test_that("co2_rggi validates type", {
  expect_error(co2_rggi(type = "invalid"))
})

test_that("co2_california validates type", {
  expect_error(co2_california(type = "invalid"))
})

test_that(".ukets_tidy_price returns expected columns", {
  df <- data.frame(
    Date = "2024-01-15", price = 50.5, volume = 6000,
    stringsAsFactors = FALSE
  )
  out <- .ukets_tidy_price(df)
  expect_named(out, c("date", "price_gbp", "volume_t"))
})

test_that(".rggi_tidy_price returns expected columns", {
  df <- data.frame(
    auction_date = "2024-03-01", auction_number = "63",
    clearing_price = 16, volume = 1000000,
    stringsAsFactors = FALSE
  )
  out <- .rggi_tidy_price(df)
  expect_named(out, c("date", "auction_number", "price_usd", "volume_t"))
})

test_that(".california_tidy_price returns expected columns", {
  df <- data.frame(
    auction_date = "2024-02-21", auction_number = "37",
    settlement_price = 39.5, allowances_sold = 53000000,
    stringsAsFactors = FALSE
  )
  out <- .california_tidy_price(df)
  expect_named(out, c("date", "auction_number", "price_usd", "volume_t"))
})
