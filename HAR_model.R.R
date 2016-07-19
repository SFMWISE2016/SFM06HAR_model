# Clear enviorenment
graphics.off()
rm(list = ls())

# import the data realized_library of realized_library from text files
# Load packages
library(zoo)
library(xts)
library(highfrequency)

# Select Dow Jones
realized_library$V1 = as.Date(as.character(realized_library$V1),"%Y%m%d")
realized.xts = xts(realized_library[,-1],realized_library$V1)
DJI_RV = realized.xts$V2

# Remove NA's
DJI_RV = DJI_RV[!is.na(DJI_RV)]

# Select data from 20150701 to 20160630
DJI_RV = DJI_RV["2015-07-01/2016-06-30"]
head(DJI_RV)
class(DJI_RV)

# Apply har model
DJ   = harModel(data = DJI_RV, periods = c(1, 5, 22), RVest = c("rCov"), 
                type = "HARRV", h = 1, transform = NULL)
summary(DJ)
png(file = "DJ1.png")
plot(DJ,xlab="2015-07-01/2016-06-30")

dev.off()

realized_library <- read.csv("C:/Users/julytang/Desktop/realized_library.csv", header=FALSE)
View(realized_library)