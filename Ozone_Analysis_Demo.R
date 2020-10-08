#University of Toronto-St.George Campus
#Department of Geography and Planning
#James Zhao
#Final Paper-Tropospheric ozone variations at surface and meteorological interpretations

getwd()

#File Import-the datasets are based on same year (2002)
library(sp)
library(spdep)
library(classInt)
library(RColorBrewer)
library(maptools)
library(raster)

o3 <- read.csv("stat_2002.csv", header=TRUE)
attach(o3)
names(o3)
class(o3)

#Create a spatial dataframe using longitude and latitude
ozonemat<-SpatialPointsDataFrame(cbind(lon,lat), data.frame(lon,lat,ozone,elevation,temperature,co2))

nn5 <- knearneigh(ozonemat, k=5)

nn5W<-nb2mat(knn2nb(nn5))

#moran's statistics for independent and dependent parameters
moran.test(ozone,nb2listw(knn2nb(nn5)))
moran.test(elevation,nb2listw(knn2nb(nn5)))
moran.test(temperature,nb2listw(knn2nb(nn5)))
moran.test(co2,nb2listw(knn2nb(nn5)))

#Plot ozone distribution
nclr<-5
plotvar <- ozone
class <- classIntervals(plotvar, nclr, style = "quantile",dataPrecision = 2)
plotclr <- brewer.pal(nclr, "Reds")
colcode <- findColours(class, plotclr, digits = 3)
plot(ozonemat, col = colcode, pch = 15, axes = T,cex=1.5)
title(main = "Ozone Distribution 2002")
legend("topleft", legend = names(attr(colcode, "table")),fill = attr(colcode, "palette"), cex = 0.4)

#Plot elevation
nclr<-5
plotvar <- elevation
class <- classIntervals(plotvar, nclr, style = "quantile",dataPrecision = 2)
plotclr <- brewer.pal(nclr, "Greens")
colcode <- findColours(class, plotclr, digits = 3)
plot(ozonemat, col = colcode, pch = 15, axes = T,cex=1.5)
title(main = "Elevation Distribution")
legend("topleft", legend = names(attr(colcode, "table")),fill = attr(colcode, "palette"), cex = 0.4)

olsres<-lm(ozone~elevation+temperature+co2)
summary(olsres)

#Plot residuals of ozone as response variable
nclr<-5
plotvar1 <- residuals(olsres)
class1 <- classIntervals(plotvar1, nclr, style = "quantile",dataPrecision = 2)
plotclr1 <- brewer.pal(nclr, "Reds")
colcode1 <- findColours(class1, plotclr1, digits = 3)
plot(ozonemat, col = colcode1, pch = 15, axes = T, cex=1.5)
title(main = "OLS Residuals")

moran.test(residuals(olsres),nb2listw(knn2nb(nn5)))

SLres<-lagsarlm(I(ozone/1000)~elevation+temperature+co2,listw=nb2listw(knn2nb(nn5)))
summary(SLres)

#SLres Analysis
nclr<-5
plotvar2 <- residuals(SLres)
class2 <- classIntervals(plotvar2, nclr, style = "quantile",dataPrecision = 5)
plotclr2 <- brewer.pal(nclr, "Reds")
colcode2 <- findColours(class2, plotclr2, digits = 3)
plot(ozonemat, col = colcode2, pch = 15, axes = T, cex=1.5)
title(main = "SL Residuals")
legend("topleft", legend = names(attr(colcode2, "table")),fill = attr(colcode2, "palette"), cex = 0.4)

moran.test(residuals(SLres),nb2listw(knn2nb(nn5)))

#SMres
SEMres<-errorsarlm(I(ozone/1000)~elevation+temperature+co2,listw=nb2listw(knn2nb(nn5)))
summary(SEMres)

res<-lm.LMtests(olsres, listw=nb2listw(knn2nb(nn5)), test="all")
tres<-t(sapply(res, function(x) c(x$statistic, x$parameter, x$p.value)))
colnames(tres)<-c("Statistic", "df", "p-value")
printCoefmat(tres)

res<-lm.LMtests(lm(ozone~elevation+temperature+co2), listw=nb2listw(knn2nb(nn5)), test="all")
tres<-t(sapply(res, function(x) c(x$statistic, x$parameter, x$p.value)))
colnames(tres)<-c("Statistic", "df", "p-value")
printCoefmat(tres)
#END OF SPATIAL ANALYSIS

#Multiple Regression Analysis

#Create a model
m2 <- lm(ozone~elevation+temperature+co2)
summary(m2)
summary(m2)$coefficients

StanRes1 <- rstandard(m2)

# Plot ri versus each X variable
par(mfrow=c(2,2))
plot(elevation,StanRes1, ylab="Standardized Residuals")
plot(temperature,StanRes1, ylab="Standardized Residuals")
plot(co2,StanRes1, ylab="Standardized Residuals")

# Make a response plot (Y vs. Yhat)
par(mfrow=c(1,1))
plot(m2$fitted.values,ozone,xlab="Fitted Values", ylab="ozone (ppbv)")
abline(lsfit(m2$fitted.values,ozone))
# The model shows good sign of linear relationship, which means it is valid

par(mfrow=c(2,2))
plot(elevation,ozone)
abline(lsfit(elevation,ozone))
plot(temperature,ozone)
abline(lsfit(temperature,ozone))
plot(co2,ozone)
abline(lsfit(co2,ozone))

#Diagnostics: Leverages, Homoscedasticity, normality, leverage
par(mfrow=c(1,2))
leverage1 <- hatvalues(m2)
StanRes1a <- rstandard(m2)
residual1 <- m2$residuals
plot(mtt,StanRes1a, ylab="Standardized Residuals")
abline(h=2,lty=2)
abline(h=-2,lty=2)
par(mfrow=c(2,2))
plot(m2)

#Add Variable Plot
library(car)
m3 <- lm(ozone~elevation+temperature+co2)
#Compare the avplots for both model with CT (m3) or without CT (m2)
avPlots(m3,id.method="identify")
avPlots(m2,id.method="identify")
#We can see that CT has no effect on mtt, therefore, taking this predictor out was the correct choice

#Marginal Model Plot
par(mfrow=c(2,2))
mmp(m2,elevation)
mmp(m2,temperature)
mmp(m2,co2)
mmp(m2,m2$fitted.values,xlab="Fitted Values")

#Multicollinearity test

log1 <- log(elevation)
log2 <- log(temperature)
log3 <- log(co2)

summary(powerTransform(cbind(ozone,co2,temperature,elevation)~1,data=o3))
m2a <- lm(log(ozone)~elevation+temperature+co2)
summary(m2a)

X <- cbind(log1,log2,log3)
c <- cor(X)
round(c,2)
#From this correlation table, logO50 and logD50 are highly correlated, which is troubling

par(mfrow=c(2,2))
avPlot(m2a,variable="log(elevation)",ask=FALSE)
avPlot(m2a,variable="log(temperature)",ask=FALSE)
avPlot(m2a,variable="log(co2)",ask=FALSE)
vif(m2a)

detach(o3)
#End of the Code