#' Add trip number to a series of locations using a base if the animal move or not outside of the buffer
#'
#' @param my_df A data frame with central_location and num_sequence
#' @param my_trip_number_sequence a number to continue trip sequence
#'
#' @return vector with data
#' @export
#'
# @examples add_trip_number(my_df=Reevaluate_trips,my_trip_number_sequence=405)
add_trip_number<-function(my_df,my_trip_number_sequence){

  my_df<-my_df %>%
    dplyr::mutate(inside= dplyr::case_when(central_location == 1 ~ 'inside_central',TRUE ~ 'outside_central'))

  my_df %>%
    dplyr::group_by(ID,inside)%>%
    dplyr::count()%>%
    tidyr::pivot_wider(names_from = inside, values_from = n)

  my_outside<-my_df %>%
    dplyr::filter(inside=='outside_central')

  my_trips<-my_outside %>%
    dplyr::mutate(num_seq=as.numeric(num_seq))%>%
    dplyr::mutate(trip_number = (cumsum(c(1L, diff(num_seq)) !=   1L)))%>%
    dplyr::mutate(trip_number = trip_number + 1 + my_trip_number_sequence)%>%
    dplyr::mutate(trip_number = stringr::str_pad(trip_number,  5, pad = "0"))%>%
    dplyr::mutate(trip_number = paste0("trip_", trip_number))

  return(my_trips)
}
