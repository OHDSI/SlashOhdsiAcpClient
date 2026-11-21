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

test_that("phenotype make-computable validates its client-side request", {
  client <- acp_client(check = FALSE)
  expect_error(acp_phenotype_make_computable(client, ""), "narrative_statement")
  expect_error(acp_phenotype_make_computable(client, "Cirrhosis", candidate_limit = 501), "1 through 500")
  expect_error(acp_phenotype_make_computable(client, "Cirrhosis", concept_review_mode = "automatic"), "concept_review_mode")
})


test_that("phenotype conversion preparation validates its client-side request", {
  client <- acp_client(check = FALSE)
  expect_error(acp_phenotype_conversion_prepare(client, ""), "phenotype_id")
  expect_error(acp_phenotype_conversion_prepare(client, "cipher:1", recommendation_context = "outcome"), "recommendation_context")
  expect_error(acp_phenotype_conversion_prepare(client, "cipher:1", check_vocabulary_database = NA), "check_vocabulary_database")
})

test_that("phenotype conversion preparation forwards unique expected domains", {
  captured <- NULL
  local_mocked_bindings(
    acp_call_flow = function(client, flow_name, body) {
      captured <<- list(flow_name = flow_name, body = body)
      list(status = "ok")
    },
    .package = "slashOhdsiAcpClient"
  )

  acp_phenotype_conversion_prepare(
    acp_client(check = FALSE), "cipher:1",
    expected_domains = c(" Condition ", "Drug", "Condition", "")
  )

  expect_identical(captured$flow_name, "phenotype_conversion_prepare")
  expect_identical(captured$body$expected_domains, list("Condition", "Drug"))
})


test_that("workflow dialogue payload carries bounded context-contract categories", {
  payload <- slashOhdsiAcpClient:::.flatten_workflow_context_dialogue_payload(
    stage_context = list(
      contract_version = 1L,
      workflow_type = "strategus_incidence",
      current_step = "target_selection",
      step_label = "Target cohort",
      user_goal = "Study atomoxetine",
      entities = list(active_role = "target", role_statement = "New users"),
      available_artifacts = list(review_path = "review.csv"),
      dialogue = list(prior_questions = list("Why?"), prior_answers = list("Because.")),
      constraints = list(interactive = TRUE)
    ),
    message = "What should I do next?"
  )

  expect_equal(payload$current_context$context_contract_version, "1")
  expect_equal(payload$current_context$workflow$current_step, "target_selection")
  expect_equal(payload$current_context$artifacts$review_path, "review.csv")
  expect_equal(payload$current_context$dialogue_summary$prior_questions[[1]], "Why?")
  expect_equal(payload$current_context$step_label, "Target cohort")
})
