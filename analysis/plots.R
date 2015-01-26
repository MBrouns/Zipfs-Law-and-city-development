if(!require(reshape2)) install.packages("reshape2")
require(reshape2)
if(!require(ggplot2)) install.packages("ggplot2")
require(ggplot2)


# Build plot for population model
results <- read.csv("popmodel-results.csv")

results$ageGroup <- as.factor(results$ageGroup)
dfm <- melt(results[, c(1, 42:542)], id.vars=c("ageGroup"))
dfm$ageGroup <- as.factor(dfm$ageGroup)

ggplot(dfm, aes(x=as.numeric(variable), y=value, colour=ageGroup)) + 
    geom_line() + 
    xlab("Years") + 
    ylab("# Households") + 
    ggtitle("Behaviour of population model over time")

# Build plot for job 1 and 2 attractiveness
fractionHouseholdsInCity <- c(0, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5)
jobAttractiveness <- c(1, 0.6875, 0.45, 0.425, 0.4, 0.375, 0.35, 0.325, 0.3, 0.275, 0.25)
job12 <- data.frame(fractionHouseholdsInCity, jobAttractiveness)
names(job12) <- c("Frac.households.in.city","job.attractiveness")

ggplot(data=job12, aes(x=Frac.households.in.city, y=job.attractiveness)) + 
    geom_line() +
    xlab("City occupancy rate (households in city / total households)") +
    ylab("Attractiveness of city") +
    ggtitle("Attractiveness of a city for primary sector jobs") +
    annotate("segment", x = 0.1, xend = 0.1, y = 0, yend = 0.45,
           colour = "black", linetype=2) + 
    annotate("segment", x = 0, xend = 0.1, y = 0.45, yend = 0.45,
             colour = "black", linetype=2) + 
    annotate("text", hjust = 0, x = 0.105, y = 0.48, label = "Tippingpoint Y")


# Build plot for job 3 attractiveness
fractionHouseholdsInCity <- c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1)
jobAttractiveness <- c(1, 0.84375, 0.6875, 0.53125, 0.441176471, 0.367647059, 0.294117647, 0.220588235, 0.147058824, 0.073529412, 0)
job3 <- data.frame(fractionHouseholdsInCity, jobAttractiveness)
names(job3) <- c("Frac.people.in.service","job.attractiveness")

ggplot(data=job3, aes(x=Frac.people.in.service, y=job.attractiveness)) + 
    geom_line() +
    xlab("Fraction people in service (People in city in service jobs / total people in city)") +
    ylab("Attractiveness of city") +
    ggtitle("Attractiveness of a city for service jobs") +
    annotate("segment", x = 0.32, xend = 0.32, y = 0, yend = 0.5,
             colour = "black", linetype=2) + 
    annotate("segment", x = 0, xend = 0.32, y = 0.5, yend = 0.5,
             colour = "black", linetype=2) + 
    annotate("text", hjust = 0, x = 0.105, y = 0.45, label = "Tippingpoint Y") + 
    annotate("text", hjust = 0, x = 0.33, y = 0.28, label = "Tippingpoint X")

# Build plot for job 6 attractiveness
fractionHouseholdsInCity <- c(0,0.1,0.2,0.3,0.34,0.4,0.5,0.6,0.7,0.8,0.9,1)
jobAttractiveness <- c(1, 0.852941176, 0.705882353, 0.558823529, 0.5, 0.454545455, 0.378787879, 0.303030303, 0.227272727, 0.151515152, 0.075757576, 0)
job6 <- data.frame(fractionHouseholdsInCity, jobAttractiveness)
names(job6) <- c("Frac.people.in.non.profit","job.attractiveness")

ggplot(data=job6, aes(x=Frac.people.in.non.profit, y=job.attractiveness)) + 
    geom_line() +
    xlab("Fraction people in non-profit (People in city in non-profit jobs / total people in city)") +
    ylab("Attractiveness of city") +
    ggtitle("Attractiveness of a city for non-profit jobs") +
    annotate("segment", x = 0.34, xend = 0.34, y = 0, yend = 0.5,
             colour = "black", linetype=2) + 
    annotate("segment", x = 0, xend = 0.34, y = 0.5, yend = 0.5,
             colour = "black", linetype=2) + 
    annotate("text", hjust = 0, x = 0.105, y = 0.45, label = "Tippingpoint Y") + 
    annotate("text", hjust = 0, x = 0.35, y = 0.28, label = "Tippingpoint X")


# Build plot for job 4 and 5 attractiveness
fractionHouseholdsInCity <- c(0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1)
jobAttractiveness <- c(1, 0.85, 0.7, 0.55, 0.4, 0.5, 0.6, 0.6, 0.6, 0.6, 0.6 )
job45 <- data.frame(fractionHouseholdsInCity, jobAttractiveness)
names(job45) <- c("Frac.people.in.finance.it","job.attractiveness")

ggplot(data=job45, aes(x=Frac.people.in.finance.it, y=job.attractiveness)) + 
    geom_line() +
    xlab("Fraction people in non-profit (People in city in non-profit jobs / total people in city)") +
    ylab("Attractiveness of city") +
    ggtitle("Attractiveness of a city for non-profit jobs") +
    annotate("text", hjust = 0, x = 0.2, y = 0.75, label = "Initially service-like job") + 
    annotate("text", hjust = 0, x = 0.37, y = 0.37, label = "Enough people for service, not yet specialisation level") + 
    annotate("text", hjust = 0, x = 0.6, y = 0.63, label = "Specialisation effect of city up to plateau")


# Build a scatter plot of the city sizes
plotCitySize <- function(row){
    city.sizes <- sort(c(row$City.5, row$City.4, row$City.3, row$City.2, row$City.1), decreasing=T)
    plot(city.sizes)
    
}

# Build plot for resistance-to-move verification
results <- read.csv("rtm-verification-results.csv")
ggplot(data=results, aes(x=Time.since.moving, y=Resistence.to.move)) + 
    geom_line() +
    xlab("Time since Moving") +
    ylab("Resistance to Move") +
    ggtitle("Measured resistance to move for single household") +
    annotate("text", x = 7.2, y = 0.92, label = "Gradually declining slope due to change in age of household members") +
    annotate("text", x = 10, y = 0.62, label = "Childbirth") + 
    annotate("text", x = 19.5, y = 0.78, label = "Plateau  reached")


# Boxplot for showing overall city distribution after parameter  sweep
results <- read.csv("EMA-narrow-results.csv")
dfm <- melt(results, measure.vars=c('City.1','City.2','City.3','City.4','City.5'))
dfm <- dfm[dfm$variable != "City.5", ]
p <- ggplot(dfm, aes(factor(variable), value))
p + geom_boxplot() + 
    xlab("Cities") + 
    ylab("# Households") + 
    ggtitle("Households per city - parameter sweep")



# Faceted line chart for showing results for different number of cities
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

   
# Faceted line chart for showing results for different number of households
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