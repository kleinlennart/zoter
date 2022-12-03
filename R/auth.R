# Authentication --------------------------------------------------------

#' Authentication Setup
#'
#' @return
#' @export
#'
#' @examples
set_zotero_creds <- function() {
  if (!rlang::is_interactive()) {
    stop("`set_zotero_creds()` only works in interactive sessions.")
  }

  choice <- utils::menu(c("Yes", "No"), title = "Do you already have your private UserID and API key?")
  if (identical(choice, 2L)) { # if No
    usethis::ui_todo("Then get a new private key here: https://www.zotero.org/settings/keys")
    Sys.sleep(1)
    utils::browseURL("https://www.zotero.org/settings/keys")
    Sys.sleep(1)

    if (!usethis::ui_yeah("Would you like to continue with the setup?")) {
      usethis::ui_oops("Setup aborted...")
      rlang::interrupt()
    }
  }

  user_id <- askpass::askpass("Please enter your Zotero userID.")
  Sys.setenv("ZOTERO_API_USER" = user_id)

  key <- askpass::askpass("Please enter your Zotero API key.")
  Sys.setenv("ZOTERO_API_KEY" = key)

  usethis::ui_done("Setup successful!")
}

# OAuth -------------------------------------------------------------------

# TODO: OAuth
# client <- httr2::oauth_client(
#   id = "b3dc85da41c41d57f373",
#   secret = httr2::obfuscated("Yaz29NgkKXeCbdFWOYCo3c7h07nFcqqBAXK3LCD3-zQpZ7vW"),
#   token_url = "https://www.zotero.org/oauth/access",
#   name = "zoter-oauth-test"
# )


# API Helper --------------------------------------------------------------

#' Title
#' @return
#' @NoRd
get_api_user <- function() {
  user_id <- Sys.getenv("ZOTERO_API_USER")
  if (identical(user_id, "")) {
    stop("No API userID found. Use set_zotero_creds.")
  }
  return(user_id)
}

#' Title
#' @return
#' @NoRd
get_api_key <- function() {
  key <- Sys.getenv("ZOTERO_API_KEY")
  if (identical(key, "")) {
    stop("No API key found. Use set_zotero_creds.")
  }
  return(key)
}
