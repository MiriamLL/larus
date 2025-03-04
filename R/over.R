#' Gives information if the polygon intersects the locations or not
#'
#' @param my_locations s Simple feature with a data frame
#' @param my_polygon a Simple feature collection with 1 feature and 0 fields
#'
#' @return vector with data
#' @export
#'
# @examples over(my_locations=Reevaluate_sf,my_polygon=Reevaluate_polygon)
over<-function(my_locations=my_locations,my_polygon=my_polygon){
  locations<-sf::st_as_sf(my_locations)
  location_over<-sapply(sf::st_intersects(locations,my_polygon),
                        function(z) if (length(z)==0) NA_integer_ else z[1])
  return(location_over)}
