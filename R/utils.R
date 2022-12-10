#' Title
#' @return
#' @NoRd
zoter_export <- function(resp, output = c("parsed", "raw"), paginated = FALSE) {
  output <- match.arg(output)

  if (paginated) {
    if (identical(output, "raw")) {
      return(resp) # all responses
    } else if (identical(output, "parsed")) {
      parsed <- resp %>%
        purrr::map(httr2::resp_body_json, simplifyVector = TRUE, simplifyDataFrame = TRUE, flatten = TRUE) %>%
        purrr::map(dplyr::bind_rows) %>%
        plyr::rbind.fill()
      # TODO: as_tibble() ??

      return(parsed)
    } else {
      stop("Output format not valid.") # FIXME: run checks on input earlier
    }
  } # not paginated
  else {
    if (identical(output, "raw")) {
      usethis::ui_done("Returning raw API response.")
      return(resp) # single resp
    } else if (identical(output, "parsed")) {
      parsed <- resp %>% httr2::resp_body_json(simplifyVector = TRUE, simplifyDataFrame = TRUE, flatten = TRUE)
      # TODO: as_tibble() ??

      return(parsed)
    }
    # TODO: add S3 class?
  }
}


# Helper ------------------------------------------------------------------

#' Title
#' @return
#' @NoRd
get_library_version <- function() {
  # FIXME: set initially with small API call
  # FIXME: clients should treat it as an opaque integer value



  library_version <- Sys.getenv("ZOTERO_API_libraryVersion")
  if (identical(library_version, "")) {
    stop("No ZOTERO_API_libraryVersion found, please supply with `api_key` argument or with NYTIMES_KEY env var")
    return(NULL)
  }
  return(library_version)
}

#' Title
#' @return
#' @NoRd
get_new_library_version <- function() {
  usethis::ui_info("Getting newest library version...")

  req <- httr2::request("https://api.zotero.org") %>%
    httr2::req_url_path_append("users") %>%
    httr2::req_url_path_append(zoter:::get_api_user()) %>%
    httr2::req_url_path_append("items") %>%
    httr2::req_headers(Authorization = paste("Bearer", zoter:::get_api_key())) %>%
    httr2::req_headers(`Zotero-API-Version` = 3) %>%
    # httr2::req_headers(Accept = "application/json") %>%
    httr2::req_url_query(format = "versions") %>%
    httr2::req_url_query(limit = 1) %>%
    httr2::req_user_agent("zoter (https://github.com/kleinlennart/zoter)")
  # httr2::req_cache(path = "notes/cache", debug = TRUE)


  resp <- req %>% httr2::req_perform(verbosity = 0)
  version <- resp %>% zoter:::set_library_version()
  return(version)
}




#' Title
#' @return
#' @NoRd
set_library_version <- function(resp) {
  # NOTE: Last-Modified-Version response header indicates the current version
  # of either a library (for multi-object requests) or an individual object (for single-object requests).

  # FIXME: clients should treat it as an opaque integer value
  version <- resp %>% httr2::resp_header("Last-Modified-Version")

  Sys.setenv("ZOTERO_API_libraryVersion" = version)
  return(version)
}


# request needs to fail for it to run!
zoter_error_body <- function(resp) {
  # body <- resp_body_json(resp)
  status <- httr2::resp_status(resp) # integer with L

  if (identical(status, 304L)) {
    message <- "No changes to the library since last request!"
  }

  return(message)
}

# request needs to fail for it to run!
zoter_errors <- function(resp) {
  return(FALSE)
}
