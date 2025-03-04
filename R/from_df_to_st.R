#' Converts a data frame into a sf simple features, uses 4326 as CRS
#'
#' @param Reevaluate_locs a data frame with latitude and longitude
#'
#' @return returns a simple features, longitude and latitude are now in the geometry information
#' @export
#'
# @examples from_df_to_st(Reevaluate_locs)
from_df_to_st<-function(my_df){
  my_points <- my_df
  sp::coordinates(my_points) <- ~Longitude + Latitude
  sp::proj4string(my_points) = sp::CRS("+init=epsg:4326")
  my_sf<-sf::st_as_sf(my_points)
  return(my_sf)
}
