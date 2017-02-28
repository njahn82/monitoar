cr_parse <- function(doi) {
  
  # fetch XML through rcrossref
  tryCatch({
    doc <- rcrossref::cr_cn(doi, "crossref-tdm")
  }, error=function(err) {
    ## what to do on error? could return conditionMessage(err) or other...
    warning(sprintf("doi: %s not found", doi))
  })
  
  if(!exists("doc") | is.null(doc))
    return(NULL)
  
  # namespaces
  nm = c(cr = "http://www.crossref.org/xschema/1.1",
         ct = "http://www.crossref.org/qrschema/3.0",
         ai = "http://www.crossref.org/AccessIndicators.xsd")
  
  #xpath queries
  xp_queries = c(doi = "//ct:doi",
                 journal_full_title = "//*[local-name() = 'journal_metadata']//*[local-name() = 'full_title']",
               #  year = "//*[local-name() = 'journal_article']//*[local-name() = 'publication_date']//*[local-name() = 'year']",
              #   year_print = "//*[local-name() = 'journal_article']//*[local-name() = 'publication_date' and @media_type='print']//*[local-name() = 'year']",
              #   year_online = "//*[local-name() = 'journal_article']//*[local-name() = 'publication_date' and @media_type='online']//*[local-name() = 'year']",
                 publisher = "//ct:crm-item[@name='publisher-name']",
                 member_id = "//ct:crm-item[@name='member-id']",
                 journal_id = "//ct:crm-item[@name='journal-id']",
                 issn = "//*[local-name() = 'journal_metadata']//*[local-name() = 'issn']",
                 issn_print = "//*[local-name() = 'journal_metadata']//*[local-name() = 'issn' and @media_type='print']",
                 issn_electronic = "//*[local-name() = 'journal_metadata']//*[local-name() = 'issn' and @media_type='electronic']",
                 license_ref = "//ai:license_ref",
                 times_cited = "//ct:crm-item[@name='citedby-count']")
  
  # sapply on xpath queries on nodes
  tt <- lapply(xp_queries, function(xp_queries) xml2::xml_text(xml2::xml_find_all(doc, xp_queries, nm)))
  # deal with empty list elements
  tt.df <- lapply(tt, function(x)  if (length(x) == 0) x <- NA  else x <- x)
  # deal with multiple value
  tt.df <- lapply(tt.df, function(x) if(length(x)>1) paste(x, collapse=";") else x <- x)
  # return vector
  unlist(tt.df)
}