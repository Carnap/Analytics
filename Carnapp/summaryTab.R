 # tab for course summary ----
 summaryTab <- tabPanel("Summary Line Graphs",
         
                         #plot of all student marks on all assignments before input changes
                        fluidRow(column(12, align="center", 
                                radioButtons('aboveorbelow', h3("Show me students whose cumulative average is"), choices=list('at or above'='above', 'at or below'='below'), selected='below'), 
                                 selectInput("thepercentage", "the following percentage", 
                                             choices = list('90%'=0.9, '85%'=0.85, '80%'=0.8, '75%'=0.75, '70%'=0.7, '65%'=0.65, '60%'=0.6, '55%'=0.55, '50%'=0.5), 
                                     selected = 0.55), helpText("(An error means there aren't any such students)"))),
         
                        fluidRow(plotOutput("plot1Summary"))
         
)