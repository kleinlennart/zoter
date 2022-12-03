
<!-- README.md is generated from README.Rmd. Please edit that file -->

# zoter

<!-- badges: start -->
<!-- badges: end -->

## Installation

You can install the development version of **{zoter}** like so:

``` r
# install.packages("devtools")
devtools::install_github("kleinlennart/zoter")
```

## API Example

To access your own private library you will need your userID (not your
username!) and an API Key. You can find them here:
[https://www.zotero.org/settings/keys](https://www.zotero.org/settings/keys/new)

``` r
library(zoter)

## Will ask you for your userID and API Key
set_zotero_creds()

## Alternatively you can also set them directly with:
Sys.setenv("ZOTERO_API_USER" = "XXXXX")
Sys.setenv("ZOTERO_API_KEY" = "XXXXX")

## Download and parse infos for all top-level items in your library (not notes or attachments)
items <- get_all_items_top()

## Download and parse infos for all collections in your library
colls <- get_all_collections()


## Use 'req_zotero' for more specific queries
trash_keys <- req_zotero(query = "items/trash", output = "raw", format = "keys")
```

## Cleaning

## Analysis

``` r
# Plots
```
