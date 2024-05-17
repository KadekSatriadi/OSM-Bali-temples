library(osmdata)
library(leaflet)
library(sf)
library(dplyr)

#check available features
#available_features()

#tags <-available_tags("amenity")
#tags_building <-available_tags("building")

#define boundaries
bali_bb <- getbb("Bali")
#bali_bb

#create overpass query, exclude mosque church cathedral synagogue
bali_opw <- bali_bb %>%
  opq() %>%
  add_osm_feature(key = "amenity", value = "place_of_worship") %>%
  add_osm_feature(key = "building", value = "!mosque") %>%
  add_osm_feature(key = "building", value = "!church") %>%
  add_osm_feature(key = "building", value = "!cathedral") %>%
  add_osm_feature(key = "building", value = "!synagogue") %>%
  osmdata_sf()

#extract points
sf_polygons <- bali_opw$osm_polygons #only extract polygons as the points contain the boundary of the place, rather than the center point (e.g, rectangular place will be 4 points)

bali_pow_df <- as.data.frame(sf_polygons) 

#num_na <- sum(is.na(bali_pow_df$name))

# Print the result
#print(num_na)
#print(nrow(bali_pow_df))

#plot
leaflet() %>%
  addTiles() %>%
  addPolygons(data = sf_polygons, 
                   fill = "black", 
              color = ifelse(is.na(sf_polygons$name), "#8da0cb", "#fc8d62"), 
              fillOpacity = 1,
                   popup = paste("Name:", sf_polygons$name, "<br>",
                                 "Amenity:", sf_polygons$amenity))


#save all, NA, and named

# Extract the geometry attribute from the sf polygon object
bali_pow_df$geometry <- st_as_text(bali_pow_df$geometry)

write.csv(bali_pow_df, "Bali_place_of_worship_all.csv", row.names = F)
write.csv(bali_pow_df %>%  dplyr::filter(!is.na(name)), "Bali_place_of_worship_named.csv", row.names = F)
write.csv(bali_pow_df %>% dplyr::filter(is.na(name)), "Bali_place_of_worship_unnamed.csv", row.names = F)

