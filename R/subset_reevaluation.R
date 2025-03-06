#' A function to subset a specific trip from the GSM data
#'
#' @param my_tripid the trip to be subset
#' @param my_trip the data frame with the locations it should contain trip_number
#' @param new_central_location data frame with latitude and longitude of new central location
#' @param old_central_location data frame with latitude and longitude of old central location
#'
#' @return a data frame filtered
#' @export
#'
#' @examples subset_reevaluation(my_trip=GSM_trips,my_tripid='trip_00528',new_central_location=data.frame(Longitude=-110.32,Latitude=24.15), old_central_location=data.frame(Longitude=-110.34,Latitude=24.28))
subset_reevaluation<-function(my_tripid=my_tripid,
                              my_trip=my_trip,
                              new_central_location=new_central_location,
                              old_central_location=old_central_location){

  # Subset locations
  my_locs<-my_trip %>%
    dplyr::filter(trip_number %in% my_tripid)%>%
    dplyr::relocate(ID,trip_number,daytime,gaps_min)

  print(plot_check(my_locs=my_locs,my_central_location = old_central_location)+
          ggplot2::geom_point(data=new_central_location, ggplot2::aes(x=Longitude, y=Latitude),color='orange',shape=17, size=5)+
          ggplot2::ggtitle('my new central location in orange, previous central location in red- for reference'))

  return(my_locs)
}
