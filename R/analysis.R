# library(tidyverse)
# library(httr2)
#
# source("R/utils.R")
#
#
# dat <- readRDS("~/Documents/Coding/Tidytuesday/Zotero/data/parsed_top_2022-12-02.rds")
# dat <- dat %>% as_tibble()
#
#
#
# res <- resp %>% map(resp_body_json, simplifyVector = TRUE, simplifyDataFrame = TRUE, flatten = TRUE) %>%
#
#   res <- resp %>% resp_body_json(simplifyVector = TRUE, simplifyDataFrame = TRUE, flatten = TRUE)
#
# # Cleaning ----------------------------------------------------------------
#
# # Change names
# dat <- dat %>% select(-data.key, data_version = data.version)
# dat <- dat %>% set_names(str_remove_all(names(.), "^data\\."))
#
# dat <- dat %>% mutate(
#   dateAdded = dateAdded %>% lubridate::ymd_hms(tz = "UTC", locale = "en_US.UTF-8"),
#   dateAdded_DE = dateAdded %>% lubridate::with_tz(tzone = "Europe/Berlin"),
# )
#
# dat <- dat %>% mutate(
#   date_added = dateAdded_DE %>% as.Date()
# )
#
#
# ## Get tags
#
# tagged <- dat %>% select(key, tags, date_added)
#
# tagged <- tagged %>%
#   mutate(
#     n_tags = tags %>% map_int(length),
#     all_tags = tags %>% map("tag")
#   ) %>%
#   arrange(desc(n_tags))
#
# tagged %>%
#   count()
#
#
#
# # data frame with one variable "tag" and rows for all tags
# # test[[2]][[128]]
#
#
# # Collections -------------------------------------------------------------
#
# colls <- get_all_collections()
# colls <- colls %>% select(key, collection_name = data.name)
#
# col_data <- dat %>%
#   group_by(date_added) %>%
#   nest() %>%
#   arrange(date_added) %>%
#   mutate(
#     n = data %>% map_int(nrow),
#     all_collections = data %>% map(~ .$collections %>%
#                                      unlist() %>%
#                                      c())
#   )
#
# col_data <- col_data %>%
#   mutate(
#     n_items = data %>% map_int(nrow),
#     n_collections = all_collections %>% map_int(n_distinct),
#     n_top_collection = all_collections %>% map_int(~ sort(table(.x), decreasing = TRUE)[1]),
#     top_collection = all_collections %>% map_chr(~ if_else(is.null(.x), NA_character_, names(sort(table(.x), decreasing = TRUE)[1])))
#   )
#
#
# col_data <- col_data %>%
#   left_join(colls, by = c("top_collection" = "key"))
#
# col_data <- col_data %>%
#   mutate(collection_label = case_when(
#     n_top_collection >= 10 ~ collection_name,
#     n_top_collection < 10 ~ NA_character_
#   ) %>% replace_na(""))
#
#
# # Plots -------------------------------------------------------------------
#
# library(ggrepel)
#
# # NOTE: Set labels to the empty string "" to hide them.
# col_data %>%
#   ggplot(aes(x = date_added, y = cumsum(n), label = collection_label)) +
#   geom_point() +
#   geom_area(alpha = 0.3) +
#   geom_label_repel(box.padding = 0.5, max.overlaps = Inf)
# # geom_text_repel()
# # theme_classic(base_size = 16)
#
#
#
#
#
#
# #######
# zotero_ts <- dat %>%
#   count(date_added) %>%
#   arrange(date_added)
#
# zotero_ts %>%
#   ggplot(aes(x = date_added, y = cumsum(n))) +
#   geom_area()
#
#
#
#
#
#
# # Notes -------------------------------------------------------------------
#
#
#
#
# parsed <- get_all_items()
# parsed$data.dateAdded %>% max()
#
#
# parsed %>%
#   select(data.dateAdded) %>%
#   View()
#
# parsed$key %>%
#   duplicated() %>%
#   sum()
#
#
# # TODO: Extract citationkey from Extra field
# # Citation Key: cohen1960CoefficientAgreement
#
#
# # data.tags, unnest
#
# # data.linkMode
# # data.path
