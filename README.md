
<!-- README.md is generated from README.Rmd. Please edit that file -->

# larus

<!-- badges: start -->
<!-- badges: end -->

The goal of larus is to …

## Installation

You can install the development version of larus from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("MiriamLL/larus")
```

# Main functions

## Check for gaps and resolution

- from_df_to_st
- over
- identify_trips
- trip_number_sequence
- calculate_gaps

# Data

## gull_data

Contains data from one gull tagged at La Paz, Mexico

``` r
library(larus)
```

``` r
gull_data<-gull_data
```

# Functions

## create_buffer

``` r
create_buffer<-function(central_point=central_point, buffer_km=buffer_km){
  central_spatial<- sp::SpatialPoints(cbind(central_point$Longitude,central_point$Latitude)) 
  sp::proj4string(central_spatial)= sp::CRS("+init=epsg:4326") 
  central_spatial <- sp::spTransform(central_spatial, sp::CRS("+init=epsg:4326"))
  central_spatial<-sf::st_as_sf(central_spatial)
  buffer_dist<-buffer_km*1000
  central_buffer<-sf::st_buffer(central_spatial, buffer_dist)
  return(central_buffer)
  }
```

``` r
central_buffer<-create_buffer(central_point=central_location,buffer_km=0.3)
```

## from_df_to_st

``` r
LALI02_02apr_points <- LALI02_02apr
sp::coordinates(LALI02_02apr_points) <- ~Longitude + Latitude
sp::proj4string(LALI02_02apr_points) = sp::CRS("+init=epsg:4326")
LALI02_02apr_points<-sf::st_as_sf(LALI02_02apr_points)
```

``` r
from_df_to_st<-function(my_df){
  my_points <- my_df
  sp::coordinates(my_points) <- ~Longitude + Latitude
  sp::proj4string(my_points) = sp::CRS("+init=epsg:4326")
  my_sf<-sf::st_as_sf(my_points)
  return(my_sf)
}
```

``` r
LALI02_27ago_points<-from_df_to_st(LALI02_27ago)
```

## over

``` r
#LALI02_02apr_over<- over(LALI02_02apr_points,central_buffer)
LALI02_02apr_over<-sapply(sf::st_intersects(LALI02_02apr_points,central_buffer), function(z) if (length(z)==0) NA_integer_ else z[1])
```

``` r
LALI02_02apr$central_location <- LALI02_02apr_over
```

``` r
over<-function(this_location=this_location,this_buffer=this_buffer){
  locations<-sf::st_as_sf(this_location)
  location_over<-sapply(sf::st_intersects(locations,this_buffer), function(z) if (length(z)==0) NA_integer_ else z[1])
  return(location_over)}
```

``` r
LALI02_27ago_over<- over(LALI02_27ago_points,central_buffer)
```

## count_trip

``` r
LALI02_02apr<-LALI02_02apr %>%
  mutate(inside=case_when(central_location == 1 ~ 'inside_central',TRUE ~ 'outside_central'))
```

``` r
LALI02_02apr %>%
  group_by(ID,inside)%>%
  count()%>%
  pivot_wider(names_from = inside, values_from = n)
```

``` r
LALI02_04apr<-LALI02_02apr %>%
  filter(inside=='outside_central')
```

``` r
LALI02_04apr<-LALI02_04apr %>%
  mutate(num_seq=as.numeric(num_seq))%>%
  mutate(trip_number = (cumsum(c(1L, diff(num_seq)) !=   1L)))%>%
  mutate(trip_number = trip_number + 1)%>%
  mutate(trip_number = stringr::str_pad(trip_number,  5, pad = "0"))%>%
  mutate(trip_number = paste0("trip_", trip_number))
