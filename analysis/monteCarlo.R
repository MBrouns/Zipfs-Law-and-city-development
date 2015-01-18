# This code is used to perform a monte carlo analysis on the zipf's law Netlogo model
# rf variable importance
# 
# only 20 most important variables shown (out of 34)
# 
# Overall
# job4_Modifier              100.00
# job5_Max                    94.80
# MinDistCityAttractiveness   93.20
# Job6Attractiveness          72.65
# job7_Value                  69.87
# job6_TippingPointX          67.61
# rtm_TippingPointY           60.49
# job2_TippingPointY          53.69
# Job3Attractiveness          52.89
# job5_TippingPointY          52.23
# job4_TippingPointY          51.77
# job3_TippingPointX          51.18
# rtm_PlateauPointX           47.68
# Job7Attractiveness          46.53
# job4_TippingPointX          46.48
# MinimalMovingDistance       45.00
# MaxDistCityAttractiveness   41.12
# rtm_PlateauPointY           39.18
# job4_Max                    32.70
# minDistBetweenCities        31.32


# Analysis setup
noOfReplications <- 100
runsToDo <- c(28:36)
runName <- "EMA-narrow"
seed <- 1338
nl.path <- "C:/Program Files (x86)/NetLogo 5.1.0"
model.path <- "C:/Users/Matthijs/Documents/GitHub/Zipfs-Law-and-city-development/netlogo/model.nlogo"
model.runtime <- 80
model.warmup <- 2
variables <- NULL


