#' Creates a plot to check locations
#'
#' @param my_locs a data frame with locations
#' @param my_central_location a data frame with the central location
#'
#' @return plot to evaluate if the central location is correct
#' @export
#'
#' @examples plot_check(my_locs=GSM_locs,my_central_location = data.frame(Longitude=-110.34,Latitude=24.28))
plot_check<-function(my_locs=my_locs,my_central_location=my_central_location){
  ggplot2::ggplot()+
    ggplot2::geom_point(data = my_locs, ggplot2::aes(x=Longitude, y = Latitude),
                        color='black',size = 0.8,alpha=0.4)+
    ggplot2::geom_point(data=my_central_location, ggplot2::aes(x=Longitude, y=Latitude),color='red',shape=17, size=5)+
    ggplot2::geom_density_2d_filled(data = my_locs, ggplot2::aes(x = Longitude, y = Latitude),alpha = 0.5)+
    ggplot2::theme_bw()+
    ggplot2::theme(legend.position = 'none')+
    ggplot2::ggtitle('Check that the triangle is close to the highest location concentration- \nThis should be your central location-  \nIf the central location is shifted -  \nPlease recalculate using another central location')}