```

## trip_number_sequence

``` r
last(LALI02_04apr$trip_number)
```

``` r
trip_number_sequence<-substr(last(LALI02_04apr$trip_id), start = 6, stop = 10)
trip_number_sequence<-as.numeric(trip_number_sequence)
trip_number_sequence
```

``` r
continue_trip_sequence<-function(my_previous){
  print(last(my_previous$trip_id))
  trip_number_sequence<-substr(last(my_previous$trip_id), start = 6, stop = 10)
  trip_number_sequence<-as.numeric(trip_number_sequence)
  print(trip_number_sequence)
return(trip_number_sequence)}
```

``` r
trip_number_sequence<-continue_trip_sequence(my_previous=LALI02_54oct)
```

### add_trip_number

``` r
add_trip_number<-function(my_over,my_df,my_previous){
  
  my_df$central_location <- my_over 
  
  my_df<-my_df %>%
    mutate(inside=case_when(central_location == 1 ~ 'inside_central',TRUE ~ 'outside_central'))
  
  my_df %>%
    group_by(ID,inside)%>%
    count()%>%
    pivot_wider(names_from = inside, values_from = n)
  
  my_outside<-my_df %>%
    filter(inside=='outside_central')
  
  last(my_previous$trip_id)
  
  trip_number_sequence<-substr(last(my_previous$trip_id), start = 6, stop = 10)
  trip_number_sequence<-as.numeric(trip_number_sequence)
  trip_number_sequence

  my_trips<-my_outside %>%
    mutate(num_seq=as.numeric(num_seq))%>%
    mutate(trip_number = (cumsum(c(1L, diff(num_seq)) !=   1L)))%>%
    mutate(trip_number = trip_number + 1 + trip_number_sequence)%>%
    mutate(trip_number = stringr::str_pad(trip_number,  5, pad = "0"))%>%
    mutate(trip_number = paste0("trip_", trip_number))
  
  return(my_trips)
}
```

``` r
LALI02_28ago<-add_trip_number(my_over=LALI02_27ago_over,my_df=LALI02_27ago,my_previous=LALI02_13jul)
```

### sequence

``` r
LALI02_27ago_points<-from_df_to_st(LALI02_27ago)
```

``` r
LALI02_27ago_over<- over(LALI02_27ago_points,central_buffer)
```

``` r
trip_number_sequence<-continue_trip_sequence(my_previous=LALI02_54oct$trip_id)
```

``` r
LALI02_28ago<-add_trip_number(my_over=LALI02_27ago_over,my_df=LALI02_27ago,my_previous=LALI02_13jul)
```

# Gaps

``` r
LALIS_all$Gaps_time<-as.numeric(LALIS_all$daytime - lag(LALIS_all$daytime))
```

``` r
gull_gaps<-calculate_gaps(GPS_data = gull_data,
                          column_datetime = 'DateTime',
                          column_tripnumber = 'trip_number')
```

``` r
range(gull_gaps$timedif_min,na.rm=TRUE)
#> [1]   9.18 120.25
```

# Intervals

When studying tracking locations from GSM data, especially in the case
of birds like gulls, it’s common to encounter gaps in the data due to
factors such as loss of signal, battery limitations, or movement through
areas with poor GSM coverage. Whether to interpolate the data depends on
your research goals and the nature of the gaps.

Here’s a breakdown of considerations to help you decide:

- Short Gaps: If the gaps are short (e.g., a few minutes to an hour),
  interpolation might be justifiable, especially if you assume that the
  bird’s movement is relatively constant during the gap. For example,
  linear interpolation can estimate a reasonable position based on
  previous and subsequent data points.
- Long Gaps: If the gaps are long (e.g., several hours or days),
  interpolation might introduce unrealistic results, especially if the
  bird’s movement during that time period was unknown. Interpolating
  long gaps could lead to misleading conclusions about the bird’s actual
  path or behavior. If your study’s analysis can handle missing data or
  gaps (e.g., for high-level migration patterns), you might consider
  leaving the gaps unfilled. This avoids the risk of introducing
  erroneous data but may reduce the overall precision. If your analysis
  is based on trajectory or movement behavior, you could use gap-filling
  approaches like predicting the bird’s behavior based on its last known
  location and surrounding environmental context (such as weather, time
  of day, etc.).

## classify_long_or_short_gap

# Battery

``` r
library(scales)
```

``` r
ggplot(LALI02_01locs, aes(x=daytime, y=battery.charge.percent)) +
  geom_line() +
  scale_x_datetime(labels = date_format("%b"),date_breaks = "1 month")
```
