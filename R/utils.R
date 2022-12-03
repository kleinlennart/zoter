#
zoter_output <- function(resp = NULL, output = c("parsed", "raw"), paginated = NULL) {
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
      # add messages
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

get_library_version <- function() {
  library_version <- Sys.getenv("ZOTERO_API_libraryVersion")
  if (identical(library_version, "")) {
    # stop("No ZOTERO_API_libraryVersion found, please supply with `api_key` argument or with NYTIMES_KEY env var")
    return(NULL)
  }
  return(library_version)
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
  # TODO
}
