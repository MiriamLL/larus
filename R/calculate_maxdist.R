#' Calculate maximum distance per trip
#'
#' @param GSM_trips a data frame with 'Longitude','Latitude'
#' @param central_location a data frame with 'Longitude','Latitude'
#' @param divider column name for divider
#'
#' @return returns data frame with maximum distance per trip
#' @export
#'
#' @examples calculate_maxdist(GSM_data = GSM_trips, central_location = data.frame(Longitude=-110.34,Latitude=24.28),divider="trip_number")
calculate_maxdist<-function(GSM_data=GSM_data,
                            central_location=central_location,
                            divider=divider){


  if (!is.null(GSM_trips[[divider]])) {
  } else {
    warning("Please check the name on the divider column")
  }

  if (nrow(GSM_trips)!=0){
  } else {
    warning("Please check the name on the GSM_trips data frame")
  }

  if (nrow(central_location)!=0){
  } else {
    warning("Please check the name on the central_location data frame")
  }


  Viajes_df<-as.data.frame(GSM_trips)

  #separa los viajes
  Viajes_df$divider<-(Viajes_df[[divider]])

  Viajes_list<-split(Viajes_df,Viajes_df$divider)

  Nest_df<-central_location

  if ("Latitude" %in% colnames(central_location)){
  } else {
    warning("Please check that central_location has a column named Latitude, otherwise please rename the column as Latitude")
  }

  if ("Longitude" %in% colnames(central_location)){
  } else {
    warning("Please check that central_location has a column named Longitude, otherwise please rename the column as Longitude")
  }

  if ("Latitude" %in% colnames(GSM_trips)){
  } else {
    warning("Please check that central_location has a column named Latitude, otherwise please rename the column as Latitude")
  }

  if ("Longitude" %in% colnames(GSM_trips)){
  } else {
    warning("Please check that central_location has a column named Longitude, otherwise please rename the column as Longitude")
  }

  Nest_coords<- Nest_df[,c('Longitude','Latitude')]
  Nest_spatial <- sp::SpatialPointsDataFrame(coords = Nest_coords, data = Nest_df)
  sp::proj4string(Nest_spatial)= sp::CRS("+init=epsg:4326")

  #calcula para cada elemento de la lista
  for( i in seq_along(Viajes_list)){

    Viaje_df<-Viajes_list[[i]]
    Viaje_coords<- Viaje_df[,c('Longitude','Latitude')]
    Viaje_spatial <- sp::SpatialPointsDataFrame(coords = Viaje_coords, data = Viaje_df)
    sp::proj4string(Viaje_spatial)= sp::CRS("+init=epsg:4326")


    maxdist_m<-(geosphere::distm(Viaje_spatial,Nest_spatial,fun = geosphere::distHaversine))
    meters_df<-cbind(Viaje_df,maxdist_m)
    meters_df$maxdist_km<-round(meters_df$maxdist_m/1000,digits=2)
    meters_df$maxdist_m<-NULL

    Viajes_list[[i]]<-meters_df
  }

  # crear lista vacia
  Maxdist_list<-list()

  # calcular para cada elemento de la lista
  for( i in seq_along(Viajes_list)){

    data<-Viajes_list[[i]]
    var1<-"maxdist_km"

    Maxdist_df <- data %>%
      dplyr::summarise(maxdist_km=max(data[[var1]],na.rm=TRUE))

    trip_id<-dplyr::first(data$divider)

    Maxdist_list[[i]]<- data.frame(trip_id = trip_id,
                                   maxdist_km = Maxdist_df)

  }

  Maxdist <- do.call("rbind",Maxdist_list)

  return(Maxdist)
}
