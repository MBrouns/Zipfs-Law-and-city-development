if(!require(reshape2)) install.packages("reshape2")
require(reshape2)
if(!require(ggplot2)) install.packages("ggplot2")
require(ggplot2)

results <- read.csv("EV-testing-cities-results.csv")
results <- cbind(rep(0:25, 24), results)
names(results)[names(results) == 'rep(0:25, 24)'] <- 'City'
results <- results[results$noOfCities %in% c(1, 2, 3, 4, 5, 10, 15, 20, 25), ]
results <- results[results$City != 0, ]
results <- results[results$X1 != 0, ]


    results$City <- as.factor(results$City)
    results <- results[order(results$noOfCities),]
    results$noOfCities <- round(results$noOfCities)
    dfm <- melt(results[, c(1, 3, 42:121)], id.vars=c("City", "noOfCities"))
    

    ggplot(dfm[dfm$City != 0, ], aes(x=as.numeric(variable), y=value, colour=City)) + 
        geom_line() + 
        xlab("Years") + 
        ylab("# Households") + 
        ggtitle("City Sizes over time for varying number of cities in model") +
        facet_wrap( ~ noOfCities, ncol=3)

   
results <- read.csv("EV-testing-households-results.csv")
#names(results)[names(results) == 'rep.0.5..9.'] <- 'City'
results <- results[results$City != 0, ]
results <- results[results$X1 != 0, ]

results$City <- as.factor(results$City)
results <- results[order(results$noOfHouseholds),]
results$noOfHouseholds <- round(results$noOfHouseholds)

dfm <- melt(results[, c(1, 4, 42:121)], id.vars=c("City", "noOfHouseholds"))
   
    
ggplot(dfm[dfm$City != 0, ], aes(x=as.numeric(variable), y=value, colour=City)) + 
    geom_line() + 
    xlab("Years") + 
    ylab("# Households") + 
    ggtitle("City Sizes over time for varying number of households in model") +
    facet_wrap( ~ noOfHouseholds, ncol=5)