#' A function to calculate the distance from leaving and returning to the colony
#'
#' @param my_locs a data frame with Longitude, Latitude,and trip_number
#' @param my_central_location a data frame with Longitude and Latitude
#'
#' @return a data frame with the trip number, the distance of leaving and returning, and the coordinates of the central location
#' @export
#'
#' @examples calculate_leaving_returning(my_locs=Path_trips,my_central_location=data.frame(Longitude=-110.33,Latitude=24.287))
calculate_leaving_returning<-function(my_locs=my_locs,my_central_location=my_central_location){

  # trips
  my_paths<-my_locs %>%
    dplyr::group_by(trip_number)%>%
    dplyr::summarise(first_lat= dplyr::first(Latitude),
                     first_lon= dplyr::first(Longitude),
                     last_lat= dplyr::last(Latitude),
                     last_lon= dplyr::last(Longitude),
                     central_location='colony',
                     central_lat=my_central_location$Latitude,
                     central_lon=my_central_location$Longitude)

  # to spatial points data frame
  central_location_df <- my_paths[, c("central_lon","central_lat")]
  central_location_sp <- sp::SpatialPointsDataFrame(coords = central_location_df,data = central_location_df)
  sp::proj4string(central_location_sp) = sp::CRS("+init=epsg:4326")

  # leaving the central location
  leaving_df <- my_paths[, c("first_lon", "first_lat")]
  leaving_sp <- sp::SpatialPointsDataFrame(coords = leaving_df,data = leaving_df)
  sp::proj4string(leaving_sp) = sp::CRS("+init=epsg:4326")

  # leaving distance
  leaving_distance<-geosphere::distm(leaving_sp, central_location_sp,fun = geosphere::distHaversine)
  leaving_distance_km<-round(as.numeric(leaving_distance[,1])/1000,digits = 2)

  # add to trip list
  my_paths$leaving_distance_km<-leaving_distance_km

  # returning to the central location
  returning_df <- my_paths[, c("last_lon", "last_lat")]
  returning_sp <- sp::SpatialPointsDataFrame(coords = returning_df,data = returning_df)
  sp::proj4string(returning_sp) = sp::CRS("+init=epsg:4326")

  # leaving distance
  returning_distance<-geosphere::distm(returning_sp, central_location_sp,fun = geosphere::distHaversine)
  returning_distance_km<-round(as.numeric(returning_distance[,1])/1000,digits = 2)

  # add to trip list
  my_paths$returning_distance_km<-returning_distance_km

  return(my_paths)
}
