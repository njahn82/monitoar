
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(dplyr)
library(rio)

# parser
source("cr_parse.R")


shinyServer(function(input, output, session) {
  
  output$loaded <- reactive(0)
  outputOptions(output, "loaded", suspendWhenHidden = FALSE)
  
  observeEvent(input$submit, {
  my_input <- reactive({
    # withProgress(message = "Fetching metadata from Crossref", value = 0, 
                # { # workaround http://stackoverflow.com/questions/30624201/read-excel-in-a-shiny-app
                 #  shiny::setProgress(1)
                   in_file <- input$file_xlsx
                   if(is.null(in_file))
                     return(NULL)
                   file.rename(in_file$datapath,
                               paste(in_file$datapath, ".xlsx", sep=""))
                   my_df <- readxl::read_excel(paste(in_file$datapath, ".xlsx", sep=""), 1)
                   source("apc_fetch.R")
                   apc_fetch(my_df) %>%
                     dplyr::as_data_frame()
                   # })
  })
  output$table <- renderPrint(my_input())
  
  # output$download_xlsx <- downloadHandler(
  #   filename = function() {
  #     paste0('data-monitoar', Sys.Date(), '.xlsx')
  #     },
  #   content = function(con) {
  #     rio::export(my_input(), con)
  #     }
  #   )
  # output$download_csv <- downloadHandler(
  #   filename = function() {
  #     paste0('data-monitoar', Sys.Date(), '.csv')
  #   },
  #   content = function(con) {
  #     rio::export(my_input(), con)
  #   }
  # )
  
  # Excel output 
  output$download_button_xlsx <- renderUI({
    if (!is.null(my_input())) {
      downloadButton("download_xlsx", "Download Data xlsx",
                     class = "btn-success")
    }
  })
  
  output$download_xlsx <- downloadHandler(
      filename = function() {
        paste0('data-monitoar', Sys.Date(), '.xlsx')
        },
      content = function(con) {
        rio::export(my_input(), con)
        }
      )
  # CSV output
  output$download_button_csv <- renderUI({
    if (!is.null(my_input())) {
      downloadButton("download_csv", "Download Data csv",
                     class = "btn-success")
    }
  })
  
  output$download_csv <- downloadHandler(
    filename = function() {
      paste0('data-monitoar', Sys.Date(), '.csv')
    },
    content = function(con) {
      rio::export(my_input(), con)
    }
  )
  })
  output$loaded <- reactive(1)
})

