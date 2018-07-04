# !! chunk options

library(leaflet)
library(sf)
library(tidyverse)
library(htmltools)

setwd("C:/Users/mathieu.rajerison/Desktop/11_DREAL_HdF_Detecte les friches/BASOL/")

source("../_script_R/lib/fonctions.R")

# READING
## BASOL

f.basol = read.csv("../_script_R/csv/basol/basol_dep60.csv") %>%
  st_as_sf(coords = c("Lambert.II.étendu...coordonnée.X", 
                      "Lambert.II.étendu...coordonnée.Y"), 
           crs = 27572) %>%
  st_transform(4326)

f.basol = f.basol %>% mutate(long = st_coordinates(f.basol)[, 1], 
                            lat = st_coordinates(f.basol)[, 2]) %>% 
          filter(estFriche)

# CHANGEMENT DE TYPE
f.basol$Numéro.BASOL.complet = as.character(f.basol$Numéro.BASOL.complet)

# REFORMATAGE
f.basol$Numéro.BASOL.complet = sapply(f.basol$Numéro.BASOL.complet, formaterCodeBasol)

# SUPPRESSION DU POINT LE PLUS BAS
w = which.min(st_coordinates(f.basol)[, 2])
f.basol = f.basol[-w, ]
# SCRAPING
# n = nrow(f)
# out=vector(mode="list")
# for (i in 1:10) {
#   print(i)
#   numero_site = f$Numéro.BASOL.complet[i]
#   out[[i]] = getDescriptionSite(numero_site)
# }
# res = do.call(rbind, out)
# save(res, file="../_script_R/rda/basol/res.descSite.rda")
load("../_script_R/rda/basol/res.descSite.rda")
# f$content = res

# save(f, file="../_script_R/rda/basol/f.descSite.rda")


# BASIAS
# f.basias = st_read("../_script_R/shp/BASIAS_60_activite_terminee.shp")
# f.basias.wgs84 = f.basias %>% st_set_crs(2154) %>% st_transform(4326)
# save(f.basias.wgs84, file="../_script_R/rda/f.basias.wgs84.rda")
load("../_script_R/rda/f.basias.wgs84.rda")
# SIIIC
# f.s3ic = st_read("../_script_R/shp/S3IC_HdF_friche_L93.shp")
# f.s3ic.wgs84 = f.s3ic %>% st_set_crs(2154) %>% st_transform(4326)
#save(f.s3ic.wgs84, file="../_script_R/rda/f.s3ic.wgs84.rda")
load("../_script_R/rda/f.s3ic.wgs84.rda")

# PARCELLES
# f.basias.parcelles = st_read("../_script_R/shp/parcelles/ff_60_basias_activite_terminee.shp")
# f.basol.parcelles = st_read("../_script_R/shp/parcelles/ff_60_basol_friche.shp")
# f.s3ic.parcelles = st_read("../_script_R/shp/parcelles/d60_parcelles_S3IC_V3.shp")
# # SURFACES
# f.basias.parcelles$surface_m2 = st_area(f.basias.parcelles)
# f.basol.parcelles$surface_m2 = st_area(f.basol.parcelles)
# f.s3ic.parcelles$surface_m2 = st_area(f.s3ic.parcelles)
# f.basias.parcelles.wgs84 = f.basias.parcelles %>% st_set_crs(2154) %>% st_transform(4326)
# f.basol.parcelles.wgs84 = f.basol.parcelles %>% st_set_crs(2154) %>% st_transform(4326)
# f.s3ic.parcelles.wgs84 = f.s3ic.parcelles %>% st_set_crs(2154) %>% st_transform(4326)
# save(list=c("f.s3ic.parcelles.wgs84", "f.basias.parcelles.wgs84", "f.basol.parcelles.wgs84"), 
#        file="../_script_R/rda/parcelles.rda")
load("../_script_R/rda/parcelles.rda")

