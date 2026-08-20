# slashOhdsiAcpClient

## Introduction

This package is the low-level ACP client for the [OHDSI Study
Agent](https://github.com/OHDSI/StudyAgent/) agent harness and suite
of AI-assisted real-world evidence generation services.

## Features

This functions for:

- ACP client construction
- HTTP transport and timeout handling
- flow and action wrappers

## Examples

This package can provide AI services to the Strategus specification and
execution shells in the [slashOhdsiStrategusAssistant](http://github.com/OHDSI/slashOhdsiStrategusAssistant)
project. The examples below assume a running StudyAgent ACP bridge.

### Configure and connect

Set the bridge URL and a request timeout appropriate for the workflow. Do not
put a bearer token in source code; set `ACP_TOKEN` in the execution environment
when the bridge requires authentication.

```r
library(slashOhdsiAcpClient)

acp_url <- Sys.getenv("ACP_URL", "http://127.0.0.1:8765")
Sys.setenv(ACP_TIMEOUT = "1800", ACP_URL = acp_url)

acp_token <- Sys.getenv("ACP_TOKEN", unset = "")
client <- acp_client(
  url = acp_url,
  token = if (nzchar(acp_token)) acp_token else NULL,
  check = TRUE
)

# A successful client construction has already checked /health and ACP API
# compatibility. Inspect the service metadata when useful for diagnostics.
acp_server_info(client)
```

`ACP_TIMEOUT` is expressed in seconds and defaults to 180 when it is not set.

### Request phenotype recommendations

Pass a clear study intent and inspect the returned ACP payload. The response is
kept as a list because the available recommendation fields can evolve with the
ACP service.

```r
recommendations <- acp_suggest_phenotypes(
  client = client,
  study_intent = paste(
    "Estimate the comparative effectiveness of first-line treatments for",
    "adults with type 2 diabetes, using time to hospitalization as an outcome."
  ),
  top_k = 20,
  max_results = 3,
  candidate_limit = 10
)
str(recommendations, max.level = 2)
```

### Use the default-client helper

For interactive or legacy scripts, `acp_connect()` stores a checked client for
the higher-level compatibility functions such as `suggestPhenotypes()`.

```r
acp_connect(
  url = acp_url,
  token = if (nzchar(acp_token)) acp_token else NULL
)

suggestions <- suggestPhenotypes(
  studyIntent = "Identify suitable cohorts for a new-user study of statins.",
  interactive = FALSE
)
```

### Review local phenotype artifacts

Flows that accept local artifacts read the files and send their contents to the
bridge. Supply paths to an existing protocol and one or more OHDSI cohort JSON
definitions.

```r
review <- acp_review_phenotypes(
  client = client,
  protocol_path = "<path to repo>/extras/protocol.md",
  cohort_paths = c("<path to repo>/extras/1197_Acute_gastrointestinal_bleeding.json")
)
str(review, max.level = 2)
```

## System Requirements

The package is written in R and has been tested with R  4.4 and 4.5

The client requires ACP API version 1 from the [OHDSI Study
Agent](https://github.com/OHDSI/StudyAgent/) agent harness. `acp_client(check = TRUE)` checks `/health` and validates the
server api_version before returning a client. The ACP server also
reports `service_version`, which makes a site mismatch actionable
without coupling this R package to the Study Agent source checkout.


## Getting Started

Install the package and load the library:

```r
# install.packages("devtools")
devtools::install_github("ohdsi/slashOhdsiAcpClient")
library(slashOhdsiAcpClient)
```

(Advanced) If you are manually updating to a newer version rather than the recommend standard  renv approach: 
```
package_name <- "slashOhdsiAcpClient"
library_loc <- ""  # fill in the location
if (paste0("package:", package_name) %in% search()) {
  detach(paste0("package:", package_name), unload = TRUE, character.only = TRUE)
}

if (package_name %in% loadedNamespaces()) {
  unloadNamespace(package_name)
}

if (dir.exists(file.path(library_loc, package_name))) {
  remove.packages(package_name, lib = library_loc)
}
```

See example usage above. 

## User Documentation

## Contributing

Read the [HADES contribution guide](https://ohdsi.github.io/Hades/contribute.html) to
learn how to contribute to this package.

## Development

This project is developed in R using OpenAI Codex, Emacs, and [agent-shell](https://github.com/xenodium/agent-shell). RStudio
may be the preferred IDE for many contributors.

**Development status:** Beta; use at your own risk.
