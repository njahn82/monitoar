# This is the user-interface definition of the monitoar Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
library(shiny)
library(shinythemes)



shinyUI(fluidPage(
  theme = shinytheme("united"),
  # titlePanel("monitoar - an app for supporting open access compliancy workflows"),
  fluidRow(
    tags$div(class = "jumbotron", includeMarkdown
                  ("about.md"))),
  fluidRow(
    column(width = 4,
           wellPanel(style = "background-color: #ffffff;",
                     includeMarkdown("upload_help.md"),
        fileInput('file_xlsx', 'Upload xlsx File',
                  accept = ".xlsx"),
        actionButton(inputId = "submit", "Run!"))),
      column(width = 8,
      conditionalPanel(condition = "$('html').attr('class') == 'shiny-busy'",
                         tags$h3("Loading ..."),
                          tags$p("Please wait, metadata records are currently fetched from Crossref, Europe PubMed Central and DOAJ. This may take a while"),
                       tags$img(src="gears.gif", align = "middle")
                         ),
  conditionalPanel(
        condition = "$('html').attr('class') != 'shiny-busy'",
               uiOutput("download_button_xlsx"))
    ))))


