# This code is used to perform a monte carlo analysis on the zipf's law Netlogo model
# rf variable importance


# Analysis setup
storeAllValues <- F
noOfReplications <- 300
runsToDo <- c(1:6)
runsPerRep <- 6
runName <- "long-MC"
seed <- 1338
nl.path <- "C:/Program Files (x86)/NetLogo 5.1.0"
model.path <- "C:/Users/Matthijs/Documents/GitHub/Zipfs-Law-and-city-development/netlogo/model.nlogo"
model.runtime <- 80
model.warmup <- 2
variables <- NULL

variables <- rbind(variables, c("noOfCities", 10, 10))
variables <- rbind(variables, c("noOfHouseholds", 20000, 20000))

variables <- rbind(variables, c("cityAttractivenessBySize_Weight", 0, 1))
variables <- rbind(variables, c("cityAttractivenessBySize_StartY", 0.4, 0.6))
variables <- rbind(variables, c("cityAttractivenessBySize_TippingPointX", 0.2, 0.8))
variables <- rbind(variables, c("cityAttractivenessBySize_TippingPointY", 0.6, 0.8))
variables <- rbind(variables, c("cityAttractivenessBySize_EndY", 0.8, 1))

variables <- rbind(variables, c("borrowedUtilityMaxDistance", 50, 250))
variables <- rbind(variables, c("borrowedUtilityWeight", 0, 0.25))

