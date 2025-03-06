#' Compare number of trips from parameters and locations
#'
#' @param my_params the data frame with the parameters - must have trip number
#' @param my_locs the data frame with the locations - must have trip id
#'
#' @return information of which trips might be missing
#' @export
#'
#' @examples compare_notrips(my_params=GSM_params,my_locs=GSM_trips)
compare_notrips<-function(my_params=my_params,my_locs=my_locs){

  values1<-data.frame(id=unique(my_locs$trip_number),origin='values1')
  values2<-data.frame(id=unique(my_params$trip_id),origin='values2')
  valuescomparison<-merge(values1,values2,by='id',all=TRUE)
  missingvalues1<-valuescomparison %>%
    dplyr::filter(is.na(origin.x))
  missingvalues2<-valuescomparison %>%
    dplyr::filter(is.na(origin.y))
  print(paste0('There are ',length(unique(my_locs$trip_number)),' trips in locations, and ',
               length(unique(my_params$trip_id)),' in parameters'))
  print(paste0('There are ',nrow(missingvalues1),' trips in locations, and ',
               nrow(missingvalues1),' in parameters'))
}
