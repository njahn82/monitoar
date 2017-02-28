
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
                 {
    dois <- unlist(strsplit(input$text, "\n"))
    plyr::ldply(dois, cr_parse) %>%
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

