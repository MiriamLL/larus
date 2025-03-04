#' Creates a buffer around a point
#'
#' @param central_pont a data frame with latitude and longitude
#'
#' @return returns a buffer in spatial new_central_buffer
#' @export
#'
# @examples new_central_location<-data.frame(Longitude=-110.325,Latitude=24.17)
# new_central_buffer<-create_buffer(central_point=new_central_location,buffer_km=0.3)
create_buffer<-function(central_point=central_point, buffer_km=buffer_km){
  central_spatial<- sp::SpatialPoints(cbind(central_point$Longitude,central_point$Latitude))
  sp::proj4string(central_spatial)= sp::CRS("+init=epsg:4326")
  central_spatial <- sp::spTransform(central_spatial, sp::CRS("+init=epsg:4326"))
  central_spatial<-sf::st_as_sf(central_spatial)
  buffer_dist<-buffer_km*1000
  central_buffer<-sf::st_buffer(central_spatial, buffer_dist)
  return(central_buffer)
}
