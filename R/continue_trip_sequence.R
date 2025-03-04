#' A function to calculate gaps between locations inside trips
#'
#' @param my_previous a data frame containing information of trip_id
#'
#' @return the same data frame with an additional column called timedif_min
#' @export
#'
#' @examples Previous_params<-data.frame(trip_id=c("trip_00405"))
#' trip_number_sequence<-continue_trip_sequence(my_previous=Previous_params$trip_id)
#'
continue_trip_sequence<-function(my_previous){
  print(dplyr::last(my_previous))
  trip_number_sequence<-substr(dplyr::last(my_previous), start = 6, stop = 10)
  trip_number_sequence<-as.numeric(trip_number_sequence)
  print(trip_number_sequence)
  return(trip_number_sequence)}
