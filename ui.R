# This is the user-interface definition of the monitoar Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
library(shiny)
library(shinythemes)



shinyUI(fluidPage(
  theme = shinytheme("flatly"),
  titlePanel("monitoar - an app for supporting open access compliancy workflows"),
  fluidRow(column(12, includeMarkdown
                  ("about.md")
                  )),
  fluidRow(column(
    4,
    wellPanel(
      tags$b("Upload your Excel sheet"),
      tags$p("Prepare your Open APC compliant Excel spreadsheet, which contains the following columns:"),
      tags$ul(
        tags$li("doi: the Digital Object Identifier"),
        tags$li("period: the year of the invoice"),
        tags$li("euro: the publication fee paid (including VAT) in €"),
        tags$li("is_hybrid: a logical indicating whether the article was published in a hybrid (TRUE) or full open access journal (FALSE)")
      ),
      fileInput('file_xlsx', 'Upload xlsx File',
                        accept = ".xlsx"),
      actionButton(inputId = "submit", "Run!")
  #   wellPanel(
  #     tags$b("Paste in your DOIs for Open APC metadata mapping"),
  #     p(
  #       "If you have DOIs (Digital Object Identifier) for several articles and would like to retrieve metadata from Crossref in accordance with the Open APC metadata schema, simply paste up to 100 DOIs in the text box below and click the button."
  #     ),
  #     textAreaInput(
  #       inputId = "text",
  #       label = "DOIs (line separated):",
  #       value = "10.7717/peerj.2323\n10.1093/pcp/pcw205",
  #       height = 200
  #     ),
  #  actionButton(inputId = "submit", "Run!")
  #   )
   )),
  column(
    8,
    conditionalPanel(
      condition = "input.submit",
      h3("R Console Output"),
      verbatimTextOutput("table"),
      h3("Download Dataset"),
      downloadButton('download_xlsx', 'Microsoft Excel (.xlsx)'),
      downloadButton('download_csv', 'comma-separated file (.csv)')
      
    )
  ))
))
