#' Calculates trip duration using locations, and gap intervals per trip
#'
#' @param my_locs a data frame with all locations
#' @param my_daytime the name of the column where day and time information is provided
#' @param my_format the format in the column POSTIXct
#' @param my_units pick "hours", "minutes", "seconds".
#' @param my_divider a column to separate trips, for example 'trip_number'
#' @param my_gaps a column to separate trips, for example 'gaps_min'
#'
#' @return regresa un nuevo data frame con la información del viaje, cuando inicio, cuando termino y la duración
#' @export
#'
# @examples GSM_params<-calculate_params(my_locs=GSM_trips,my_daytime='daytime',my_format="%Y-%m-%d %H:%M:%S",my_units="hours",my_divider="trip_number",my_gaps='gaps_min')
calculate_params<-function(my_locs=my_locs,
                           my_daytime=my_daytime,
                           my_format=my_format,
                           my_units=my_units,
                           my_divider=my_divider,
                           my_gaps=my_gaps
){


  if (!is.null(my_locs[[my_divider]])) {
  }
  else {
    warning("Please check the name on the divider column")
  }
  if (!is.null(my_locs[[my_daytime]])) {
  }
  else {
    warning("Please check the name in my_daytime")
  }
  my_locs$my_divider <- (my_locs[[my_divider]])
  trips_list <- split(my_locs, my_locs$my_divider)
  duration_list <- list()
  for (i in seq_along(trips_list)) {
    trips_df <- trips_list[[i]]
    trip_start <- dplyr::first(trips_df[[my_daytime]])
    trip_end <- dplyr::last(trips_df[[my_daytime]])
    trip_id <- dplyr::first(trips_df[[my_divider]])
    duration_list[[i]] <- nest_loc <- data.frame(trip_id = trip_id,
                                                 trip_start = trip_start, trip_end = trip_end)
  }
  duration_merged <- do.call("rbind", duration_list)
  duration_merged$trip_start <- as.POSIXct(strptime(duration_merged$trip_start,
                                                    my_format), "GMT")
  duration_merged$trip_end <- as.POSIXct(strptime(duration_merged$trip_end,
                                                  my_format), "GMT")
  duration_merged$duration <- as.numeric(difftime(duration_merged$trip_end,
                                                  duration_merged$trip_start, units = my_units))
  if (!is.null(my_locs[[my_gaps]])) {
  }
  else {
    warning("Please check the name on the column with the gaps calculations")
  }
  my_locs$my_gaps<-my_locs[[my_gaps]]

  gaps_params<-my_locs %>%
    dplyr::group_by(trip_number)%>%
    dplyr::summarise(min_gap=min(my_gaps),
              max_gap=max(my_gaps))%>%
    dplyr::rename(trip_id=trip_number)

  this_params<-gaps_params %>%
    dplyr::left_join(duration_merged,by='trip_id')%>%
    dplyr::select(trip_id,trip_start,trip_end,duration,min_gap,max_gap)

  return(this_params)
}
