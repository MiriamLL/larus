#' A function to calculate gaps between locations inside trips
#'
#' @param my_locs the data containing date, time and trip number
#' @param my_datetime a column with date and time information already in POSIXct format
#' @param my_separator a column with trip_number or any other separator
#'
#' @return the same data frame with an additional column called timedif_min
#' @export
#'
#' @examples calculate_gaps(my_locs = GSM_locs,my_datetime = 'daytime',my_separator = 'ID')
calculate_gaps<-function(my_locs=my_locs,
                         my_datetime=my_datetime,
                         my_separator=my_separator){

  my_locs$my_separator<-(my_locs[[my_separator]])

  trips_list<-split(my_locs,my_locs$my_separator)

  gaps_list<-list()

  #obtiene para cada elemento de la lista
  for( i in seq_along(trips_list)){

    trip_df<-trips_list[[i]]

    times<-trip_df[[my_datetime]]
    times_lag<-dplyr::lag(times)
    time_dif<-as.numeric(difftime(times,times_lag, units="mins"))
    trip_df$timedif_min<-round(time_dif,2)

    gaps_list[[i]]<-trip_df

  }

  gaps_df<- do.call("rbind",gaps_list)

  gaps_df$my_separator<-NULL

  return(gaps_df)
}
