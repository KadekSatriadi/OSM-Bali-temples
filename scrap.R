library(osmdata)
library(leaflet)
library(sf)
library(dplyr)

#check available features
available_features()

tags <-available_tags("amenity")
tags_building <-available_tags("building")

#define boundaries
bali_bb <- getbb("Bali")
bali_bb

#create overpass query, exclude mosque church cathedral synagogue
bali_pow <- bali_bb %>%
  opq() %>%
  add_osm_feature(key = "amenity", value = "place_of_worship") %>%
  add_osm_feature(key = "building", value = "!mosque") %>%
  add_osm_feature(key = "building", value = "!church") %>%
  add_osm_feature(key = "building", value = "!cathedral") %>%
  add_osm_feature(key = "building", value = "!synagogue") %>%
  osmdata_sf()

#extract points

bali_pow_df<- st_drop_geometry(bali_pow$osm_points)
coordinates <- st_coordinates(bali_pow$osm_points)
bali_pow_df <- cbind(coordinates, bali_pow_df)

num_na <- sum(is.na(bali_pow_df$name))

# Print the result
print(num_na)
print(nrow(bali_pow_df))

#plot
sf_points <- bali_pow$osm_points
leaflet() %>%
  addTiles() %>%
  #addMarkers(data = bali_pow$osm_points)
  addCircleMarkers(data = sf_points, 
                   radius = 4, # Adjust the size of the circles if needed
                   color = ifelse(is.na(sf_points$name), "#8da0cb", "#fc8d62"), 
                   stroke = FALSE,
                   fillOpacity = 1,
                   popup = paste("Name:", sf_points$name, "<br>",
                                 "Amenity:", sf_points$amenity))


#save all, NA, and named

write.csv(bali_pow_df, "Bali_place_of_worship_all.csv", row.names = F)
write.csv(bali_pow_df %>% dplyr::filter(!is.na(name)), "Bali_place_of_worship_named.csv", row.names = F)
write.csv(bali_pow_df %>% dplyr::filter(is.na(name)), "Bali_place_of_worship_unnamed.csv", row.names = F)

