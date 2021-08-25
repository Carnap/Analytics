source('utils.R', local =T)
source('assmntServer.R')
source('questionsServer.R')
source('StudentServer.R')

carnapServer <- function(input, output, session){
  
##### global reactive things  
    
  # create the list to populate the class list drop down menu in the first tab
  classesList <- reactive({courseListFun(input$API, input$Email)})
  
  # dropdown of the classes an instructor has taught on carnap
  output$classesDrop <- renderUI({
    selectInput("Class", "Classes",
                choices = as.list(sort(classesList()$Title)), selected = 1)
  })
  
  # format the class name for the URL
  className <- reactive({whiteSpaceReplace(input$Class)})
  
  # set the time zone for the class
  classTZ <- reactive({filter(classesList(), Title == input$Class)$timeZone[1]}) 
  
  # set the list of assignments for the class
  assgnData <- reactive({assgnListFun(input$API,input$Email, className(), classTZ())})
  
  # get a list of all the assignment names
  assgnList <- reactive({assgnData() %>% pull(.,Title) %>% mixedsort()})
  
  # get the names of the students in the course
  studentData <- reactive({studentListFun(input$API, input$Email, className())})
  
  #get the list of extensions given
  extensionsData <- reactive({extensionListFun(input$API, input$Email, className(), classTZ(), assgnData())})
  
  # compute the average scores for each assignment
  averageScores <- reactive({ averageScoresFun(input$API,input$Email, className(), classTZ(), assgnData(), studentData(), extensionsData()) %>% 
      mutate(., AvgScore = round(as.numeric(AvgScore), 4))
  })
  
  
  ### Summary Tab  
  
  # plotting the average scores of all student grades on all assignments.
  output$plot1Summary <- renderPlot({
    studentstoobserve <- group_by(averageScores(), firstName, lastName) %>%
      summarise(., CumAvg = mean(AvgScore)) %>%
      {if(input$aboveorbelow=='below') filter(., CumAvg <= input$thepercentage) else filter(., CumAvg >= input$thepercentage)} %>% 
      select(., lastName) %>%
      pull(.,lastName) 
    
    filter(averageScores(), lastName %in% studentstoobserve) %>% studentLineFun(., 'lastName')
  })
  
  
  
### Students tab

  # user input to select the students
  output$studentsDrop <- renderUI({
    students <- studentData() %>%
      unite(., "Name", firstName, lastName, sep=" ") %>%
      select(.,Name) %>%
      distinct()
    students <- as.list(sort(students$Name))
    
    selectInput("student", h3("Choose Student"), choices = students)
  })
  
  studentAverages <- reactive({averageScores() %>%
      unite(., "Name", firstName, lastName, sep=" ") %>%
      filter(., Name == input$student)
  })
  
  chosenStudentData <- reactive({studentChoiceFun(input$API, input$Email, className(), classTZ(), assgnData(), extensionsData(), studentData(),input$student)
  })
  
  
  output$plotStudent <- renderPlot({studentLineFun(studentAverages(), 'Name')})  
  
  output$studentAveragesLines <- renderDataTable({studentAverages() %>% select(., -userId, -MaxScore) %>% as.data.table()})
  
  output$tableStudent <- renderDataTable({ chosenStudentData() %>%
      unite(., "Name", firstName, lastName, sep=" ") %>%
      as.data.table()
  })
  

  
### Assignments Tab
  
  # creating the user input for the assignments
  output$assignmentsDrop <- renderUI({
    selectInput("assignment", h2("Choose Assessment to View"), choices = as.list(assgnList()))
  })
  
  # getting the speific data for the assignment
  assmntDf <- reactive({assignmentChoiceFun(input$API, input$Email, className(), classTZ(), input$assignment, assgnData(), studentData(), extensionsData())
  })
  
  # stripping out the raw data
  assmntData <- reactive({assessmentDataFun(assmntDf())})
  
  # compute the stats for the assessments for review
  assessmentstats <- reactive({averageScores() %>% group_by(., Title) %>%
      summarise(., AssessmentSubmissions=n_distinct(userId), AssessmentMean= mean(TotalScore), SDofAssessment = sd(TotalScore), VarofAssessment = var(TotalScore), FullScore=mean(MaxScore))
  })
  
  # plotting the histogram of averages for each assignment.
  output$plotAssignment <- renderPlot({
    assessmenthistoFun(averageScores(), input$assignment, input$score)
  })
  
  # the summary table for the assignment
  output$assngSummaryTable <- renderDataTable({ 
    theassgnstats <- assessmentstats() %>%
      filter(., Title==input$assignment)
    
    theassgnstats$InternalConsistency <- AlphaFunction(assmntData())
    
    theassgnstats %>% select(., -Title) %>% mutate(., across(everything(), as.numeric)) %>%
      mutate(., across(everything(), round, digits=4)) %>% as.data.table()
  })
  
  
  # showing a table of all submissions to an assignment when an assignment selected.
  output$tableAssignment <- renderDataTable({assmntDf() %>%
      select(., -userId, -Title, -document) %>%
      as.data.table()
  })
  
  ### Assessment Questions Tab
  
  output$tableQuestions <- renderDataTable({
    assmntDf() %>% itemStatsFun() %>% as.data.table()
  })
  
  
  output$tableEffQuestions <- renderDataTable({
    b <- assmntData() %>% itemDifferences() %>% discriminitiveEffTestScoreFun() %>% as.data.table()
    
    c <- assmntData() %>% discriminitiveEffRestScoreFun(., itemDifferences(.)) %>% as.data.table()
    
    rbind(b,c) %>%  as.data.frame() %>% rbind(., stri_replace_all_regex(names(.), pattern='[:punct:]', replacement = '')) %>% 
      t() %>% as.data.frame() %>% .[mixedorder(.[[3]]),] %>% 
      select(., -3) %>% t() %>% as.data.frame() %>% 
      mutate(., across(everything(), as.numeric)) %>%
      mutate(., across(everything(), round, digits=4 )) %>% as.data.table()
  })
  
  output$tableUncertCoeff <- renderDataTable({
    a <- assmntData() %>% itemPredictTotalFun()
    b <- assmntData() %>% cramerVFun()
    
    rbind(a,b) %>% as.data.frame() %>% rbind(., stri_replace_all_regex(names(.), pattern='[:punct:]', replacement = '')) %>% 
      t() %>% as.data.frame() %>% .[mixedorder(.[[3]]),] %>% select(., -3) %>% t() %>% as.data.frame() %>% 
      mutate(., across(everything(), as.numeric)) %>%
      mutate(., across(everything(), round, digits=4 )) %>% as.data.table()
  })
  
  
  ## All submissions
  
  observeEvent(input$reset1, {
    shinyjs::reset("exVar1") 
    shinyjs::reset("exVar2") 
    shinyjs::reset("exVar3")
    shinyjs::reset("exVar4")
    shinyjs::reset("exVar5")
    
    
  })
  
  observeEvent(input$reset2, {
    shinyjs::reset("group1") 
    shinyjs::reset("group2") 
    shinyjs::reset("group3")
    shinyjs::reset("group4")
    
  })
  
  extcoltitle <- c('userId', 'universityId', 'lastName', 'firstName', 'Title', 'duedate', 'Extension', 'Submitted', 'Type', 'Ident', 'Score', 'Late', 'document', 'AssignmentId', " ")
  
  noextcoltitle <- c('userId', 'universityId', 'lastName', 'firstName', 'Title', 'duedate', 'Submitted', 'Type', 'Ident', 'Score', 'Late', 'document', 'AssignmentId', " ")
  
  downloadSubs1 <- reactive({if (is.null(extensionsData())){ return(noextcoltitle)} else{return(extcoltitle)} })  
  
  output$downloadVariables1 <- renderUI({selectInput('exVar1', h4("Exclude"), choices = downloadSubs1(), selected = " ")})
  output$downloadVariables2 <- renderUI({selectInput('exVar2', h4("and"), choices = downloadSubs1(), selected = " ")})
  output$downloadVariables3 <- renderUI({selectInput('exVar3', h4("and"), choices = downloadSubs1(), selected = " ")})
  output$downloadVariables4 <- renderUI({selectInput('exVar4', h4("and"), choices = downloadSubs1(), selected = " ")})
  output$downloadVariables5 <- renderUI({selectInput('exVar5', h4("and"), choices = downloadSubs1(), selected = " ")})
  
  excludedVariables <- reactive({
    c(input$exVar1, input$exVar2, input$exVar3, input$exVar4, input$exVar5) %>% unique()
  })
  
  downloadSubs2 <- reactive({downloadSubs1() %>% base::setdiff(., excludedVariables()) %>% append(., c(" ")) %>% unique()})
  
  output$downloadOptions1 <- renderUI({selectInput('group1', h4("Group by"), choices = downloadSubs2(), selected = " ")})
  output$downloadOptions2 <- renderUI({selectInput('group2', h4("and by"), choices = downloadSubs2(), selected = " ")})
  output$downloadOptions3 <- renderUI({selectInput('group3', h4("and by"), choices = downloadSubs2(), selected = " ")})
  output$downloadOptions4 <- renderUI({selectInput('group4', h4("and by"), choices = downloadSubs2(), selected = " ")})
  
  groupingVariables <- reactive({
    c(input$group1, input$group2, input$group3, input$group4) %>% unique() %>% sort() %>% .[which(.!=" ")]
  })
  
  
  
  downloadSubs3 <- eventReactive(input$submitchoice, {
    if (length(groupingVariables()) < 1){
      subsFunB(input$API, input$Email, className(), classTZ(), assgnData(), studentData(), extensionsData()) %>%
        select(., downloadSubs2()[which(downloadSubs2() !=' ')])}
    else if (input$datafunc == 'Mean') {allSubs() %>% select(., downloadSubs2()[which(downloadSubs2() !=' ')]) %>% group_by(., !!!syms(groupingVariables())) %>% summarise(., mean(Score))}
    else{allSubs() %>% select(., downloadSubs2()[which(downloadSubs2() !=' ')]) %>% group_by(., !!!syms(groupingVariables())) %>% summarise(., sum(Score))}
  })
  
  output$everythingTable <- renderDataTable({as.data.table(downloadSubs3())})
  
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$Class, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(downloadSubs3(), file, row.names = FALSE)
    }
  )
}