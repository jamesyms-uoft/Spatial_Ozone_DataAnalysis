#University of Toronto-St.George Campus
#Department of Geography and Planning
#Thesis material-Moran's I Test
#Yue Zhao 1000449963

getwd()

#File Import-Ozone dataset
library(sp)
library(spdep)
library(classInt)
library(RColorBrewer)
library(maptools)
library(raster)

o3 <- read.csv("Moranina8.csv", header=TRUE)
attach(o3)
names(o3)
class(o3)

#Create a spatial dataframe using longitude and latitude
ozonemat<-SpatialPointsDataFrame(cbind(lon,lat), data.frame(lon,lat,ozone))

nn5 <- knearneigh(ozonemat, k=5)

nn5W<-nb2mat(knn2nb(nn5))
#moran's statistics for independent and dependent parameters
moran.test(ozone,nb2listw(knn2nb(nn5)))


#Plot ozone distribution
nclr<-5
plotvar <- ozone
class <- classIntervals(plotvar, nclr, style = "quantile",dataPrecision = 2)
plotclr <- brewer.pal(nclr, "Reds")
colcode <- findColours(class, plotclr, digits = 3)
plot(ozonemat, col = colcode, pch = 15, axes = T,cex=1.5)
title(main = "Long Term NA Ozone Distribution-8 km")
legend("topleft", legend = names(attr(colcode, "table")),fill = attr(colcode, "palette"), cex = 0.6)

