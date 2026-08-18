# slashOhdsiAcpClient

This package is the low-level ACP client for [OHDSI Study
Agent](https://github.com/OHDSI/StudyAgent/) agent harness and suite
of AI-assisted real-world evidence generation services.

This R project provides functions for:

- ACP client construction
- HTTP transport and timeout handling
- flow and action wrappers

It does not own Strategus shells, checkpointing, or workflow-stage decisions.

## ACP Compatibility

The client requires ACP API version 1 from the Study Agent
project. `acp_client(check = TRUE)` checks `/health` and validates the
server api_version before returning a client. The ACP server also
reports `service_version`, which makes a site mismatch actionable
without coupling this R package to the Study Agent source checkout.


