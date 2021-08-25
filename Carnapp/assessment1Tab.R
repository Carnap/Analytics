assessmentTab <- tabPanel("Summary Stats",  
                                      # Assessment inputs 
                                      fluidRow(
                                       
                                        column(3, radioButtons("score", h4("Plot score in terms of"),
                                                               choices = list("Points" = "TotalScore", "Average" = "AvgScore"), selected = "AvgScore"))
                                      ),
                                      
                                      #plot the distribution of grades for the selected assignment. 
                                      fluidRow(plotOutput("plotAssignment")),
                                      
                                      #summary table of stats for chosen assignment.
                                      fluidRow(h2("Assessment Stats"), dataTableOutput("assngSummaryTable")),
                                      
                                      #table of all submissions to chosen assignment
                                      fluidRow(h2("Submissions for Each Question on the Assessment"), dataTableOutput("tableAssignment"))
                                      
)
