#' ## Get Open APC compliant metadata
#' 
#' Required libraries
library(dplyr)
library(plyr)
library(httr)
library(europepmc)
#' Load Excel spreadsheet, which has be prepared in accordance with the Open APC initiatives
#' submission handout: <https://github.com/OpenAPC/openapc-de/wiki/Data-Submission-Handout>
#' 
apc_fetch <- function(x) {
  my_df <- x %>%
    # spreadsheets are often created manually with copy & paste techniques, so trailing white space
    # may occur
    mutate(doi = trimws(doi)) %>%
    # dois are case-insensitive https://www.doi.org/doi_handbook/2_Numbering.html#2.4
    mutate(doi = tolower(doi))
  #' ### Fetch metadata from Crossref
  source("cr_parse.R")
  cr_df <- plyr::ldply(my_df$doi, plyr::failwith(f = cr_parse)) %>%
    mutate(doi = tolower(doi)) %>%
    left_join(select(my_df, one_of(c("doi", "euro", "institution", "period", "is_hybrid", "url"))), by = "doi") %>%
    # Sometimes there are duplicated DOIs because spreadsheets are curated manually, 
    # so remove duplicated matches after join
    distinct()
  #' Combine crossref md with data with no crossref match
  cr_apc <- bind_rows(cr_df, filter(my_df, !doi %in% cr_df$doi))
  #' indicate which records we have found in crossref
  cr_apc$indexed_in_crossref <- cr_apc$doi %in% cr_df$doi
  
  #' Get formatted citation via DOI Content Negotiation http://citation.crosscite.org/docs.html
  refs <- rcrossref::cr_cn(dois = cr_apc$doi, "text", "elsevier-harvard")
  cr_apc <- mutate(cr_apc, styled_citation = unlist(sapply(refs, function(x) ifelse(is.null(x), NA, x))))
  #' ### Check indexing coverage in Europe PMC by DOI
  #' 
  cr_epmc_df <- plyr::ldply(cr_apc$doi, plyr::failwith(f = function(x) europepmc::epmc_search(paste0("DOI:", x)))) %>%
    select(doi, pmid, pmcid) %>%
    mutate(doi, doi = tolower(doi)) %>%
    left_join(cr_apc, ., by = "doi") %>%
    # Sometimes there are duplicated DOIs because spreadsheets are curated manually, 
    # so remove duplicated matches after join
    distinct()
  #' ### DOAJ check
  #'
  #' Load most recent DOAJ list
  doaj <- httr::GET("http://doaj.org/csv") %>%
    httr::content()
  #' get vector of issns that will be matched with our apc dataset
  doaj_issns <-c(doaj$`Journal ISSN (print version)`, doaj$`Journal EISSN (online version)`) %>%
    as_data_frame() %>%
    filter(!value == "") %>%
    mutate(value = gsub("-", "", value))
  #' remove "-" before match
  issn_tmp <- cr_epmc_df %>%
    select(issn, issn_print, issn_electronic) %>%
    sapply(., function(x) gsub("-", "", x)) %>%
    as_data_frame()
  #' match every row and return logical indicating DOAJ indexing status
  cr_epmc_df$doaj <- !is.na(match(issn_tmp$issn, doaj_issns$value) | match(issn_tmp$issn_print, doaj_issns$value) | match(issn_tmp$issn_electronic, doaj_issns$value))
  #' ### Check if publication is already available via Open APC
  #' Load most recent Open APC dataset
  open_apc <- httr::GET("https://raw.githubusercontent.com/OpenAPC/openapc-de/master/data/apc_de.csv") %>%
    httr::content("text") %>%
    readr::read_csv() %>%
    mutate(doi = tolower(doi))
  apc_check <- cr_epmc_df %>%
    # we don't wanna match NA
    filter(!is.na(doi)) %>%
    mutate(indexed_by_open_apc = doi %in% open_apc$doi)
  apc_df <- cr_epmc_df %>%
    filter(is.na(doi)) %>%
    bind_rows(apc_check,.)
  return(apc_df)
}

# create publication list
make_reflist <- function(x) {
 refs <- paste0('<li>', 
                 x$styled_citation, 
                 '</br>DOI: <a href="https://', x$doi, 
                 '>https://doi.org', x$doi, '</a></li>')
 cat("<ol>", refs, "</ol>")
}

# create shiny
