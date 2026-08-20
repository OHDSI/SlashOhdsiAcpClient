test_that("matching ACP API version is accepted", {
  client <- acp_client(check = FALSE)
  health <- list(status = "ok", api_version = 1, service_version = "0.1.0")

  expect_invisible(acp_check_compatibility(client, health))
})

test_that("missing ACP API version reports a clear error", {
  client <- acp_client(check = FALSE)
  health <- list(status = "ok", service_version = "0.1.0")

  expect_error(acp_check_compatibility(client, health), "does not report an api_version")
})

test_that("incompatible ACP API version reports both requirements", {
  client <- acp_client(check = FALSE)
  health <- list(status = "ok", api_version = 2, service_version = "9.9.9")

  expect_error(
    acp_check_compatibility(client, health),
    "client supports 1 but server reports 2 \\(service version 9.9.9\\)"
  )
})
