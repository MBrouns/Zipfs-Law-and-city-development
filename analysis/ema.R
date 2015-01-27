if(!require(rpart)) install.packages("rpart")
if(!require(rattle)) install.packages("rattle")
if(!require(rpart.plot)) install.packages("rpart.plot")
if(!require(RColorBrewer)) install.packages("RColorBrewer")
if(!require(doParallel)) install.packages("doParallel")
library(doParallel)
library(rpart)
library(rattle)
library(rpart.plot)
library(RColorBrewer)
if(!require(caret)) install.packages("caret")
if(!require(randomForest)) install.packages("randomForest")
require(caret)
require(randomForest)

cl <- makeCluster(3)
registerDoParallel(cl)
input <- read.csv("long-MC-results.csv")


# Calculate RMSE of model results in comparison with a true zipf's law
calculateZipfFit <- function(row, plot=FALSE) {
    city.sizes <- sort(c(row$City.10, row$City.9, row$City.8, row$City.7, row$City.6, row$City.5, row$City.4, row$City.3, row$City.2, row$City.1), decreasing=T)
    # A = R / P^-a
    expected.city.sizes <- vector()
    for (i in 1:10) { 
        expected.city.sizes <- c(expected.city.sizes, round(1/ (i / (city.sizes[1]))))
        
    }
    if (plot){
    plot(city.sizes)
    lines(expected.city.sizes,col="green")
    }
    rmse <- sqrt(mean((city.sizes-expected.city.sizes)^2))
    
    if (city.sizes[1] < 1000){rmse <- 3000}
    rmse
}


calculateRSquared <- function(row, plot=FALSE) {
    city.sizes <- sort(c(row$City.10, row$City.9, row$City.8, row$City.7, row$City.6, row$City.5, row$City.4, row$City.3, row$City.2, row$City.1), decreasing=T)
    # A = R / P^-a
    expected.city.sizes <- vector()
    for (i in 1:10) { 
        expected.city.sizes <- c(expected.city.sizes, round(1/ (i / (city.sizes[1]))))
        
    }
    
    rsquared <- 1 - round((sum(((city.sizes - expected.city.sizes)^2))/sum(((city.sizes - mean(city.sizes))^2))), 2)
    
    if (city.sizes[1] < 1000){rsquared <- 0}
    
    
    if (plot){
        plot(log(city.sizes), log(1:10), main="Zipf Regression",
             xlab="ln(City Size)", ylab="ln(Rank)")
        mtext(paste("            r^2:", rsquared, sep=" "), 1, adj=0, line=-2)
        lines(log(expected.city.sizes), (log(1:10)),col="green")
        
    }
 
    rsquared
}


for(row in 1:nrow(input)) { 
    input$sse[row] <- calculateZipfFit(input[row, ])
    input$rsquared[row] <- calculateRSquared(input[row, ])
}


input$bin <- cut(input$sse, 
                breaks= c(0, 100, 250, 500, 750, 10000),
                labels=c("1. very good", "2. good", "3. medium", "4. bad","5. very bad"), 
                include.lowest=TRUE
)

input <- input[order(input$sse),] 


# Calculate variable importance using random forest
#myControl = trainControl(method='cv',number=5000,repeats=10,returnResamp='none')
#model2 = train(sse ~ .
               , data=input[ , c(3:45, 60)], method = 'rf', trControl=myControl, importance = TRUE)

#varImp(model2)

stopCluster(cl)


# Build decision tree on results to do multivariate analysis
fit <- rpart(bin ~ .,
             data = input[ , c(3:45, 61)],
             method = "class"
)
fit2 <- prp(fit,snip=TRUE)$obj
prp(fit2, type=0, varlen=0, tweak=0.8, box.col=c("palegreen3", "yellow", "orange", "darkorange","darkorange", "firebrick1","firebrick1", "red")[fit$frame$yval])

#pfit<- prune(fit, cp=0.015)
#pfit <- prp(pfit,snip=TRUE)$obj
# plot the pruned tree 
#fancyRpartPlot(fit)

prp(pfit, type=0, varlen=0, tweak=0.8, box.col=c("palegreen3", "yellow", "orange", "darkorange","darkorange", "firebrick1","firebrick1", "red")[fit$frame$yval])


