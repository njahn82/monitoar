
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(dplyr)
library(rio)

# parser
source("cr_parse.r")


shinyServer(function(input, output) {
  observeEvent(input$submit, {
  my_input <- reactive({
    withProgress(message = "Fetching metadata from Crossref", min = 0, 
                 { # workaround http://stackoverflow.com/questions/30624201/read-excel-in-a-shiny-app
                   in_file <- input$file_xlsx
                   if(is.null(in_file))
                     return(NULL)
                   file.rename(in_file$datapath,
                               paste(in_file$datapath, ".xlsx", sep=""))
                   my_df <- readxl::read_excel(paste(in_file$datapath, ".xlsx", sep=""), 1)
                   source("apc_fetch.R")
                   apc_fetch(my_df) %>%
                     dplyr::as_data_frame()
    })
  })
  output$table <- renderPrint(my_input())
  
  output$download_xlsx <- downloadHandler(
    filename = function() {
      paste0('data-monitoar', Sys.Date(), '.xlsx')
      },
    content = function(con) {
      rio::export(my_input(), con)
      }
    )
  output$download_csv <- downloadHandler(
    filename = function() {
      paste0('data-monitoar', Sys.Date(), '.csv')
    },
    content = function(con) {
      rio::export(my_input(), con)
    }
  )
  })
})

