# Making Maps with R

# The packsges we will need for the exercise
install.packages(c("ggplot2", "devtools", "dplyr", "stringr"))

# some standard map packages.
install.packages(c("maps", "mapdata"))

# the github version of ggmap, which recently pulled in a small fix I had
# for a bug 
devtools::install_github("dkahle/ggmap")

library(ggplot2)
library(ggmap)
library(maps)
library(mapdata)

usa <- map_data("usa")

# india <- map_data("india")

dim(usa)
head(usa)
tail(usa)

w2hr <- map_data("world2Hires")

dim(w2hr)
head(w2hr)
tail(w2hr)

# Plot the USA map
usa <- map_data("usa") # we already did this, but we can do it again
ggplot() + geom_polygon(data = usa, aes(x=long, y = lat, group = group)) + 
  coord_fixed(1.3)

# Variations of the same map:

# 1. Here is no fill, with a red line. Remember, fixed value of aesthetics go outside the aes function.
ggplot() + 
  geom_polygon(data = usa, aes(x=long, y = lat, group = group), fill = NA, color = "red") + 
  coord_fixed(1.3)

# 2. Here is yellow/ violet fill, with a blue line.
gg1 <- ggplot() + 
  geom_polygon(data = usa, aes(x=long, y = lat, group = group), fill = "yellow", color = "blue") + 
  coord_fixed(1.3)
gg1

gg1 <- ggplot() + 
  geom_polygon(data = usa, aes(x=long, y = lat, group = group), fill = "violet", color = "blue") + 
  coord_fixed(1.3)
gg1


# Adding points to the map
labs <- data.frame(
  long = c(-122.064873, -122.306417),
  lat = c(36.951968, 47.644855),
  names = c("SWFSC-FED", "NWFSC"),
  stringsAsFactors = FALSE
)  

gg1 + 
  geom_point(data = labs, aes(x = long, y = lat), color = "black", size = 5) +
  geom_point(data = labs, aes(x = long, y = lat), color = "yellow", size = 4)

# Map with group aesthetics:
ggplot() + 
  geom_polygon(data = usa, aes(x=long, y = lat), fill = "violet", color = "blue") + 
  geom_point(data = labs, aes(x = long, y = lat), color = "black", size = 5) +
  geom_point(data = labs, aes(x = long, y = lat), color = "yellow", size = 4) +
  coord_fixed(1.3)


## State maps
# We can also get a data frame of polygons that tell us above state boundaries:

states <- map_data("state")

dim(states)
head(states)
tail(states)

# Plot all the US states:
ggplot(data = states) + 
  geom_polygon(aes(x = long, y = lat, fill = region, group = group), color = "white") + 
  coord_fixed(1.3) +
  guides(fill=FALSE)  # do this to leave off the color legend

# Plot just a subset of states in the contiguous 48:
west_coast <- subset(states, region %in% c("california", "oregon", "washington"))

ggplot(data = west_coast) + 
  geom_polygon(aes(x = long, y = lat), fill = "palegreen", color = "black") 

ggplot(data = west_coast) + 
  geom_polygon(aes(x = long, y = lat, group = group), fill = "palegreen", color = "black") + 
  coord_fixed(1.3)

# Zoom in on California and look at counties
ca_df <- subset(states, region == "california")

head(ca_df)
tail(ca_df)

counties <- map_data("county")
ca_county <- subset(counties, region == "california")

head(ca_county)
tail(ca_county)

ca_base <- ggplot(data = ca_df, mapping = aes(x = long, y = lat, group = group)) + 
  coord_fixed(1.3) + 
  geom_polygon(color = "black", fill = "gray")
ca_base + theme_nothing()

ca_base + theme_nothing() + 
  geom_polygon(data = ca_county, fill = NA, color = "white") +
  geom_polygon(color = "black", fill = NA)  # get the state border back on top

# Get some facts about the counties
# Now I can go to wikipedia or http://www.california-demographics.com/counties_by_population
# and grab population and area data for each county.

library(stringr)
library(dplyr)

data/ca-counties-wikipedia.txt

# make a data frame
x <- readLines("C:\\Users\\its_t\\Documents\\CUNY\\Fall 2019\\9750 - Software Tools and Techniques_Data Science\\ca-counties-wikipedia.csv")
pop_and_area <- str_match(x, "^([a-zA-Z ]+)County\t.*\t([0-9,]{2,10})\t([0-9,]{2,10}) sq mi$")[, -1] %>%
  na.omit() %>%
  str_replace_all(",", "") %>% 
  str_trim() %>%
  tolower() %>%
  as.data.frame(stringsAsFactors = FALSE)

# give names and make population and area numeric
names(pop_and_area) <- c("subregion", "population", "area")
pop_and_area$population <- as.numeric(pop_and_area$population)
pop_and_area$area <- as.numeric(pop_and_area$area)

head(pop_and_area)

cacopa <- inner_join(ca_county, pop_and_area, by = "subregion")

cacopa$people_per_mile <- cacopa$population / cacopa$area

head(cacopa)

# prepare to drop the axes and ticks but leave the guides and legends
# We can't just throw down a theme_nothing()!
ditch_the_axes <- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank()
)

elbow_room1 <- ca_base + 
  geom_polygon(data = cacopa, aes(fill = people_per_mile), color = "white") +
  geom_polygon(color = "black", fill = NA) +
  theme_bw() +
  ditch_the_axes

elbow_room1 

elbow_room1 + scale_fill_gradient(trans = "log10")

# Make it colorful
eb2 <- elbow_room1 + 
  scale_fill_gradientn(colours = rev(rainbow(7)),
                       breaks = c(2, 4, 10, 100, 1000, 10000),
                       trans = "log10")
eb2


eb2 + xlim(-123, -121.0) + ylim(36, 38)

eb2 + coord_fixed(xlim = c(-123, -121.0),  ylim = c(36, 38), ratio = 1.3)


