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
input <- read.csv("ema-narrow-results.csv")

calculateZipfFit <- function(row) {
    
    city.sizes <- sort(c(row$City.5, row$City.4, row$City.3, row$City.2, row$City.1), decreasing=T)
    
    # A = R / P^-a
    expected.city.sizes <- vector()
    for (i in 1:5) { 
        expected.city.sizes <- c(expected.city.sizes, round(1/ (i / (city.sizes[1]))))
        
    }
    rmse <- sqrt(mean((city.sizes-expected.city.sizes)^2))
    
    rmse
}

plotCitySize <- function(row){
    city.sizes <- sort(c(row$City.5, row$City.4, row$City.3, row$City.2, row$City.1), decreasing=T)
    plot(city.sizes)
    
}
for(row in 1:nrow(input)) { 
    input$sse[row] <- calculateZipfFit(input[row, ])
}

input$bin <- cut(input$sse, 
                breaks= 10,
                include.lowest=TRUE
)

myControl = trainControl(method='cv',number=5000,repeats=10,returnResamp='none')
model2 = train(sse ~ rtm_TippingPointX +
                   rtm_TippingPointY + 
                   rtm_PlateauPointX +
                   rtm_PlateauPointY +
                   rtm_AgeModifier +
                   rtm_ResistancePerChild +
                   minDistBetweenCities +
                   maxDistBetweenCities +
                   MinimalMovingDistance + 
                   MaximumMovingDistance +
                   MinDistCityAttractiveness +
                   MaxDistCityAttractiveness +
                   Job1Attractiveness +
                   Job2Attractiveness +
                   Job3Attractiveness +
                   Job4Attractiveness + 
                   Job5Attractiveness + 
                   Job6Attractiveness + 
                   Job7Attractiveness +
                   job1_TippingPointY +
                   job2_TippingPointY +
                   job3_TippingPointX +
                   job3_TippingPointY +
                   job4_TippingPointX + 
                   job4_TippingPointY +
                   job4_Modifier +
                   job4_Max +
                   job5_TippingPointX +
                   job5_TippingPointY +
                   job5_Modifier +
                   job5_Max +
                   job6_TippingPointX +
                   job6_TippingPointY +
                   job7_Value
               , data=input, method = 'rf', trControl=myControl, importance = TRUE)

varImp(model2)

stopCluster(cl)

fit <- rpart(bin ~ rtm_TippingPointX +
                 rtm_TippingPointY + 
                 rtm_PlateauPointX +
                 rtm_PlateauPointY +
                 rtm_AgeModifier +
                 rtm_ResistancePerChild +
                 minDistBetweenCities +
                 maxDistBetweenCities +
                 MinimalMovingDistance + 
                 MaximumMovingDistance +
                 MinDistCityAttractiveness +
                 MaxDistCityAttractiveness +
                 Job1Attractiveness +
                 Job2Attractiveness +
                 Job3Attractiveness +
                 Job4Attractiveness + 
                 Job5Attractiveness + 
                 Job6Attractiveness + 
                 Job7Attractiveness +
                 job1_TippingPointY +
                 job2_TippingPointY +
                 job3_TippingPointX +
                 job3_TippingPointY +
                 job4_TippingPointX + 
                 job4_TippingPointY +
                 job4_Modifier +
                 job4_Max +
                 job5_TippingPointX +
                 job5_TippingPointY +
                 job5_Modifier +
                 job5_Max +
                 job6_TippingPointX +
                 job6_TippingPointY +
                 job7_Value,
             data = input,
             method = "class"
)

#pfit<- prune(fit, cp=   fit$cptable[which.min(fit$cptable[,"xerror"]),"CP"])
#pfit <- prp(pfit,snip=TRUE)$obj
# plot the pruned tree 
#fancyRpartPlot(fit)


prp(fit, type=0, varlen=0, tweak=0.8, box.col=c("palegreen3", "yellow", "orange", "darkorange","darkorange", "firebrick1","firebrick1", "red")[fit$frame$yval])


