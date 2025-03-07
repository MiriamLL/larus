#' This function is just to provide a baseline information
#'
#' @param my_params a data frame with trip parameters
#'
#' @return prints information about your parameters
#' @export
#'
# @examples check_trip_criteria(my_params=Params_criteria)
check_trip_criteria<-function(my_params=my_params){

  trip_criteria<-my_params %>%
    dplyr::group_by(trip_size)%>%
    dplyr::tally()%>%
    dplyr::mutate(total=sum(n))%>%
    dplyr::mutate(prop=n*100/total)

  print(paste0("From ",sum(trip_criteria$n),' trips: ',
               round(trip_criteria$prop[1],2),'% (n=',trip_criteria$n[1],
               ') were ',trip_criteria$trip_size[1],' and ',
               round(trip_criteria$prop[2],2),'% (n=',trip_criteria$n[2],
               ') were ',trip_criteria$trip_size[2],
               '. Trips shorter than 30 minutes are not considered real trips. Remove these trips from analyses. '
  ))

}
