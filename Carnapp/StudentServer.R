## Students tab

studentChoiceFun <- function(theapikey, userEmail, courseName, courseTZ, assgnData, extensionList, studentList, studentName){
  studentid <- filter(studentList, stri_detect_regex(studentName, lastName) & stri_detect_regex(studentName, firstName))[['id']]
  
  studentuserId <- filter(studentList, stri_detect_regex(studentName, lastName) & stri_detect_regex(studentName, firstName))[['userId']]
  
  subsData <- subsFunA3(theapikey, userEmail, courseName, studentid) %>%
    left_join(., assgnData, by="AssignmentId") %>%
    left_join(., studentList, by="userId") %>%
    mutate(., duedate=translateDatesFun(duedate,courseTZ), Submitted=translateDatesFun(Time,courseTZ))
  
  if (is.null(extensionList)){
    return(noextensionCombFun(subsData)%>% select(., -userId, -document, -AssignmentId))
  } else if (length(filter(extensionList, userId == studentuserId)) < 1){
    return(noextensionCombFun(subsData)%>% select(., -userId, -document, -AssignmentId))
  } else{ return(extensionCombFun(subsData, extensionList) %>% select(., -userId, -document, -AssignmentId)) }
}