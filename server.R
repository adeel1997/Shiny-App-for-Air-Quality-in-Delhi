library(shiny)
library(mapview)
library(sp)
library(raster)
library(rgdal)
library(plainview)
library(RColorBrewer)


shinyServer(function(input, output, session) {
    PM25 <- read.csv("data/PM25_Month.csv",col.names = c("Number","Station_Name","Location","Latitude","Longitude",
                                                         "January","February","March","April","May","June","July","August","September","October","November","December"))
    coordinates(PM25) <- ~Longitude + Latitude  
    proj4string(PM25)=CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")
    # Changing the Projection
    PM25_T <- spTransform(PM25, CRS("+proj=utm +zone=43 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))
    
    # Reading the Shape file of Delhi
    Delhi <- readOGR("data/Shape file/delhi.shp")
    Delhi_T <- spTransform(Delhi, CRS("+proj=utm +zone=43 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")) 
    
    grdpts <- makegrid(Delhi_T)
    spgrd <- SpatialPoints(grdpts, proj4string = CRS(proj4string(Delhi_T)))
    spgrdWithin <- SpatialPixels(spgrd[Delhi_T,])
    
    m <- reactive({
        i <- months(input$slider)
        x <- paste(i, "~","1")
        formula <- as.formula(x)
        PM25.idw <- gstat::idw(formula, PM25_T, newdata=spgrdWithin, idp=2.0)
        raster_IDW  <- raster(PM25.idw)
        red_colors <- brewer.pal(9, "Reds") %>%
            colorRampPalette()
        mapview(raster_IDW,alpha=0.4,na.color="transparent",col.regions=red_colors,legend.pos="bottomright",layer.name="PM2.5") + mapview(PM25_T, zcol = "Station_Name",legend=FALSE)
    })
    
    
    output$mapplot <- renderLeaflet({
        m <- m()
        m@map
    })
    
})
