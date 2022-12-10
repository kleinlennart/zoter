#' Title
#'
#' @param dat
#'
#' @return
#' @export
#'
#' @examples
clean_zotero <- function(dat) {
  usethis::ui_done("Cleaning...")
  dat <- dat %>% purrr::set_names(stringr::str_remove_all(names(.), "^data."))

  # select(-starts_with("library."), -starts_with("links."))

  return(dat)
}


# TODO: parser function
