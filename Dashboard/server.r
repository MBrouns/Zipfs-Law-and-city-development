if(!require(RNetLogo)) install.packages("RNetLogo")
library(RNetLogo)

nl.path <- "C:/Program Files (x86)/NetLogo 5.1.0"
NLStart(nl.path, gui=T, nl.obj=nlheadless1)


model.path <- "../netlogo/model.nlogo"
nlheadless1 <- "nlheadless1"
NLLoadModel(paste(nl.path,model.path,sep=""))
NLCommand("setup")


