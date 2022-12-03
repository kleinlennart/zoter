# FIXME: get all functions on one man page!


# Items -------------------------------------------------------------------

#' Title
#'
#' @param output
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
get_all_items <- function(output = c("parsed", "raw"), ...) {
  res <- zoter::req_zotero(query = "items", output, ...)
  return(res)
}

#' Title
#'
#' @param output
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
get_all_items_top <- function(output = c("parsed", "raw"), ...) {
  res <- zoter::req_zotero(query = "items/top", output, ...)
  return(res)
}



# Collections -------------------------------------------------------------

#' Title
#'
#' @param output
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
get_all_collections <- function(output = c("parsed", "raw"), ...) {
  res <- zoter::req_zotero(query = "collections", output, ...)
  return(res)
}

#' Title
#'
#' @param output
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
get_all_collections_top <- function(output = c("parsed", "raw"), ...) {
  res <- zoter::req_zotero(query = "collections/top", output, ...)
  return(res)
}
