# the UI for the download tab
downloadTab <- tabPanel("Download Submission Data", useShinyjs(),
                        
                        fluidRow(h2("Choose columns you wish to exclude from download (Submit Choices to preview table below)"), column(3,uiOutput("downloadVariables1")), 
                                 column(3,uiOutput("downloadVariables2")), column(3,uiOutput("downloadVariables3"))),
                        fluidRow(column(3,uiOutput("downloadVariables4")), column(3,uiOutput("downloadVariables5"), actionButton("reset1", "Reset Excluded Columns"))),
                        fluidRow(h3("Choose columns to group and summarise Score field by"), helpText("(Leave the fields below empty if you do not wish to summarise the Score.)"), column(3, uiOutput("downloadOptions1")), 
                                 column(3, uiOutput("downloadOptions2")), column(3, h3("Submit Choices"), actionButton("submitchoice", "Submit"), helpText("Submit choices first."), h3("Download Table"), downloadButton("downloadData", "Download"), helpText("(All pages of data will be downloaded; searching will not affect the download)"), offset=2)), 
                        fluidRow(column(3, uiOutput("downloadOptions3")), column(3, uiOutput("downloadOptions4"), actionButton("reset2", "Reset Grouping Columns"))),
                        fluidRow(h3("Choose method for summarising score:"), radioButtons('datafunc', 'Function', choices = c('Mean', 'Sum'))),
                        fluidRow(h3("Summary Table"), dataTableOutput("everythingTable"))         
)