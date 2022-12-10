# FIXME: add check for API write access!
# link to setup function


#
#' Title
#'
#' @param item_key
#' @param item_version
#'
#' @return
#' @export
#'
#' @examples
write_tag <- function(item_key, item_version) {
  # FIXME: item_version could also be library version...
  usethis::ui_done("Making modify request...")

  req <- httr2::request("https://api.zotero.org") %>%
    httr2::req_url_path_append("users") %>% # FIXME: or groups
    httr2::req_url_path_append(zoter:::get_api_user()) %>% # FIXME: or group ID
    httr2::req_url_path_append("items") %>%
    httr2::req_url_path_append(item_key) %>% # item to modify
    httr2::req_headers(Authorization = paste("Bearer", zoter:::get_api_key())) %>%
    httr2::req_user_agent("zoter (https://github.com/kleinlennart/zoter)") %>%
    httr2::req_headers(`If-Unmodified-Since-Version` = item_version) %>%
    # httr2::req_url_query(!!!params) %>%
    httr2::req_headers(`Zotero-API-Version` = 3) %>%
    httr2::req_body_json(data = list(tags = list(list(tag = "imported_PDF")))) %>% # tags needs to be formatted this way!
    httr2::req_error(is_error = zoter:::zoter_errors) %>%
    httr2::req_method("PATCH")


  resp <- req %>% httr2::req_perform()

  # resp %>% zoter:::set_library_version()

  # last_response() or last_request()
  if (identical(httr2::resp_status(resp), 412L)) {
    usethis::ui_info("Synching before writing...")

    # format "versions" only works for multi-items!
    updates <- zoter::req_zotero(query = paste0("items/", item_key), output = "parsed", paginate = FALSE)
    new_version <- updates[["data"]][["version"]]

    zoter::write_tags(item_key = item_key, item_version = new_version)

    # return(updates)
  }



  # Error Handling ------------------------------------------------------------

  # if (!identical(httr2::resp_status(resp), 200L)) {
  #   if (httr2::resp_is_error(resp)) {
  #     resp %>% httr2::resp_check_status() # turns HTTPs errors into R errors.
  #   }
  #   message(httr2::resp_status_desc(resp))
  #   # TODO: add nice message for not modified
  # }

  usethis::ui_done("Successful!")

  return()
}


# Multi -------------------------------------------------------------------

#
#' Title
#'
#' @param item_key
#' @param item_version
#'
#' @return
#' @export
#'
#' @examples
write_tags <- function(data, lib_version = NULL) {
  # FIXME: item_version could also be library version...
  usethis::ui_done("Making modify request...")

  req <- httr2::request("https://api.zotero.org") %>%
    httr2::req_url_path_append("users") %>% # FIXME: or groups
    httr2::req_url_path_append(zoter:::get_api_user()) %>% # FIXME: or group ID
    httr2::req_url_path_append("items") %>%
    httr2::req_headers(Authorization = paste("Bearer", zoter:::get_api_key())) %>%
    httr2::req_user_agent("zoter (https://github.com/kleinlennart/zoter)") %>%
    httr2::req_headers(`If-Unmodified-Since-Version` = zoter:::get_new_library_version()) %>%
    # httr2::req_url_query(!!!params) %>%
    httr2::req_headers(`Zotero-API-Version` = 3) %>%
    httr2::req_body_json(data = data) %>% # tags needs to be formatted this way!
    # httr2::req_error(is_error = zoter:::zoter_errors) %>%
    httr2::req_method("POST")


  resp <- req %>% httr2::req_perform()

  # resp %>% zoter:::set_library_version()

  # last_response() or last_request()
  # if (identical(httr2::resp_status(resp), 412L)) {
  #   usethis::ui_info("Synching before writing...")
  #
  #   # format "versions" only works for multi-items!
  #   updates <- zoter::req_zotero(query = paste0("items/", item_key), output = "parsed", paginate = FALSE)
  #   new_version <- updates[["data"]][["version"]]
  #
  #   zoter::write_tags(item_key = item_key, item_version = new_version)
  #
  #   # return(updates)
  # }



  # Error Handling ------------------------------------------------------------

  # if (!identical(httr2::resp_status(resp), 200L)) {
  #   if (httr2::resp_is_error(resp)) {
  #     resp %>% httr2::resp_check_status() # turns HTTPs errors into R errors.
  #   }
  #   message(httr2::resp_status_desc(resp))
  #   # TODO: add nice message for not modified
  # }

  usethis::ui_done("Successful!")

  return(resp)
}
