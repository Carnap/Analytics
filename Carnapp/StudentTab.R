# UI for the student data tab
StudentTab <- tabPanel("Individual Student Averages and Submissions",
                       
                       fluidRow(uiOutput("studentsDrop")),
                       
                       fluidRow(plotOutput("plotStudent")),
                       
                       fluidRow(h2("Student Averages for Each Assessment"), dataTableOutput("studentAveragesLines")),
                       
                       fluidRow(h2('Student Submissions on Each Assessment'), dataTableOutput("tableStudent"))
)