# the functions for the server for the assignments tab
# outputs a table of basic stats for the questions on an assessment
itemStatsFun <- function(assessmentDf){
  something <- assessmentDf %>% group_by(., Ident) %>% 
    summarise(., Submissions = n(), MeanScore = mean(Score), SD = sd(Score), MaxPoints = max(Score), VarofItem = var(Score), SumScore = sum(Score)) %>%
    mutate(., FacilityIdx = SumScore / (MaxPoints*max(Submissions))) %>% 
    select(., -SumScore) %>% mutate(., across(-1, as.numeric)) %>% 
    mutate(., across(-1, round, digits = 4)) %>% as.data.table()
  
  something[ , NIdent := stri_replace_all_regex(Ident, pattern='\\.', replacement = '')
  ][mixedorder(NIdent)
  ][,NIdent := NULL]
}



# calculates the means of all the questions on an assessment from the data set above
itemMeans <- function(assessmentData){ 
  assessmentData %>% summarise(., across(everything(), mean)) %>% .[1,] %>% as.vector()
}

#calculates the differences between the mark on a question and the mean for that question  
itemDifferences <- function(assessmentData){
  bind_rows(apply(assessmentData, 1, function(x){x-itemMeans(assessmentData)}))
}

# discriminitive efficiency using the total test score
discriminitiveEffTestScoreFun <- function(assessmentData){
  c <- assessmentData %>% mutate(., across(!starts_with('Total'), function(x){x*TotalScore})) %>% select(., -TotalScore) %>% 
    summarise(.,across(everything(), function(x){(1/(length(.[,1])-1))*sum(x)}))
  
  e <- assessmentData %>% mutate(., across(everything(), sort)) %>%
    mutate(., across(!starts_with('Total'), function(x){x*TotalScore})) %>% select(., -TotalScore) %>% 
    summarise(.,across(everything(), function(x){(1/(length(.[,1])-1))*sum(x)}))
  
  f <- rbind(c,e)
  
  f[1,]/f[2,] 
}

# discriminitive efficiency using the 'rest of test' score
discriminitiveEffRestScoreFun <- function(assessmentData, itemmeandf){
  d1 <- as.data.frame(apply(assessmentData, 2, function(x){(-1*x) + assessmentData$TotalScore})) %>% select(., -TotalScore)
  
  d2 <- itemDifferences(d1) #bind_rows(apply(d1, 1, function(x){x-b1}))
  
  d3 <- select(itemmeandf, -TotalScore) * d2
  
  c1 <- d3 %>% summarise(.,across(everything(), function(x){(1/(length(.[,1])-1))*sum(x)}))
  
  e1 <- mutate(select(itemmeandf, -TotalScore), across(everything(), sort))*mutate(d2, across(everything(), sort)) 
  
  e2 <- summarise(e1,across(everything(), function(x){(1/(length(e1[,1])-1))*sum(x)}))
  
  f1 <- rbind(c1,e2)
  
  f1[1,]/f1[2,] 
  
}

# Cramer's V function
cramerVFun <- function(assessmentData){
  somenames <- names(select(assessmentData, -TotalScore))
  DT <- lapply(somenames, function(x){CramerV(assessmentData[[x]],assessmentData[['TotalScore']], method = 'fisheradj', correct=TRUE)})
  names(DT) <- somenames
  return(DT)
}

# uncertainy coefficients for the item predicting the total and the total predicting the item
itemPredictTotalFun <- function(assessmentData){
  somenames <- select(assessmentData, -TotalScore) %>% names() 
  DT <- lapply(somenames, function(x){round(UncertCoef(assessmentData$TotalScore,assessmentData[[x]],direction ='column'), 4)})
  names(DT) <- somenames
  return(as.data.table(DT))
}

totalPredictItemFun <- function(assessmentData){
  somenames <- select(assessmentData, -TotalScore) %>% names() 
  lapply(somenames, function(x){UncertCoef(assessmentData$TotalScore,assessmentData[[x]],direction ='row')})
}
