


# get the data for a particular assignment from carnap
assignmentChoiceFun <- function(theapikey, userEmail, courseName, courseTZ, assgnName, assgnList, studentList, extensionList){
  assignment <- filter(assgnList, Title==assgnName)
  
  subsData <- assignment[['AssignmentId']] %>% 
    subsFunA2(theapikey, userEmail, courseName, .) %>%
    left_join(., assignment, by="AssignmentId") %>%
    left_join(., studentList, by="userId") %>%
    mutate(., duedate=translateDatesFun(duedate,courseTZ), Submitted=translateDatesFun(Time,courseTZ))
  
  if (is.null(extensionList)){
    
    return(noextensionCombFun(subsData) %>% select(., -AssignmentId))
  } else if (length(filter(extensionList, AssignmentId == assignment[['AssignmentId']])[[1]]) < 1){
  
    return(noextensionCombFun(subsData) %>% select(., -AssignmentId))
  } 
  else{
    subsData <- extensionCombFun(subsData, filter(extensionList, AssignmentId == assignment[['AssignmentId']])) %>%
    select(., -AssignmentId)
    return(subsData)
  }
}



# makes a data set out of an assessment with questions and total score as columns
assessmentDataFun <- function(assessmentDf){
  assessmentDf %>% 
    select(., userId, Ident, Score) %>% 
    tidyr::pivot_wider(., names_from = Ident, values_from = Score, values_fill = 0) %>% 
    select(., -userId) %>%
    cbind(., TotalScore = rowSums(.))
}




# makes histograms with a line showing the mean
assessmenthistoFun <- function(assessmentDf, assmentTitle, scoretype){
  assessmentDf %>% as.data.table() %>% .[Title==assmentTitle] %>%
    ggplot(., aes(x=.data[[scoretype]])) +
    geom_bar(colour="black", fill="blue") +
    theme_bw() +
    geom_text(stat="count", aes(label=..count..), vjust=-1) +
    geom_vline(aes(xintercept=mean(.data[[scoretype]])), col='red', linetype=4) +
    geom_text(aes(label=round(mean(.data[[scoretype]]),2),y=-1,x=mean(.data[[scoretype]])),
              hjust=-0.3, vjust=1, col='red',size=4) +
    geom_text(aes(label='Mean',y=-1,x=mean(.data[[scoretype]])),
              hjust=1.3, vjust=1, col='red',size=4)
  
}

# calculates Cronbach's alpha for an assessment
AlphaFunction <- function(assessmentData){
  assessmentData %>%
    select(., -TotalScore) %>% CronbachAlpha()
}  