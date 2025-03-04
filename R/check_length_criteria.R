#' This function is just to provide a baseline information from the foraging trips
#'
#' @param my_params a data frame with trip parameters
#'
#' @return prints information about your parameters
#' @export
#'
# @examples check_length_criteria(my_params=Params_resolution)

check_length_criteria<-function(my_params=my_params){

  length_criteria<-my_params %>%
    dplyr::group_by(params_analyses)%>%
    dplyr::tally()%>%
    dplyr::mutate(total=sum(n))%>%
    dplyr::mutate(prop=n*100/total)


  print(paste0("From ",sum(length_criteria$n),' trips: ',
               round(length_criteria$prop[1],2),' (n = ',length_criteria$n[1],') were ',length_criteria$params_analyses[1],' and ',
               round(length_criteria$prop[2],2),' (n = ',length_criteria$n[2],') were ',length_criteria$params_analyses[2],
               '. Evaluate if trips longer than 24 hrs is because of a change in central location'))

}
