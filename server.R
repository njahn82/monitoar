
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(dplyr)
library(rio)
library(DT)

shinyServer(function(input, output, session) {
  
  output$loaded <- reactive(0)
  outputOptions(output, "loaded", suspendWhenHidden = FALSE)
  
  observeEvent(input$submit, {
  my_input <- reactive({
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
  

  # Download options
  output$download_xlsx <- downloadHandler(
      filename = function() {
        paste0('data-monitoar', Sys.Date(), '.xlsx')
        },
      content = function(con) {
        rio::export(my_input(), con)
        }
      )

  
  output$table <- renderPrint(my_input())

  output$download_csv <- downloadHandler(
    filename = function() {
      paste0('data-monitoar', Sys.Date(), '.csv')
    },
    content = function(con) {
      rio::export(my_input(), con)
    }
  )
  # Download buttons
  output$download_button_xlsx <- renderUI({
    if (!is.null(my_input())) {
      tabsetPanel(
        tabPanel("Log",
                 verbatimTextOutput("table")
                 ),
        tabPanel("Download",
      tagList(
        tags$h4("Download Options"),
        tags$p("Microsoft Excel",
            downloadButton("download_xlsx", "Microsoft Excel (.xlsx)",
                           class = "btn-success")),
        tags$p("Comma-seperated value",
            downloadButton("download_csv", "Comma-separated values (.csv)",
                           class = "btn-success"))
        )
      ))
    }
  })
  })
  output$loaded <- reactive(1)
})

