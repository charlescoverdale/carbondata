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
