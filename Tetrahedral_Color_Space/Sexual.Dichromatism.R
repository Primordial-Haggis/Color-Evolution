### Sexual Dichromatism 
setwd("G:/a_Averaged/Sexual Dichromatism")
source("RtcsFunctions.R")	
load("bluetitss.dat")
source("visualization.R")

library(pavo)
library(phytools)



WPTCS <-data.frame(matrix(nrow = 85, ncol = 10))
colnames(WPTCS) <- c("Species","AvgSpan","VarSpan","MaxSpan","Volume","AvgHueDisp","VarHueDisp","MaxHueDisp","AvgBrill","AvgChroma")

filenames <- list.files(path=getwd(),pattern="*.csv") 
numfiles <- length(filenames)  


datalist = list()

for (i in c(1:numfiles)){
  tryCatch({
    print(filenames[i])
    refs <- read.csv(filenames[i], header=TRUE)
    #Get the relative stimulation values for each cone type for each patch.  It requries any reflectance spectra you would like analyzed, and ss, the spectral sensitivities you would like to use.  I have included the bluetit spectral sensitivities.  It will only use 300-700 nm, but data outside of this range can be submitted (it will delete them).  
    refstims <- stim(refs,ss)
    
    #Convert the stimulation values to Cartesian Coordinates (for later analyses)
    refcart <- cartCoord(refstims)
    
    #Converte the Cartesian Coordinates to Sphereical Coordinates (for later analyses)
    refsphere <- sphereCoord(refcart)
    
    #Calculate the maximum possible r-value for each hue (angles from the origin)
    rmax <- rMax(refsphere)
    
    #Calculate the acheived chroma for each patch (r/rmax)
    acheivedr <- acheivedR(refsphere,rmax)
    
    #Normalized brilliance for each patch (aka. brightness)
    normbrill <- normBrill(refs)
    
    #Color volume for all patches submitted (minimum convex polygon of all points in the tetracolorspace)
    vol <- colorVolume(refcart)
    
    #Hue disparity matrix (all patches compared to each other)
    disp <- hueDisp(refsphere)
    
    #Average, variance and maximum hue disparity
    disp.summary <- summary.hueDisp(disp)
    
    #Color span matrix (all patches compared to each other)
    spans <- colorSpan(refcart)
    
    #Average, variance and maximum color span
    spans.summary <- summary.colorSpan(spans)
    
    #Average chroma
    avgChroma(refsphere)
    
    #Average acheived chroma
    avgAcheivedChroma(acheivedr)
    
    #Average brilliance
    avgBrill(normbrill)
    
    #A number of summary measurements from all patches submitted (Average color span, variance in color span, maximum color span, color volume, average hue disparity, variance in hue disparity, maximum hue disparity, average brilliance, average chroma, and average acheived chroma)
    summ <- summaryOfpatches(refs,ss)
    datalist[[i]] <- spans.summary},
    error = function(err) {
      
      print(paste("Didn't work:  ",filenames[i]))
      
    },
    warning = function(warn) {}, finally = {}
  )
}

### Comebine results and write them as csv
data <- do.call(rbind, datalist)
write.csv(data, file = "Spans.csv")