variables <- rbind(variables, c("job4_Modifier", 8, 12))
variables <- rbind(variables, c("job5_Max", 0.5, 0.8))
variables <- rbind(variables, c("MinDistCityAttractiveness", 0.05, 0.3))
variables <- rbind(variables, c("Job6Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("job7_Value", 0.4, 0.6))
variables <- rbind(variables, c("job6_TippingPointX", 0.2, 0.4))
variables <- rbind(variables, c("rtm_TippingPointY", 0.25, 0.75))
variables <- rbind(variables, c("job2_TippingPointY", 0.4, 0.4))
variables <- rbind(variables, c("Job3Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("job5_TippingPointY", 0.4, 0.6))
variables <- rbind(variables, c("minDistBetweenCities", 10, 250))
variables <- rbind(variables, c("maxDistBetweenCities", 10, 500))

variables <- rbind(variables, c("rtm_TippingPointX", 10, 10))
variables <- rbind(variables, c("rtm_PlateauPointX", 20, 20))
variables <- rbind(variables, c("rtm_PlateauPointY", 0.75, 75))
variables <- rbind(variables, c("rtm_AgeModifier", 0.16, 0.16))
variables <- rbind(variables, c("rtm_ResistancePerChild", 0.05, 0.05))
variables <- rbind(variables, c("MinimalMovingDistance", 100, 100))
variables <- rbind(variables, c("MaximumMovingDistance", 250, 250))
variables <- rbind(variables, c("MaxDistCityAttractiveness", 0.1, 0.1))
variables <- rbind(variables, c("Job1Attractiveness", 0.5, 0.5))
variables <- rbind(variables, c("Job2Attractiveness", 0.5, 0.5))
variables <- rbind(variables, c("Job4Attractiveness", 0.5, 0.5))
variables <- rbind(variables, c("Job5Attractiveness", 0.5, 0.5))
variables <- rbind(variables, c("Job7Attractiveness", 0.5, 0.5))
variables <- rbind(variables, c("job1_TippingPointY", 0.5, 0.5))
variables <- rbind(variables, c("job3_TippingPointX", 0.3, 0.3))
variables <- rbind(variables, c("job3_TippingPointY", 0.5, 0.5))
variables <- rbind(variables, c("job4_TippingPointX", 0.04, 0.04))
variables <- rbind(variables, c("job4_TippingPointY", 0.5, 0.5))
variables <- rbind(variables, c("job4_Max", 0.6, 0.6))
variables <- rbind(variables, c("job5_TippingPointX", 0.04, 0.04))
variables <- rbind(variables, c("job5_Modifier", 10, 10))
variables <- rbind(variables, c("job6_TippingPointY", 0.5, 0.5))


variables <- rbind(variables, c("Seed", seed, seed))
variables <- rbind(variables, c("NumberOfYears", model.runtime, model.runtime))
variables <- rbind(variables, c("WarmUpTime", model.warmup, model.warmup))

options(java.parameters=c("-XX:MaxPermSize=512m","-Xmx4096m"))
#Install required packages if necessary and load them
if(!require(RNetLogo)) install.packages("RNetLogo")
library(RNetLogo)
if(!require(lhs)) install.packages("lhs")
library(lhs)
if(!require(doParallel)) install.packages("doParallel")
library(doParallel)
if(!require(foreach)) install.packages("foreach")
library(foreach)
if(!require(rJava)) install.packages("rJava")
library(rJava)


cl<-makeCluster(3, outfile="clusterlog.txt") #change the 2 to your number of CPU cores
registerDoParallel(cl)

set.seed(seed)
# Create a Latin Hypercube sample to populate model with
lhs <- data.frame(randomLHS(noOfReplications, nrow(variables), preserveDraw=T))
names(lhs) <- variables[, 1]

# Transform the LHS to the correct minimum and maximum values
for (index in 1:nrow(variables)) { 
    row = variables[index, ]; # do stuff with the row 
    min <- as.numeric(variables[index, 2])
    max <- as.numeric(variables[index, 3])                
    lhs[, c(variables[index, 1])] <- sapply(lhs[, c(variables[index, 1])], function(x){
        x <- x * (max - min) + min 
        })
} 

# Run the models and store the results in a Data Frame
results <- NULL
results <- data.frame(results)


start.time <- Sys.time()

results <- foreach(i=runsToDo, .errorhandling="remove", .combine='rbind', .packages=c("RNetLogo","rJava")) %dopar% {
    tryCatch({
        options(java.parameters=c("-XX:MaxPermSize=512m","-Xmx4096m"))
        print(paste("starting job", i, sep=" "))
        #run the model here
        # create a second NetLogo instance in headless mode (= without GUI) 
        # stored in a variable
        nlheadless1 <- paste("nlheadless", i, sep="")
        NLStart(nl.path, gui=F, nl.obj=nlheadless1)
        
        NLLoadModel(model.path, nl.obj=nlheadless1)
        NLCommand("no-display", nl.obj=nlheadless1)
       
        
        for (j in 1:ncol(lhs)) {    
            NLCommand(paste("set", names(lhs)[j], lhs[i, j], sep = " "), nl.obj=nlheadless1)
        }
        
        NLCommand("setup", nl.obj=nlheadless1)
        
        NLDoCommand(model.runtime, "go", nl.obj=nlheadless1)
        
        city0Size <- NLReport("count turtles with [cityIdentifier = 0]", nl.obj=nlheadless1)
        city1Size <- NLReport("count turtles with [cityIdentifier = 1]", nl.obj=nlheadless1)
        city2Size <- NLReport("count turtles with [cityIdentifier = 2]", nl.obj=nlheadless1)
        city3Size <- NLReport("count turtles with [cityIdentifier = 3]", nl.obj=nlheadless1)
        city4Size <- NLReport("count turtles with [cityIdentifier = 4]", nl.obj=nlheadless1)
        city5Size <- NLReport("count turtles with [cityIdentifier = 5]", nl.obj=nlheadless1)
        
        
        result <- data.frame(c(lhs[i, ], city0Size, city1Size, city2Size, city3Size, city4Size, city5Size))
        names(result) <- c(names(lhs), "City 0", "City 1", "City 2","City 3","City 4","City 5")
        NLQuit(nl.obj=nlheadless1)
        result
        
    }, warning = function(err){
        print(paste("Error in task", i, err, sep=" "))
        c(names(lhs), NA, NA, NA, NA, NA, NA)
    })
  
}

write.table(results, file=paste(runName, "-results",".csv", sep=""), append=TRUE, sep=", ", col.names=FALSE, row.names=FALSE)
NLQuit(all=TRUE)
stopCluster(cl)
end.time <- Sys.time()
time.taken <- end.time - start.time 
time.taken
