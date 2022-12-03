#' Title
#'
#' @param query
#' @param output
#' @param sort
#' @param format
#' @param limit
#' @param verbose
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
req_zotero <- function(query = NULL, output = c("parsed", "raw"), sort = "dateAdded", format = c("json", "keys"), limit = 100, verbose = FALSE, interactive = FALSE, ...) {
  # only for USERS so far!!
  # FIXME: add group

  # query <- match.arg(query, choices = c(
  #   "collections/top", "collections", "items/top", "items", "items/trash",
  #   "publications/items"
  # ))

  params <- list(
    ...,
    sort = match.arg(sort, choices = c(
      "dateAdded", "dateModified", "title", "creator", "itemType", "date",
      "publisher", "publicationTitle", "journalAbbreviation", "language",
      "accessDate", "libraryCatalog", "callNumber", "rights", "addedBy",
      "numItems"
    )),
    format = match.arg(format),
    limit = limit
  )

  output <- base::match.arg(output) # TODO: CHECK!!


  # Make Request ------------------------------------------------------------
  req <- httr2::request("https://api.zotero.org") %>%
    httr2::req_url_path_append("users") %>% # FIXME: or groups
    httr2::req_url_path_append(zoter:::get_api_user()) %>% # FIXME: or group ID
    httr2::req_url_path_append(query) %>%
    httr2::req_user_agent("zoter (https://github.com/kleinlennart/zoter)") %>%
    httr2::req_headers(Authorization = paste("Bearer", zoter:::get_api_key())) %>%
    # req_headers(`If-Modified-Since-Version` = zoter:::get_library_version()) %>% # only use for one specific query!!
    # req_url_query(format = format) %>%
    # req_url_query(sort = "dateAdded") %>%
    httr2::req_url_query(!!!params) %>%
    httr2::req_url_query(v = 3) %>% # https://www.zotero.org/support/dev/web_api/v3/start
    # req_cache(path = "data/cache/", debug = TRUE)
    # httr2::req_error(is_error = zoter::zoter_errors, body = zoter::zoter_error_body) %>%
    httr2::req_url_query(limit = 100) # integer 1-100

  usethis::ui_done("Making first request...")
  resp <- req %>% httr2::req_perform(verbosity = as.integer(verbose))

  # Error Handling ------------------------------------------------------------

  if (!identical(httr2::resp_status(resp), 200L)) {
    if (httr2::resp_is_error(resp)) {
      resp %>% httr2::resp_check_status() # turns HTTPs errors into R errors.
    }
    message(httr2::resp_status_desc(resp))
    # TODO: add nice message for not modified
  }

  usethis::ui_done("Successful!")

  headers <- resp %>% httr2::resp_headers()
  usethis::ui_todo("Total number of items: {usethis::ui_value(headers[['Total-Results']])}")

  n_pages <- as.integer(headers[["Total-Results"]]) / 100 # ceiling?, first page already downloaded!
  estimated_time <- lubridate::dseconds(n_pages * 2.6)
  usethis::ui_todo("Estimated time of full download: {usethis::ui_value(estimated_time)}")

  if (interactive) {
    choice <- utils::menu(c("Yes", "No"), title = "Do you want to proceed?")

    if (identical(choice, 2L)) {
      usethis::ui_info("Only returning first results.")
      res <- zoter::zoter_output(resp, output = output, paginated = FALSE)
      return(res)
    }
  }

  Sys.setenv("ZOTERO_API_libraryVersion" = headers[["Last-Modified-Version"]])

  # Pagination ------------------------------------------------------------

  responses <- vector(mode = "list") # undefined length
  responses[[1]] <- resp
  i <- 2

  usethis::ui_done("Starting pagination...")
  pb <- progress::progress_bar$new(
    format = "  Downloading [:bar] :percent in :elapsed",
    clear = FALSE, width = 75, total = n_pages - 1 # remaining pages
  )

  while (!is.null(httr2::resp_link_url(resp, "next"))) {
    pb$tick() # advance progress bar
    next_url <- resp %>% httr2::resp_link_url("next")

    if (verbose) {
      cat("\n", i, "Requesting: ", next_url)
    }

    resp <- httr2::request(next_url) %>% # next_url carries over all other params
      httr2::req_headers(Authorization = paste("Bearer", zoter:::get_api_key())) %>%
      httr2::req_perform()
    responses[[i]] <- resp


    i <- i + 1
  }

  # Transforming ------------------------------------------------------------
  # FIXME: outsource to seperate function

  # are there any errors?
  pagination_errors <- responses %>%
    purrr::map_lgl(httr2::resp_is_error) %>%
    any()

  if (pagination_errors) {
    return(responses)
    stop("There war an error in one of the responses. Returning unfinished results.")
  }

  # status <- responses %>% map_int(resp_status)
  # responses %>% map_chr(resp_content_type)

  ## Export
  res <- zoter::zoter_output(resp = responses, output = output, paginated = TRUE)
  usethis::ui_done("Done!")
  return(res)
}
