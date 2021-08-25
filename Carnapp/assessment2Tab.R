questionsTab <- tabPanel("Question Stats per Assessment",
                
                         
                         fluidRow(h2(" Basic Stats for Questions on Chosen Assessment"), dataTableOutput("tableQuestions")),
                         
                         fluidRow(h2("Discrimative Effeiciency"), dataTableOutput("tableEffQuestions")),
                         
                         fluidRow(h2("Measures of Association"), dataTableOutput("tableUncertCoeff")),
                         
                         fluidRow(h2("Interpreting these Statistics"), 
                                  p(h3("Facility Index (FacilityIdx):"), 
                                    "The facility index is an estimate of how difficult the question is. The closer to 1 the index is, 
                                     the easier the question since that means more people answered correctly. 
                                     It takes the sum of all scores on the question, and then divides that 
                                     by the MaxScore multipled by the maximum number of submissions on any assignment question. 
                                     That may differ from the number of submissions to that question, 
                                     but wouldn't be reflected in the mean of the scores because of the way carnap records the scores."),
                                  p(h4(span("Note:", style="color:blue"), "A facility index of 1 makes the other statistics unreliable, hence the blank fields. Too little 
                                        data will also result in blank fields.")),
                                  p(h3("Dsicriminative Efficiency:"), 
                                    "Discriminitive efficiency is meant to measure how effective a question is at testing a student's ability.
                                     The closer to 1 these values are, the better these questions discriminate between high and low ability.
                                     It is computed as the correlation between the students' score on the question and the students' total score
                                     on the assignment. The first row displays the correlations between the question scores and the total score.
                                     The second row displays the correlation between the students' question score and the total-the question score.
                                     This is referred to as the 'Rest of Test' score. Both of these are calculated as roughly Chi^2 statistics. 
                                     for more details on this see", a("Moodle Quiz Statistics Calculations.", href="https://docs.moodle.org/dev/Quiz_statistics_calculations", target="_blank") ),
                                  "The calculations used are those of the 'Item Statistics'. The problem with the Discrimitive Index used by Moodle 
                                     is that the variances of the questions in carnap tends to be 0 because the standard deviation is often 0.",
                                  p(h3("Measures of Association:"),
                                    "These statistics measure whether the questions correlate with the over all test score. The first row is the uncertainty coefficient
                                     for the question against the test score. The second row is Cramer's V for the question against the test score.
                                     The closer to 1 these values are, the more correlated the question is to the total value of the assignment. 
                                     The uncertainty coefficient (UC) represents the decrease in uncertainty about a variable's value when the value 
                                     of another variable is known. So, in this case, if the UC is 0.46 for question 1, then knowing the value of 
                                     question 1 means that the uncertainty of predcitions of the total score based on question 1 are decreased by 46%.
                                     UC is a measure of information entropy. For more information on this measure see:", a("Uncertainty Coefficient.", href="https://en.wikipedia.org/wiki/Uncertainty_coefficient", target="_blank"),
                                    "Cramer's V is a Chi-squared measure of association which isn't effected by samble size so the comparisons between the 
                                     questions are more reliable than in the other statistics. This use has been corrected for bias, so it is a more conservative 
                                     measure of association. It is also a symmetric measure, so even though no one may have gotten that question wrong, Cramer's V 
                                     will report something, usually. Any score over 0.7 indicates a strong association. For more information see:", a("Cramer's V.", href="https://en.wikipedia.org/wiki/Cram%C3%A9r%27s_V", target='_blank')
                                  )
                                  
                        )
                         
)



