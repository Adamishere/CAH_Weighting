#setwd("[SET YOUR OWN FILE LOCATION]")
library(survey)
library(dplyr)
#Import, string as factors = FALSE
potn_raw<-read.csv("201711-CAH_PulseOfTheNation.csv", stringsAsFactors = FALSE)

#Review Variables
str(potn_raw)

#Review Weighting Variables
table(potn_raw$Gender)
table(potn_raw$Age.Range)
table(potn_raw$What.is.your.race.)

#subset to weighting variables 
#potn_1 <- potn_raw[,c("Gender","Age.Range","What.is.your.race.")]
#or not
potn_1 <- potn_raw[,]

##########################
#Data Cleaning:
##########################
    
    ##########################
    #Gender
    ##########################
    #Impute DK/Other to match population categories
    potn_1[,"imp_gender"]<- runif(nrow(potn_1))
    
    #Randomly assign imputation
    potn_1[potn_1$imp_gender>(.5),"w_gender"]<- "M"
    potn_1[potn_1$imp_gender<=(.5),"w_gender"]<- "F"
    
    #Overwrite with Respondent Answer where not imputed
    potn_1[potn_1$Gender=="Male","w_gender"]<- "M"
    potn_1[potn_1$Gender=="Female","w_gender"]<- "F"
    table(potn_1$w_gender, potn_1$Gender)
    table(potn_1$w_gender)
 
    ##########################
    #Race
    ##########################
    #Collapse Race to White/Black/Other
    table(potn_raw$What.is.your.race.)
    
    potn_1[,"w_race"] <- "Other"
    potn_1[potn_1$What.is.your.race.=="White","w_race"]<-"White"
    potn_1[potn_1$What.is.your.race.=="Black","w_race"]<-"Black"
    
    table(potn_1$w_race)
    ##########################
    #Age
    ##########################
    
    #Age is okay
    potn_1[,"w_age"] <- potn_1$Age.Range
    table(potn_1$w_age)


##########################
#Create Survey Design Object
##########################
svy.unweighted <- svydesign(ids=~1, data=potn_1)

##########################
#Population totals
##########################
age.dist <- data.frame(w_age = c("18-24",
                              "25-34",
                              "35-44",
                              "45-54",
                              "55-64",
                              "65+"),
                       Freq =  c(             30843811,
                                              44677243,
                                              40470156,
                                              42786679,
                                              41463144,
                                              49244195))
race.dist <- data.frame(w_race = c("White",
                                 "Black",
                                 "Other"),
                       Freq =  c(             191867632,
                                               33200631,
                                               24416965))

gender.dist <- data.frame(w_gender = c("M",
                                 "F"),
                        Freq =  c(121469708,
                                  128015520))

##############################
# Survey Weighting
##############################

svy.rake <- rake(design = svy.unweighted,
                       sample.margins = list(~w_race, ~w_gender, ~w_age),
                       population.margins = list(race.dist, gender.dist, age.dist))

##############################
#check for extreme weights
##############################
summary(weights(svy.rake))
#3*median
paste("Trimming needed? = ", median(weights(svy.rake))*3 < max(weights(svy.rake)))

#svy.rake.trim <- trimWeights(svy.rake, lower=0, upper=median(weights(svy.rake))*3, strict=TRUE) 
#summary(weights(svy.rake.trim))

##############################
##############################

svytable(~w_race,svy.rake)
svytable(~w_age,svy.rake)
svytable(~w_gender,svy.rake)
sum(weights(svy.rake))

#Extract Weights out of Survey Design Object
potn_1$base_weight <- 1
potn_1$pop_weight <- weights(svy.rake)
potn_1$scaled_weight <- weights(svy.rake)/sum(weights(svy.rake))*nrow(potn_1)

#Check weights outside of SD object:
aggregate(base_weight ~ w_gender, potn_1, sum)
aggregate(scaled_weight ~ w_gender, potn_1, sum)
aggregate(pop_weight ~ w_gender, potn_1, sum)

#Write weights to CSV
write.csv(potn_1[,c("pop_weight","scaled_weight")], "Weights11.csv")


####################################
#Population Totals Used in Raking
####################################
x<-function(){
"
  Annual Estimates of the Resident Population 2016
  Source: U.S. Census Bureau, Population Division
  
  Release Date: June 2017
  #Age
  18-24	 30843811
  25-34	 44677243
  35-44	 40470156
  45-54	 42786679
  55-64	 41463144
  65+	   49244195
  
  #Race
  White	 191867632
  Black  33200631
  Other	 24416965
  
  #Gender
  Male	 121469708	
  Female 128015520
  
  Note: 
  Race scaled to +18 from full population, 
  Gender represents actual +18 pop
"
}