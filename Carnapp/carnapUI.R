
source('summaryTab.R')
source('StudentTab.R')
source('assessment1Tab.R')
source('assessment2Tab.R')
source('downloadTab.R')
# User Interface 
carnapUI <- navbarPage("Carnap Analytics",
                 
                 # App title ----
                 tabPanel("Enter Email and API Key First",
                          
                          # Sidebar layout with input and output definitions ----
                          sidebarLayout(
                            
                            # Sidebar panel for inputs ----
                            sidebarPanel("Enter your details first",
                                         
                                         # Input: email of user ----
                                         textInput("Email", h3("User Email"),
                                                   value = ""),
                                         
                                         #textInput("carnapClass", h3("Carnap Class Name"),
                                         #          value = ""),
                                         
                                         textInput("API", h3("API key"),
                                                   value = ""),
                                         
                                         #submitButton("Submit")
                                         
                            ),
                            
                            # Main panel for displaying outputs ----
                            mainPanel(h2("Choose a Class"),
                                      uiOutput("classesDrop"),
                                      h4("All stats and data in the other tabs are determined by the class choosen here."), 
                                      h4("To see different stats you must first choose a different class here."),
                                      helpText("(Don't worry about the warning after entering your email."), 
                                      helpText("After picking a class, it may take a few minutes of processing.)")
                            )
                          )
                 ),
                 
                 summaryTab,
                 
                 StudentTab,
                 
                 tabPanel("Assessment Stats",
                          fluidRow(column(12, align="center", uiOutput("assignmentsDrop")),
                                   helpText('Assignment Names sometimes get left over and 
                                            cause an error: simply choose another assignment to view.')
                                   ),
                          
                          tabsetPanel(type='pills',
                          
                                      assessmentTab,
                                      
                                      questionsTab
                          )
                  ),
                 
                 downloadTab,
                 
                 tabPanel("FAQs",
                          
                          h2("Why aren't my classes loading?"), br(),
                          p("Have you generated an API-key in the 'Manage Uploaded Documents' tab on your carnap instructor page? If so, have you generated an API-key recently? Try copying and pasting your new key."),
                          
                          h2("What is a student's cumulative average?"), br(),
                          p("A student's cumulative averages is the mean of the student's average scores, which can be high if the student has done well on relatively few assessments. You can indentify such outliers by looking at the data points in the second line graph in the summary line graphs tab."),
                          
                          h2("How are the average scores calculated?"), br(),
                          p("A student's average score is calculated by adding up that student's score on each question (that's the TotalScore) and then dividing it by EITHER the total point value you provided when assigning your document in carnap OR (if you didn't do that) the maximum score achieved on that assessment for that class."),
                          p("An assessment's average score is the mean of the TotalScore column computed from the student scores."),
                          
                          h2("What is 'Internal Consistency'?"), br(),
                          p("In this case it is Cronbach's Alpha which is meant to measure how well the questions measure the same skill. It is questionable how applicable this is in this case because the variables are supposed to be Likert scales which carnap question scores tend not to be."), br(), 
                          p("Further information on Cronbach's alpha can be found here:", a("Cronbach's_alpha", href="https://en.wikipedia.org/wiki/Cronbach%27s_alpha", target="_blank")), br(),
                          p("Information on the interpretation of Internal Consistency can be found here:", a("Internal Consistency", href="https://en.wikipedia.org/wiki/Internal_consistency", target="_blank")), br()        
                          
                 )
                 
      )

