test_that("co2_cache_info shape is correct", {
  op <- options(carbondata.cache_dir = tempfile("co2_test_"))
  on.exit(options(op))
  info <- co2_cache_info()
  expect_named(info, c("dir", "n_files", "size_bytes", "size_human", "files"))
  expect_equal(info$n_files, 0L)
})

test_that("co2_cache_info lists files", {
  tmp <- tempfile("co2_test_")
  op <- options(carbondata.cache_dir = tmp)
  on.exit(options(op))
  dir.create(tmp, recursive = TRUE)
  writeLines("test", file.path(tmp, "test.csv"))
  info <- co2_cache_info()
  expect_equal(info$n_files, 1L)
  expect_true(info$size_bytes > 0)
})

test_that("co2_clear_cache empties the cache", {
  tmp <- tempfile("co2_test_")
  op <- options(carbondata.cache_dir = tmp)
  on.exit(options(op))
  dir.create(tmp, recursive = TRUE)
  writeLines("test", file.path(tmp, "test.csv"))
  co2_clear_cache()
  expect_false(file.exists(file.path(tmp, "test.csv")))
})
