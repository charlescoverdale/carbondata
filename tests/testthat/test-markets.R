test_that("co2_markets returns a data.frame", {
  m <- co2_markets()
  expect_s3_class(m, "data.frame")
  expect_true(nrow(m) >= 9)
  expect_named(m, c("market", "name", "type", "coverage_start",
                    "jurisdiction", "function_name", "notes"))
})

test_that("co2_markets filters by type", {
  compliance <- co2_markets(type = "compliance")
  expect_true(all(compliance$type == "compliance"))

  voluntary <- co2_markets(type = "voluntary")
  expect_true(all(voluntary$type == "voluntary"))
})

test_that("co2_markets rejects invalid type", {
  expect_error(co2_markets(type = "invalid"))
})

test_that("every listed function exists as export", {
  m <- co2_markets()
  all_fns <- unique(unlist(strsplit(m$function_name, ",\\s*")))
  for (fn in all_fns) {
    expect_true(exists(fn, mode = "function"),
                info = paste("Missing function:", fn))
  }
})
