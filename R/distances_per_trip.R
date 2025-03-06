#' A function to calculate distance between points
#'
#' @param my_df a data frame with a divider, latitude and longitude
#' @param my_divider the name of the column to divide
#'
#' @return a data frame with the distances between points
#' @export
#'
#' @examples Path_distances<-distances_per_trip(my_df=Path_trips,my_divider='trip_number')
distances_per_trip<-function(my_df=my_df,
                             my_divider=my_divider){
  trips_df<-my_df
  trips_df$separator <- (trips_df[[my_divider]])

  trips_list <- split(trips_df, trips_df$separator)
  for (i in seq_along(trips_list)) {
    trips_df <- trips_list[[i]]
    trips_coords <- trips_df[, c("Longitude", "Latitude")]
    trips_spatial <- sp::SpatialPointsDataFrame(coords = trips_coords,data = trips_df)
    sp::proj4string(trips_spatial) = sp::CRS("+init=epsg:4326")
    trips_distancias <- sapply(2:nrow(trips_spatial),
                               function(i) {
                                 geosphere::distm(trips_spatial[i - 1, ],
                                                  trips_spatial[i,])})
    trips_distancias <- c(NA, trips_distancias)
    trips_df$pointsdist_km <- round(trips_distancias/1000,2)
    trips_list[[i]] <- trips_df
  }
  my_path <- do.call("rbind", trips_list)
  return(my_path)
}
