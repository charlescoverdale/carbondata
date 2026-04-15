test_that("co2_offsets_db validates kind", {
  expect_error(co2_offsets_db(kind = "invalid"))
})

test_that("co2_offsets_db validates date", {
  expect_error(co2_offsets_db(date = "not-a-date"))
})

test_that("co2_cad_trust always errors with guidance", {
  expect_error(co2_cad_trust(), "v0\\.1\\.0")
})
