# This code is used to perform a monte carlo analysis on the zipf's law Netlogo model

# Analysis setup
noOfReplications <- 50
seed <- 20454
nl.path <- "C:/Program Files (x86)/NetLogo 5.1.0"
model.path <- "E:/Documents/SkyDrive/TU Delft/Jaar 5/Zipfs-Law-and-city-development/netlogo/model.nlogo"
model.runtime <- 80
model.warmup <- 2
variables <- NULL


variables <- rbind(variables, c("rtm_TippingPointX", 5, 15))
variables <- rbind(variables, c("rtm_TippingPointY", 0.25, 0.75))
variables <- rbind(variables, c("rtm_PlateauPointX", 15, 25))
variables <- rbind(variables, c("rtm_PlateauPointY", 0.5, 1))
variables <- rbind(variables, c("rtm_AgeModifier", 0.01, 0.3))
variables <- rbind(variables, c("rtm_ResistancePerChild", 0, 0.1))
variables <- rbind(variables, c("minDistBetweenCities", 10, 250))
variables <- rbind(variables, c("maxDistBetweenCities", 10, 500))
variables <- rbind(variables, c("MinimalMovingDistance", 10, 200))
variables <- rbind(variables, c("MaximumMovingDistance", 200, 400))
variables <- rbind(variables, c("MinDistCityAttractiveness", 0.05, 0.3))
variables <- rbind(variables, c("MaxDistCityAttractiveness", 0.05, 0.3))
variables <- rbind(variables, c("Job1Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("Job2Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("Job3Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("Job4Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("Job5Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("Job6Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("Job7Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("job1_TippingPointY", 0.4, 0.6))
variables <- rbind(variables, c("job2_TippingPointY", 0.4, 0.4))
variables <- rbind(variables, c("job3_TippingPointX", 0.2, 0.4))
variables <- rbind(variables, c("job3_TippingPointY", 0.4, 0.6))
variables <- rbind(variables, c("job4_TippingPointX", 0.02, 0.06))
variables <- rbind(variables, c("job4_TippingPointY", 0.4, 0.6))
variables <- rbind(variables, c("job4_Modifier", 8, 12))
variables <- rbind(variables, c("job4_Max", 0.5, 0.8))
variables <- rbind(variables, c("job5_TippingPointX", 0.02, 0.06))
variables <- rbind(variables, c("job5_TippingPointY", 0.4, 0.6))
variables <- rbind(variables, c("job5_Modifier", 8, 12))
variables <- rbind(variables, c("job5_Max", 0.5, 0.8))
variables <- rbind(variables, c("job6_TippingPointX", 0.2, 0.4))
variables <- rbind(variables, c("job6_TippingPointY", 0.4, 0.6))
variables <- rbind(variables, c("job7_Value", 0.4, 0.6))


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
library(rJava)


set.seed(seed)
cl<-makeCluster(2, outfile="clusterlog.txt") #change the 2 to your number of CPU cores
registerDoParallel(cl)

# Create a Latin Hypercube sample to populate model with
lhs <- data.frame(randomLHS(noOfReplications, nrow(variables)))
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

results <- foreach(i=1:noOfReplications, .errorhandling="remove", .combine='rbind', .packages=c("RNetLogo","rJava")) %dopar% {
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

write.table(results, file=paste("results-",format(Sys.time(), "%b-%d-%H%M%S-%Y"),".csv", sep=""))
NLQuit(all=TRUE)
stopCluster(cl)
end.time <- Sys.time()
time.taken <- end.time - start.time 
time.taken