# HEATMAP
# library(spatstat)
# library(raster)
# library(maptools)
# 
# f = data.frame(rbind(st_coordinates(f.basol),
#         st_coordinates(f.basias.wgs84),
#         st_coordinates(f.s3ic.wgs84))) %>% filter(!is.na(X)) %>%
#     st_as_sf(coords = c("X", "Y"))
# 
# # SUPPRESSION DU POINT DU BAS
# w = which.min(st_coordinates(f)[, 2])
# f.sel = f[-w, ]
# 
# library(maptools)
# library(raster)
# spatstat.options(npixel=300)
# r = f.sel %>% st_set_crs(4326) %>% as("Spatial") %>% as("ppp") %>% density.ppp(sigma=0.02) %>% raster()
# crs(r) = CRS("+init=EPSG:4326")
# 
# # PALETTE RASTER
# pal <- colorNumeric(c("#0C2C84", "#41B6C4", "#FFFFCC"), values(r),
#                     na.color = "transparent")
# ICONES
icon.basol <- makeAwesomeIcon(icon= 'home', markerColor = 'red', iconColor = 'black')
icon.basias <- makeAwesomeIcon(icon= 'home', markerColor = 'blue', iconColor = 'black')
icon.s3ic <- makeAwesomeIcon(icon= 'home', markerColor = 'green', iconColor = 'black')



# RENDER
m = leaflet(width="100%") %>% 
  addTiles() %>%
  
  addAwesomeMarkers(data = f.basol, 
             lng=~long, lat=~lat, 
             # popup = content,
             popup = ~res[1:nrow(f.basol)],
             # popup = ~content,
             # popup = res, 
             label = ~as.character(Nom.usuel.du.site),
             clusterOptions = markerClusterOptions(),
             group="BASOL",
             icon = icon.basol) %>%
  
  addAwesomeMarkers(data = f.basias.wgs84,
             group = "BASIAS",
             label = ~as.character(raison.soc),
             popup = ~as.character(libellé.ac),
             clusterOptions = markerClusterOptions(),
             icon = icon.basias) %>%
  
  addAwesomeMarkers(data = f.s3ic.wgs84, 
             group = "S3IC",
             label = ~as.character(Nom.établi),
             clusterOptions = markerClusterOptions(),
             icon = icon.s3ic) %>%
  
  addPolygons(data = f.basol.parcelles.wgs84,
              color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = "red",
              popup = ~paste("Date de construction :", as.character(jannatmin), "<br>",
                             "Type de propriétaire :", typproptxt, "<br>",
                             "Surface :", surface_m2, "m²"),
              highlightOptions = highlightOptions(color = "white", weight = 2),
              group="Parcelles BASOL") %>%
  
  addPolygons(data = f.basias.parcelles.wgs84,
              color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = "blue",
              popup = ~paste("Date de construction :", as.character(jannatmin), "<br>",
                             "Type de propriétaire :", typproptxt, "<br>",
                             "Surface :", surface_m2, "m²"),
              highlightOptions = highlightOptions(color = "white", weight = 2),
              group="Parcelles BASIAS") %>%
  
  addPolygons(data = f.s3ic.parcelles.wgs84,
              color = "#444444", weight = 1, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = "green",
              popup = ~paste("Date de construction :", as.character(jannatmin), "<br>",
                             "Type de propriétaire :", typproptxt, "<br>",
                             "Surface :", surface_m2, "m²"),
              highlightOptions = highlightOptions(color = "white", weight = 2),
              group="Parcelles S3IC") %>%
  
  # addRasterImage(r, colors = pal, opacity = 1) %>%
  
  # Layers control
  addLayersControl(
    overlayGroups = c("BASOL", "BASIAS", "S3IC", "Parcelles BASOL", "Parcelles BASIAS", "Parcelles S3IC"),
    options = layersControlOptions(collapsed = FALSE)
  )

m