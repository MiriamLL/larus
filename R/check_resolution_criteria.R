#' This function is just to provide a baseline information
#'
#' @param my_params a data frame with trip parameters
#'
#' @return prints information about your parameters
#' @export
#'
# @examples check_resolution_criteria(my_params=Params_resolution)
check_resolution_criteria<-function(my_params=my_params){

  resolution_criteria<-my_params %>%
    dplyr::group_by(resolution)%>%
    dplyr::tally()%>%
    dplyr::mutate(total=sum(n))%>%
    dplyr::mutate(prop=n*100/total)


  print(paste0("From ",sum(resolution_criteria$n),' trips: ',
               round(resolution_criteria$prop[1],2),' (n = ',resolution_criteria$n[1],') were ',
               resolution_criteria$resolution[1],' and ',
               round(resolution_criteria$prop[2],2),' (n = ',resolution_criteria$n[2],') were ',
               resolution_criteria$resolution[2],
               '. Evaluate if trips with low resolution are to be kept'))

}
