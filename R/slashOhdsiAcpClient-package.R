#' slashOhdsiAcpClient: an R client for the StudyAgent ACP bridge
#'
#' Create an explicit client with \code{acp_client()} and pass it to the flow and
#' action wrappers. This is the preferred interface for reusable scripts and
#' packages. \code{acp_connect()} stores a default client for compatibility
#' helpers such as \code{suggestPhenotypes()}.
#'
#' @section Configuration:
#' Use \env{ACP_URL} to select the bridge URL in calling code and
#' \env{ACP_TIMEOUT} to set the HTTP timeout in seconds. Supply ACP bearer
#' tokens through a caller-managed environment variable such as \env{ACP_TOKEN};
#' do not store tokens in source files.
#'
#' @section Compatibility:
#' \code{acp_client()} checks the bridge health endpoint and ACP API compatibility by
#' default. The supported protocol versions are an internal package contract.
#'
#' @keywords internal
"_PACKAGE"
