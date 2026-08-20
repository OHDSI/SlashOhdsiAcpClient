# Coding guidance for slashOhdsiAcpClient

## Project purpose

This is a small R package that calls the OHDSI StudyAgent ACP bridge. Keep its
public API thin, explicit, and transport-focused.

- Use the explicit client API for new code: construct with `acp_client()` and
  pass `client` to exported flow/action wrappers.
- `R/compatibility_api.R` provides the default-client and legacy convenience
  layer. Preserve its behavior unless a change explicitly targets that layer.
  In particular, some high-level helpers intentionally return
  `source = "stub_no_acp"` when ACP has not been connected.
- ACP version compatibility is an executable internal contract:
  `.acp_supported_api_versions`. Update it and its tests together when
  supporting a new bridge API version.
- Do not add secrets to source, tests, README examples, or logs. Read bearer
  tokens from the caller or environment.

## Local R environment

The project may contain linked `.Rprofile` and `renv/` entries. The linked
library is shared and should be treated as read-only for package development.

Use the linked library for dependency resolution, but install this package into
a separate temporary library:

```sh
mkdir -p /tmp/slashOhdsiAcpClient-smoke-lib
R_PROFILE_USER=/dev/null R_ENVIRON_USER=/dev/null \
  R_LIBS_USER="$PWD/renv/library/linux-ubuntu-noble/R-4.5/x86_64-pc-linux-gnu" \
  R CMD INSTALL --library=/tmp/slashOhdsiAcpClient-smoke-lib .
```

Do not run `renv::restore()`, `renv::install()`, or install this package into
the linked renv library unless the user specifically authorizes it.

## Required validation after code changes

1. Reinstall into the isolated temporary library.
2. Run package-aware source tests, which load the development package:

   ```sh
   R_PROFILE_USER=/dev/null R_ENVIRON_USER=/dev/null \
     R_LIBS="/tmp/slashOhdsiAcpClient-smoke-lib:$PWD/renv/library/linux-ubuntu-noble/R-4.5/x86_64-pc-linux-gnu" \
     Rscript --vanilla -e 'testthat::test_local(".", reporter = "summary")'
   ```

   Do not use `testthat::test_check()` for this source-tree test run:
   installed R packages do not retain their `tests/` directory.

3. For changes to connection, health, compatibility, or HTTP transport, run the
   local smoke test only when a StudyAgent ACP bridge is available:

   ```sh
   R_PROFILE_USER=/dev/null R_ENVIRON_USER=/dev/null \
     R_LIBS="/tmp/slashOhdsiAcpClient-smoke-lib:$PWD/renv/library/linux-ubuntu-noble/R-4.5/x86_64-pc-linux-gnu" \
     Rscript --vanilla -e 'library(slashOhdsiAcpClient); acp_connect(); print(acp_server_info(acp_get_default_client()))'
   ```

   The standard local endpoint is `http://127.0.0.1:8765`; the service must
   report healthy status and supported ACP API version.

4. For package metadata, namespace, dependency, or build-file changes, build
   and check a source tarball in `/tmp`. Do not run `R CMD check .` directly:
   it sees the linked renv tree and local editor artifacts as package contents.
   `.Rbuildignore` controls what the source tarball excludes.

   Current known package-check follow-up work includes documenting all exported
   functions and supplying the `LICENSE` file referenced by `DESCRIPTION`.

## Documentation and tests

- Add a focused `testthat` regression test for each bug fix, especially API
  compatibility and error-message behavior.
- Keep README examples executable in principle, use `ACP_URL`, `ACP_TOKEN`,
  and `ACP_TIMEOUT`, and never hard-code credentials.
- Run `git diff --check` on changed files before handoff.
