#' @title readLPJmL4
#' @description Read LPJmL 4 content
#' @param subtype Switch between diffrent input
#' @return List of magpie objects with results on cellular level, weight, unit and description.
#' @author Kristine Karstens
#' @seealso
#' \code{\link{readLPJmL5}},
#' \code{\link{readLPJ}}
#' @examples
#'
#' \dontrun{
#' readSource("LPJmL4", subtype="maize_mrh")
#' }
#'
#' @import madrat
#' @import magclass
#' @importFrom lpjclass readLPJ

readLPJmL4 <- function(subtype="soilc"){
  
  folder <- "CRU4p02_2019_11_07/"
  
  files <- c(soilc           = "soilc_natveg.bin",
             soilc_layer     = "soilc_layer_natveg.bin",
             litc            = "litc_natveg.bin",
             vegc            = "vegc_natveg.nc",
             alitfallc       = "alitfallc_natveg.bin",
             alitfalln       = "alitfalln_natveg.bin",
             harvest         = "pft_harvest_lai.unlimN.pft.bin",
             sdate           = "sdate_lai.unlimN.bin",
             hdate           = "hdate_lai.unlimN.bin"
  )
  
  file_name <- toolSubtypeSelect(subtype,files)
  
  
  start_year <- as.numeric(gsub("First year: ","",readLines(paste0(folder,"tmp.out"))))
  years      <- seq(start_year,2017,1)
  
  unit_transform <-0.01               # Transformation factor gC/m^2 --> t/ha
  
  if(subtype%in%c("soilc","litc","vegc","alitfallc","alitfalln")){
    
    start_year  <- start_year           #Start year of data set
    years       <- years                #Vector of years that should be exported
    nbands      <- 1                    # Number of bands in the .bin file
    avg_range   <- 1                    #Number of years used for averaging
    
    x <- readLPJ(
      file_name=paste0(folder,file_name),
      wyears=years,
      syear=start_year,
      averaging_range=avg_range,
      bands=nbands,
      soilcells=TRUE)
    
    x <- collapseNames(as.magpie(x))
    x <- x*unit_transform
    getNames(x) <- subtype
    
  } else if(grepl("*date*", subtype)){
    
    start_year  <- start_year           #Start year of data set
    years       <- years                #Vector of years that should be exported
    nbands      <- 24                    # Number of bands in the .bin file
    avg_range   <- 1                    #Number of years used for averaging
    
    x <- readLPJ(
      file_name=paste0(folder,file_name),
      wyears=years,
      syear=start_year,
      averaging_range=avg_range,
      bands=nbands,
      datatype=integer(),
      bytes=2,
      soilcells = TRUE,
      ncells = 67420)
    
    x <- collapseNames(as.magpie(x))
    
  } else if(subtype%in%c("soilc_layer")){
    
    start_year  <- start_year           #Start year of data set
    years       <- years                #Vector of years that should be exported
    nbands      <- 5                    # Number of bands in the .bin file
    avg_range   <- 1                    #Number of years used for averaging
    
    x <- readLPJ(
      file_name=paste0(folder,file_name),
      wyears=years,
      syear=start_year,
      averaging_range=avg_range,
      bands=nbands,
      soilcells=TRUE)
    
    x <- collapseNames(as.magpie(x))
    x <- x*unit_transform
    
    getNames(x)     <- paste0("soilc.",getNames(x))
    getSets(x)[4:5] <- c("data" ,"layer")
    
  } else if(grepl("m *", subtype)){
    
    start_year  <- start_year          #Start year of data set
    years       <- years               #Vector of years that should be exported
    nbands      <- 12                   #Number of bands in the .bin file
    avg_range   <- 1                    #Number of years used for averaging
    
    x <- readLPJ(
      file_name=paste0(folder,file_name),
      wyears=years,
      syear=start_year,
      averaging_range = avg_range,
      monthly=TRUE,
      soilcells=TRUE)
    
    x <- collapseNames(as.magpie(x))
    x <- x*unit_transform
    
    if(grepl("layer", subtype)){
      subtype     <- gsub("_", "\\.", subtype)                     # Expand dimension to layers
      getNames(x) <- paste0(subtype,".",getNames(x))
      getSets(x)[4:6]  <- c("data" ,"layer","month")
    } else{
      getNames(x) <- paste0(subtype,".",getNames(x))
      getSets(x)[4:5]  <- c("data" , "month")
    }
    
  } else if(grepl("*harvest*", subtype)){
    
    start_year  <- start_year           #Start year of data set
    years       <- years                #Vector of years that should be exported
    nbands      <- 32                    # Number of bands in the .bin file
    avg_range   <- 1                    #Number of years used for averaging
    
    x <- readLPJ(
      file_name=paste0(folder,file_name),
      wyears=years,
      syear=start_year,
      averaging_range=avg_range,
      bands=nbands,
      soilcells=TRUE)
    
    # Transformation factor gC/m^2 --> t/ha
    yield_transform <- 0.01/0.45
    x <- collapseNames(as.magpie(x))
    x <- x*yield_transform
    
  } else {stop(paste0("subtype ",subtype," is not existing"))}
  
  return(x)
}
