# all the functions that are used in the global environment


#function to replace the white space in titles so that they can be used in urls.
whiteSpaceReplace <- function(x){stri_replace_all_regex(x, "\\s+", '%20')}

# function which makes the dates readable 
#and displays them in the right time zone, i.e., where the course is being offered
translateDatesFun <- function(x,courseTZ){
  theTime <- x %>% stri_sub(.,1,19) %>% stri_replace_all_regex(., "T", " ") %>%
    ymd_hms(., tz="UTC") %>% with_tz(., tzone = courseTZ)# %>% as.character()
  
  return(theTime)
}

# function for generating the list of courses for that instructor 
courseListFun <- function(theapikey, userEmail){
  
  coursespage <- stri_join("https://carnap.io/api/v1/instructors/", userEmail, "/courses", sep="")
  
  coursesList <- GET(coursespage, add_headers('x-api-key'=theapikey)) %>%
    content(., "text") %>% 
    jsonlite::fromJSON()
  
  names(coursesList)[names(coursesList) == 'title'] <- 'Title'
  return(coursesList)
}

#gets a list of assignments with their due date, title etc
assgnListFun <- function(theapikey, userEmail, courseName, courseTZ){
  assignmentspage <- stri_join("https://carnap.io/api/v1/instructors/", userEmail, "/courses/", courseName, "/assignments", sep="")
  
  AssignmentData <- GET(assignmentspage, add_headers('x-api-key'=theapikey)) %>%
    content(., "text") %>% 
    jsonlite::fromJSON() %>%
    mutate(., AssignmentId=id, Title = stri_replace_all_regex(title, '.md','')) %>%
    filter(., !is.na(duedate)) %>%
    select(., AssignmentId, document, pointValue, totalProblems, Title, duedate)
  
  return(AssignmentData)
}


# gets the list of students for the class
studentListFun <- function(theapikey, userEmail, courseName){
  studentpage <- stri_join("https://carnap.io/api/v1/instructors/", userEmail, "/courses/", courseName, "/students", sep="")
  
  GET(studentpage, add_headers('x-api-key'=theapikey)) %>%
    content(., "text") %>%
    jsonlite::fromJSON() %>%
    select(., universityId, userId, firstName, lastName, id)
  
}

extensionsFun <- function(userName, courseName, theapikey, assignmentId){
  
  extensionspage <- stri_join("https://carnap.io/api/v1/instructors/", userName, "/courses/", courseName, "/assignments/", as.character(assignmentId) ,"/extensions", sep="")
  
  extensionData <- GET(extensionspage, add_headers('x-api-key'=theapikey)) %>%
    content(., "text") %>%
    jsonlite::fromJSON()
  Sys.sleep(0.1)
  return(extensionData)
}

# get all of the extensions granted
extensionListFun <- function(theapikey, userEmail, courseName, courseTZ, assgnList){
  extensions <- assgnList[['AssignmentId']] %>% as.list() %>% 
    lapply(., function(x){extensionsFun(userEmail, courseName, theapikey, x)}) %>%
    rbindlist()
  
  if(length(extensions) < 2){return(NULL)}
  else{ 
    extensions <- mutate(extensions, Extension=translateDatesFun(until, courseTZ)) %>% select(., -id, -until)
    
    names(extensions)[names(extensions)=='forUser'] <- 'userId'
    names(extensions)[names(extensions)=='onAssignment'] <- 'AssignmentId'
    
    return(extensions)}
}

# creditfun <- function(correct, credit){
#   if (is.na(credit)){return(NA)}
#   else if (correct==TRUE){return(credit)}
#   else{return(0)}
# }

# get all the submissions for an assignment in the class with a pause
subsFunA1 <- function(theapikey, userEmail, courseName, assgnId){
  submissionspage <- stri_join("https://carnap.io/api/v1/instructors/", userEmail, "/courses/", courseName, "/assignments/", as.character(assgnId), "/submissions", sep="")
  
  subsData <- GET(submissionspage, add_headers('x-api-key'=theapikey)) %>%
    content(., "text") %>% 
    jsonlite::fromJSON()
  
  
  # simplifying the column names
  names(subsData) <- stri_replace_all_regex(names(subsData), "problemSubmission", "")
  
  names(subsData)[names(subsData) == 'UserId'] <- 'userId'
  
  if (length(subsData)==0){Sys.sleep(0.1)}
  else{
    subsData <- dplyr::select(as.data.frame(subsData), -(3:4))
    Sys.sleep(0.1)
    return(subsData)
  }
  
}

# doesn't pause between gets and gets submissions to a particular assignment
subsFunA2 <- function(theapikey, userEmail, courseName, assgnId){
  submissionspage <- stri_join("https://carnap.io/api/v1/instructors/", userEmail, "/courses/", courseName, "/assignments/", as.character(assgnId), "/submissions", sep="")
  
  subsData <- GET(submissionspage, add_headers('x-api-key'=theapikey)) %>%
    content(., "text") %>% 
    jsonlite::fromJSON()
  
  # simplifying the column names
  names(subsData) <- stri_replace_all_regex(names(subsData), "problemSubmission", "")
  
  names(subsData)[names(subsData) == 'UserId'] <- 'userId'
  
  if (length(subsData)==0){NULL}
  else{
    subsData <- dplyr::select(as.data.frame(subsData), -(3:4))
    return(subsData)
  }
}

