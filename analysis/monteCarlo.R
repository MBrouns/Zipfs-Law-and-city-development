# This code is used to perform a monte carlo analysis on the zipf's law Netlogo model

# Analysis setup
noOfReplications <- 1
seed <- 1337
nl.path <- "C:/Program Files (x86)/NetLogo 5.1.0"
model.path <- "E:/Documents/SkyDrive/TU Delft/Jaar 5/Zipfs-Law-and-city-development/netlogo/model.nlogo"
variables <- NULL
variables <- rbind(variables, c("variable1", 3, 5))
variables <- rbind(variables, c("variable2", 10, 20))

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
cl<-makeCluster(2) #change the 2 to your number of CPU cores
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
results <- foreach(i=1:noOfReplications, .combine='rbind', .export=c("NLStart","NLLoadModel","NLCommand","NLDoReport", "NLQuit", "NLReport", "NLDoCommand")) %dopar% {
    options(java.parameters=c("-XX:MaxPermSize=512m","-Xmx4096m"))
    print("starting job", i)
    #run the model here
    # create a second NetLogo instance in headless mode (= without GUI) 
    # stored in a variable
    nlheadless1 <- paste("nlheadless", i, sep="")
    NLStart(nl.path, gui=F, nl.obj=nlheadless1)
    
    NLLoadModel(model.path, nl.obj=nlheadless1)
    NLCommand("no-display", nl.obj=nlheadless1)
    NLCommand("setup", nl.obj=nlheadless1)
    

    NLDoCommand(10, "go", nl.obj=nlheadless1)
    
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
}

NLQuit(all=TRUE)
stopCluster(cl)
end.time <- Sys.time()
time.taken <- end.time - start.time 
time.taken