variables <- rbind(variables, c("populationGrowth", 1, 1.01))
variables <- rbind(variables, c("job4_Modifier", 8, 12))
variables <- rbind(variables, c("job4_Modifier", 8, 12))
variables <- rbind(variables, c("job5_Max", 0.5, 0.8))
variables <- rbind(variables, c("MinDistCityAttractiveness", 0.01, 0.5))
variables <- rbind(variables, c("Job6Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("job7_Value", 0.4, 0.6))
variables <- rbind(variables, c("job6_TippingPointX", 0.2, 0.4))
variables <- rbind(variables, c("rtm_TippingPointY", 0.25, 0.75))
variables <- rbind(variables, c("job2_TippingPointY", 0.4, 0.6))
variables <- rbind(variables, c("Job3Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("job5_TippingPointY", 0.4, 0.6))
variables <- rbind(variables, c("minDistBetweenCities", 30, 150))
variables <- rbind(variables, c("maxDistBetweenCities", 200, 500))
variables <- rbind(variables, c("rtm_TippingPointX", 5, 15))
variables <- rbind(variables, c("rtm_PlateauPointX", 15, 25))
variables <- rbind(variables, c("rtm_PlateauPointY", 0.5, 1))
variables <- rbind(variables, c("rtm_AgeModifier", 0.01, 0.3))
variables <- rbind(variables, c("rtm_ResistancePerChild", 0.01, 0.3))
variables <- rbind(variables, c("MinimalMovingDistance", 1, 200))
variables <- rbind(variables, c("MaximumMovingDistance", 200, 400))
variables <- rbind(variables, c("MaxDistCityAttractiveness", 0.01, 0.5))
variables <- rbind(variables, c("Job1Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("Job2Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("Job4Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("Job5Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("Job7Attractiveness", 0.4, 0.6))
variables <- rbind(variables, c("job1_TippingPointY", 0.4, 0.6))
variables <- rbind(variables, c("job3_TippingPointX", 0.2, 0.4))
variables <- rbind(variables, c("job3_TippingPointY", 0.4, 0.6))
variables <- rbind(variables, c("job4_TippingPointX", 0.01, 0.1))
variables <- rbind(variables, c("job4_TippingPointY", 0.4, 0.6))
variables <- rbind(variables, c("job4_Max", 0.5, 0.8))
variables <- rbind(variables, c("job5_TippingPointX", 0.01, 0.1))
variables <- rbind(variables, c("job5_Modifier", 8, 12))
variables <- rbind(variables, c("job6_TippingPointY", 0.4, 0.6))


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


start.time <- Sys.time()


for (repetitionIterator in 1:ceiling(noOfReplications/runsPerRep)){
    print(paste("starting jobs", runsToDo, sep=" "))
    
    cl<-makeCluster(3, outfile="clusterlog.txt") #change the 2 to your number of CPU cores
    registerDoParallel(cl)
    
    results <- NULL
    results <- data.frame(results)
    
    
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
            
            if(storeAllValues){
                
                city0Size <- NLReport("count turtles with [cityIdentifier = 0]", nl.obj=nlheadless1)
                city1Size <- NLReport("count turtles with [cityIdentifier = 1]", nl.obj=nlheadless1)
                city2Size <- NLReport("count turtles with [cityIdentifier = 2]", nl.obj=nlheadless1)
                city3Size <- NLReport("count turtles with [cityIdentifier = 3]", nl.obj=nlheadless1)
                city4Size <- NLReport("count turtles with [cityIdentifier = 4]", nl.obj=nlheadless1)
                city5Size <- NLReport("count turtles with [cityIdentifier = 5]", nl.obj=nlheadless1)
                city6Size <- NLReport("count turtles with [cityIdentifier = 6]", nl.obj=nlheadless1)
                city7Size <- NLReport("count turtles with [cityIdentifier = 7]", nl.obj=nlheadless1)
                city8Size <- NLReport("count turtles with [cityIdentifier = 8]", nl.obj=nlheadless1)
                city9Size <- NLReport("count turtles with [cityIdentifier = 9]", nl.obj=nlheadless1)
                city10Size <- NLReport("count turtles with [cityIdentifier = 10]", nl.obj=nlheadless1)
                city11Size <- NLReport("count turtles with [cityIdentifier = 11]", nl.obj=nlheadless1)
                city12Size <- NLReport("count turtles with [cityIdentifier = 12]", nl.obj=nlheadless1)
                city13Size <- NLReport("count turtles with [cityIdentifier = 13]", nl.obj=nlheadless1)
                city14Size <- NLReport("count turtles with [cityIdentifier = 14]", nl.obj=nlheadless1)
                city15Size <- NLReport("count turtles with [cityIdentifier = 15]", nl.obj=nlheadless1)
                city16Size <- NLReport("count turtles with [cityIdentifier = 16]", nl.obj=nlheadless1)
                city17Size <- NLReport("count turtles with [cityIdentifier = 17]", nl.obj=nlheadless1)
                city18Size <- NLReport("count turtles with [cityIdentifier = 18]", nl.obj=nlheadless1)
                city19Size <- NLReport("count turtles with [cityIdentifier = 19]", nl.obj=nlheadless1)
                city20Size <- NLReport("count turtles with [cityIdentifier = 20]", nl.obj=nlheadless1)
                city21Size <- NLReport("count turtles with [cityIdentifier = 21]", nl.obj=nlheadless1)
                city22Size <- NLReport("count turtles with [cityIdentifier = 22]", nl.obj=nlheadless1)
                city23Size <- NLReport("count turtles with [cityIdentifier = 23]", nl.obj=nlheadless1)
                city24Size <- NLReport("count turtles with [cityIdentifier = 24]", nl.obj=nlheadless1)
                city25Size <- NLReport("count turtles with [cityIdentifier = 25]", nl.obj=nlheadless1)
                
                for (k in 1:model.runtime){
                    NLCommand("go", nl.obj=nlheadless1)
                    
                    city0Size <- c(city0Size, NLReport("count turtles with [cityIdentifier = 0]", nl.obj=nlheadless1))
                    city1Size <- c(city1Size , NLReport("count turtles with [cityIdentifier = 1]", nl.obj=nlheadless1))
                    city2Size <- c(city2Size , NLReport("count turtles with [cityIdentifier = 2]", nl.obj=nlheadless1))
                    city3Size <- c(city3Size , NLReport("count turtles with [cityIdentifier = 3]", nl.obj=nlheadless1))
                    city4Size <- c(city4Size , NLReport("count turtles with [cityIdentifier = 4]", nl.obj=nlheadless1))
                    city5Size <- c(city5Size , NLReport("count turtles with [cityIdentifier = 5]", nl.obj=nlheadless1))
                    city6Size <- c(city6Size , NLReport("count turtles with [cityIdentifier = 6]", nl.obj=nlheadless1))
                    city7Size <- c(city7Size , NLReport("count turtles with [cityIdentifier = 7]", nl.obj=nlheadless1))
                    city8Size <- c(city8Size , NLReport("count turtles with [cityIdentifier = 8]", nl.obj=nlheadless1))
                    city9Size <- c(city9Size , NLReport("count turtles with [cityIdentifier = 9]", nl.obj=nlheadless1))
                    city10Size <- c(city10Size , NLReport("count turtles with [cityIdentifier = 10]", nl.obj=nlheadless1))
                    city11Size <- c(city11Size , NLReport("count turtles with [cityIdentifier = 11]", nl.obj=nlheadless1))
                    city12Size <- c(city12Size , NLReport("count turtles with [cityIdentifier = 12]", nl.obj=nlheadless1))
                    city13Size <- c(city13Size , NLReport("count turtles with [cityIdentifier = 13]", nl.obj=nlheadless1))
                    city14Size <- c(city14Size , NLReport("count turtles with [cityIdentifier = 14]", nl.obj=nlheadless1))
                    city15Size <- c(city15Size , NLReport("count turtles with [cityIdentifier = 15]", nl.obj=nlheadless1))
                    city16Size <- c(city16Size , NLReport("count turtles with [cityIdentifier = 16]", nl.obj=nlheadless1))
                    city17Size <- c(city17Size , NLReport("count turtles with [cityIdentifier = 17]", nl.obj=nlheadless1))
                    city18Size <- c(city18Size , NLReport("count turtles with [cityIdentifier = 18]", nl.obj=nlheadless1))
                    city19Size <- c(city19Size , NLReport("count turtles with [cityIdentifier = 19]", nl.obj=nlheadless1))
                    city20Size <- c(city20Size , NLReport("count turtles with [cityIdentifier = 20]", nl.obj=nlheadless1))
                    city21Size <- c(city21Size , NLReport("count turtles with [cityIdentifier = 21]", nl.obj=nlheadless1))
                    city22Size <- c(city22Size , NLReport("count turtles with [cityIdentifier = 22]", nl.obj=nlheadless1))
                    city23Size <- c(city23Size , NLReport("count turtles with [cityIdentifier = 23]", nl.obj=nlheadless1))
                    city24Size <- c(city24Size , NLReport("count turtles with [cityIdentifier = 24]", nl.obj=nlheadless1))
                    city25Size <- c(city25Size , NLReport("count turtles with [cityIdentifier = 25]", nl.obj=nlheadless1))
                    
                }
                
                for (k in 1:model.runtime){
                    NLCommand("go", nl.obj=nlheadless1)
                }
                names(result) <- c("runNo", names(lhs), c(1:model.runtime))
                result <- rbind(result, setNames(c(i, lhs[i, ], city1Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city2Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city3Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city4Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city5Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city6Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city7Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city8Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city9Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city10Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city11Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city12Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city13Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city14Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city15Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city16Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city17Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city18Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city19Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city20Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city21Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city22Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city23Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city24Size), names(result)))
                result <- rbind(result, setNames(c(i, lhs[i, ], city25Size), names(result)))
            }else{
                
                
                NLDoCommand(model.runtime, "go", nl.obj=nlheadless1)
                city0Size <- NLReport("count turtles with [cityIdentifier = 0]", nl.obj=nlheadless1)
                city1Size <- NLReport("count turtles with [cityIdentifier = 1]", nl.obj=nlheadless1)
                city2Size <- NLReport("count turtles with [cityIdentifier = 2]", nl.obj=nlheadless1)
                city3Size <- NLReport("count turtles with [cityIdentifier = 3]", nl.obj=nlheadless1)
                city4Size <- NLReport("count turtles with [cityIdentifier = 4]", nl.obj=nlheadless1)
                city5Size <- NLReport("count turtles with [cityIdentifier = 5]", nl.obj=nlheadless1)
                city6Size <- NLReport("count turtles with [cityIdentifier = 6]", nl.obj=nlheadless1)
                city7Size <- NLReport("count turtles with [cityIdentifier = 7]", nl.obj=nlheadless1)
                city8Size <- NLReport("count turtles with [cityIdentifier = 8]", nl.obj=nlheadless1)
                city9Size <- NLReport("count turtles with [cityIdentifier = 9]", nl.obj=nlheadless1)
                city10Size <- NLReport("count turtles with [cityIdentifier = 10]", nl.obj=nlheadless1)
                
                
                result <- data.frame(c(lhs[i, ], city0Size, city1Size, city2Size, city3Size, city4Size, city5Size, city6Size, city7Size, city8Size, city9Size, city10Size))
                names(result) <- c(names(lhs), "City 0", "City 1", "City 2","City 3","City 4","City 5", "City 6","City 7","City 8","City 9","City 10")
                
            }
            
            
            
            
            NLQuit(nl.obj=nlheadless1)
            result
            
        }, warning = function(err){
            print(paste("Error in task", i, err, sep=" "))
            c(names(lhs), NA, NA, NA, NA, NA, NA)
        })
        
    }
    #results <- cbind(rep(0:25, 9), results)
    #names(results)[names(results) == 'rep(0:25, 9)'] <- 'City'
    write.table(results, file=paste(runName, "-results",".csv", sep=""), append=TRUE, sep=", ", col.names=T, row.names=FALSE)
    NLQuit(all=TRUE)
    stopCluster(cl)
    
    
    
    runsToDo <- runsToDo + runsPerRep
    runsToDo <- runsToDo[runsToDo <= noOfReplications]
}
end.time <- Sys.time()



time.taken <- end.time - start.time 
time.taken
