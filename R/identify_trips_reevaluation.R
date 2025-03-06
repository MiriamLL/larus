#' Identifies trips from a data set
#'
#' @param my_trip trip locations
#' @param my_central_location data frame with longitude and latitude
#' @param my_previous_params a data frame containing trip id to keep the sequence, and not repetead trip numbers
#'
#' @return a data frame containing trip number
#' @export
#'
#' @examples identify_trips_reevaluation(my_trip=Reevaluate_trips,my_central_location=data.frame(Longitude=-110.33,Latitude=24.15),my_previous_params=Params_criteria$trip_id)
identify_trips_reevaluation<-function(my_trip=my_trip,my_central_location=my_central_location,my_previous_params=my_previous_params){

  new_central_buffer<-create_buffer(central_point=my_central_location,buffer_km=0.3)
  my_sf<-from_df_to_st(my_trip)
  my_trip$central_location<- larus::over(my_locations=my_sf,my_polygon=new_central_buffer)

  new_trip_number_sequence<-continue_trip_sequence(my_previous=my_previous_params)
  new_trips<-add_trip_number(my_df=my_trip,my_trip_number_sequence=new_trip_number_sequence)

  print(paste0("From ",length(unique(my_trip$trip_number)),
               " original trip, the change in central location divided the locations to obtain ",
               length(unique(new_trips$trip_number)),
               ' new trips'))

  return(new_trips)
}
