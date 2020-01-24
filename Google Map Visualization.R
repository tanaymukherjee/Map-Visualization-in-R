## GGMap

## How ggmap works
# ggmap simplifies the process of downloading base maps from Google or 
# Open Street Maps or Stamen Maps to use in the background of your plots.
# It also sets the axis scales, etc, in a nice way.
# Once you have gotten your maps, you make a call with ggmap() much as you would with ggplot()
# Let's do by example.

# Sisquoctober

sisquoc <- read.table("C:\\Users\\its_t\\Documents\\CUNY\\Fall 2019\\9750 - Software Tools and Techniques_Data Science\\sisquoc-points.txt", sep = "\t", header = TRUE)
sisquoc

# ggmap typically asks you for a zoom level, but we can try using ggmap's make_bbox function:
sbbox <- make_bbox(lon = sisquoc$lon, lat = sisquoc$lat, f = .1)
sbbox

# Now, when we grab the map ggmap will try to fit it into that bounding box. Let's try:
# First get the map. By default it gets it from Google.  I want it to be a satellite map
sq_map <- get_map(location = sbbox, maptype = "satellite", source = "google")

ggmap(sq_map) + geom_point(data = sisquoc, mapping = aes(x = lon, y = lat), color = "red")

# compute the mean lat and lon
ll_means <- sapply(sisquoc[2:3], mean)
sq_map2 <- get_map(location = ll_means,  maptype = "satellite", source = "google", zoom = 15)

# Map from URL : http://maps.googleapis.com/maps/api/staticmap?center=34.753117,-119.751324&zoom=15&size=640x640&scale=2&maptype=satellite&language=en-EN&sensor=false
ggmap(sq_map2) + 
  geom_point(data = sisquoc, color = "red", size = 4) +
  geom_text(data = sisquoc, aes(label = paste("  ", as.character(name), sep="")), angle = 60, hjust = 0, color = "yellow")

sq_map3 <- get_map(location = ll_means,  maptype = "terrain", source = "google", zoom = 15)
#> Map from URL : http://maps.googleapis.com/maps/api/staticmap?center=34.753117,-119.751324&zoom=15&size=640x640&scale=2&maptype=terrain&language=en-EN&sensor=false
ggmap(sq_map3) + 
  geom_point(data = sisquoc, color = "red", size = 4) +
  geom_text(data = sisquoc, aes(label = paste("  ", as.character(name), sep="")), angle = 60, hjust = 0, color = "yellow")


# How about a bike ride?
# I was riding my bike one day with a my phone and downloaded the
# GPS readings at short intervals.
# We can plot the route like this:

bike <- read.csv("data/bike-ride.csv")
head(bike)
bikemap1 <- get_map(location = c(-122.080954, 36.971709), maptype = "terrain", source = "google", zoom = 14)

#> Map from URL : http://maps.googleapis.com/maps/api/staticmap?center=36.971709,-122.080954&zoom=14&size=640x640&scale=2&maptype=terrain&language=en-EN&sensor=false
ggmap(bikemap1) + 
  geom_path(data = bike, aes(color = elevation), size = 3, lineend = "round") + 
  scale_color_gradientn(colours = rainbow(7), breaks = seq(25, 200, by = 25))