# doesn't pause between gets and gets submissions for a particular student
subsFunA3 <- function(theapikey, userEmail, courseName, studentId){
  submissionspage <- stri_join("https://carnap.io/api/v1/instructors/", userEmail, "/courses/", courseName, "/students/", as.character(studentId), "/submissions", sep="")
  
  subsData <- GET(submissionspage, add_headers('x-api-key'=theapikey)) %>%
    content(., "text") %>% 
    jsonlite::fromJSON()
  
  # simplifying the column names
  names(subsData) <- stri_replace_all_regex(names(subsData), "problemSubmission", "")
  
  names(subsData)[names(subsData) == 'UserId'] <- 'userId'
  
  if (length(subsData)==0){NULL}
  else{
    subsData <- dplyr::select(as.data.frame(subsData), -(3:4))
    return(subsData)
  }
}

#computes one score from the various credit inputs
scoreFun <- function(correct, credit, latecredit, extracredit, subLate){
  if (!is.na(extracredit)){return(extracredit)}
  else if (!is.na(latecredit)){return(latecredit)}
  else if (!is.na(credit) & correct==FALSE){return(0)}
  else if (!is.na(credit) & subLate==TRUE){return(floor(as.numeric(credit)/2))}
  else if (!is.na(credit)){return(credit)}
  else if (subLate==FALSE & correct==TRUE){return(5)}
  else{return(2)}
}

extensionCombFun <- function(df, extensionList){
  
  subsData <- left_join(df, extensionList, by=c('userId', 'AssignmentId')) %>% 
    mutate(., Late = !(Submitted <= Extension | Submitted <= duedate)) %>%
    filter(., !is.na(Late))
  
  subsData$Score <- mapply(scoreFun, subsData$Correct, subsData$Credit, subsData$LateCredit, subsData$Extra, subsData$Late)
  
  subsData <- subsData %>% filter(., !is.na(Score), !is.na(lastName)) %>%
    select(., userId, universityId, lastName, firstName, Title, duedate, Extension, Submitted, Type, Ident, Score, Late, document, AssignmentId)
  return(subsData)
}

noextensionCombFun <- function(df){
  subsData <-  mutate(df, Late = !(Submitted <= duedate)) %>%
    filter(., !is.na(Late))
  
  subsData$Score <- mapply(scoreFun, subsData$Correct, subsData$Credit, subsData$LateCredit, subsData$Extra, subsData$Late)
  
  subsData <- subsData %>% filter(., !is.na(Score), !is.na(lastName)) %>%
    select(., userId, universityId, lastName, firstName, Title, duedate, Submitted, Type, Ident, Score, Late, document, AssignmentId)
  return(subsData)
  
}

# get the submissions for everything
subsFunB <- function(theapikey, userEmail, courseName, courseTZ, assgnList, studentList, extensionList){
  
  subsData <- lapply(assgnList$AssignmentId,
                     function(x){subsFunA1(theapikey, userEmail, courseName, x)}) %>%
    rbindlist() %>%
    left_join(., assgnList, by="AssignmentId") %>%
    left_join(., studentList, by="userId") %>%
    mutate(., duedate=translateDatesFun(duedate,courseTZ), Submitted=translateDatesFun(Time,courseTZ))
  
  if (is.null(extensionList)){
    subsData <- noextensionCombFun(subsData)
    return(subsData)
  } else{
    subsData <- extensionCombFun(subsData, extensionList)
    return(subsData)
  }
}


# outputs a table of the average scores each student received on each assessment
averageScoresFun <- function(theapikey, userEmail, courseName, courseTZ, assgnList, studentList, extensionsList){
  
  testing <- subsFunB(theapikey, userEmail, courseName, courseTZ, assgnList, studentList, extensionsList) %>% 
    group_by(.,Title, duedate, userId, universityId, firstName, lastName, AssignmentId) %>%
    summarise(., TotalScore = sum(Score)) %>%
    left_join(., select(assgnList, AssignmentId, pointValue, totalProblems), by="AssignmentId")
  
  testing %>% group_by(.,AssignmentId) %>%
    summarise(., MaxScore = max(TotalScore)) %>%
    select(., AssignmentId, MaxScore) %>%
    left_join(testing, ., by="AssignmentId") %>%
    mutate(., AvgScore = if_else(!is.na(pointValue), as.numeric(TotalScore)/as.numeric(pointValue), TotalScore/MaxScore)) %>%
    arrange(., duedate) %>% mutate(., duedate=as.character(as_datetime(duedate, tz=courseTZ))) %>%
    select(., -pointValue, -totalProblems, -AssignmentId)
  #return(avgscore)
}

# plots a line graph for a student averages
studentLineFun <- function(df,linelabels){
  p <- df %>% mutate(., duedate = ymd_hms(duedate)) %>%
    mutate(., Title = fct_reorder(Title, desc(duedate))) %>%
    ggplot(., aes(x=reorder(Title, duedate), y=AvgScore, group=.data[[linelabels]], color=.data[[linelabels]])) + 
    geom_point() + 
    geom_line() + theme_bw() +
    theme(axis.text.x = element_text(size = 12, angle = 90, vjust = 0.5, hjust=1)) + # rotates the names of the assessments
    labs(x='Assessment', y='Avg Score') +
    #scale_colour_discrete(guide = 'none') +
    scale_x_discrete() 
  #direct.label(p, method="angled.boxes")
  p
}
