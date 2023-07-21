#' A function to calculate gaps between locations inside trips
#'
#' @param GPS_data the data containing date, time and trip number
#' @param column_datetime a column with date and time information already in POSIXct format
#' @param column_tripnumber a column with trip_number or any other separator
#'
#' @return the same data frame with an additional column called timedif_min
#' @export
#'
#' @examples gull_gaps<-calculate_gaps(GPS_data = gull_data,column_datetime = 'DateTime',
#' column_tripnumber = 'trip_number')
calculate_gaps<-function(GPS_data=GPS_data,
                         column_datetime=column_datetime,
                         column_tripnumber=column_tripnumber){

  GPS_data$column_tripnumber<-(GPS_data[[column_tripnumber]])

  trips_list<-split(GPS_data,GPS_data$column_tripnumber)

  gaps_list<-list()

  #obtiene para cada elemento de la lista
  for( i in seq_along(trips_list)){

    trip_df<-trips_list[[i]]

    times<-trip_df[[column_datetime]]
    times_lag<-dplyr::lag(times)
    time_dif<-as.numeric(difftime(times,times_lag, units="mins"))
    trip_df$timedif_min<-round(time_dif,2)

    gaps_list[[i]]<-trip_df

  }

  gaps_df<- do.call("rbind",gaps_list)

  gaps_df$column_tripnumber<-NULL

  return(gaps_df)
}
