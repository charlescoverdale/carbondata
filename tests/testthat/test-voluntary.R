test_that("co2_offsets_db validates endpoint", {
  expect_error(co2_offsets_db(endpoint = "invalid"))
})

test_that("co2_offsets_db validates limit", {
  expect_error(co2_offsets_db(limit = 0))
  expect_error(co2_offsets_db(limit = "100"))
})

test_that(".vrod_tidy returns expected columns", {
  df <- data.frame(
    project_id = "VCS001", registry = "Verra",
    project_name = "Forest Project", country = "Brazil",
    project_type = "Forestry",
    methodology = "VM0015",
    total_issuances = 500000, total_retirements = 100000,
    stringsAsFactors = FALSE
  )
  out <- .vrod_tidy(df)
  expect_named(out, c("project_id", "registry", "project_name",
                      "country", "project_type", "methodology",
                      "total_issuances", "total_retirements",
                      "first_issuance_date"))
  expect_equal(out$total_issuances, 500000)
})
