test_that("co2_ukets_allocations validates sector", {
  expect_error(co2_ukets_allocations(sector = "invalid"))
})

test_that("co2_rggi_allowances validates year", {
  expect_error(co2_rggi_allowances(year = 1900))
  expect_error(co2_rggi_allowances(year = c(2020, 2021)))
})

test_that("co2_rggi_state_proceeds validates state", {
  expect_error(co2_rggi_state_proceeds("XX"))
  expect_error(co2_rggi_state_proceeds(c("NY", "MA")))
})

test_that("co2_rggi_state_proceeds accepts lowercase state", {
  # Only URL construction; we don't actually fetch
  # Test just that uppercase normalisation doesn't error
  # The download itself is gated on live flag
  skip_on_cran()
  skip_if_offline()
  skip_if_not(nzchar(Sys.getenv("CARBONDATA_LIVE_TESTS")),
              "Set CARBONDATA_LIVE_TESTS=1 to run live RGGI tests.")
  df <- co2_rggi_state_proceeds("ny")
  expect_s3_class(df, "data.frame")
})
