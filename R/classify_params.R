#' Add trip classification on the trip parameters
#'
#' @param my_params a data frame with trip parameters
#'
#' @return returns four new columns with criteria to keep or recalculate trip parameters
#' @export
#'
# @examples GSM_criteria<-classify_params(my_params=GSM_params)
classify_params<-function(my_params=my_params){
  my_params<-my_params %>%
    dplyr::mutate(trip_size =  dplyr::case_when(duration >= 0.5 ~ 'trip_longer_than_30mins',
                                 duration <= 0.5 ~ 'trip_shorter_than_30mins',
                                 TRUE ~ "other"))%>%

    dplyr::mutate(resolution= dplyr::case_when(max_gap >= 60 ~ 'low_resolution_gaps_more_60_mins',
                                max_gap <= 60 ~ 'ok_resolution_gaps_less_60_mins',
                                TRUE ~ "other"))%>%

    dplyr::mutate(params_analyses= dplyr::case_when(duration >= 24 ~ 'longer_than_24h_reevaluate_centralloc',
                                     duration <= 24 ~ 'shorter_than_24h_keep_centralloc',
                                     TRUE ~ "other"))%>%

    dplyr::mutate(interpolation =  dplyr::case_when(duration <= 24 & max_gap <= 60 ~ 'gapsless60mins_shorter24hr_canditate_interpolate',
                                     duration >= 24 & max_gap >= 60 ~ 'gapsmore60mins_longer24hr_reevaluate_centralloc',
                                     duration >= 24 ~ 'onger24hr_reevaluate_centralloc',
                                     max_gap >= 60 ~ 'gapsmore60mins_dont_interpolate',
                                     TRUE ~ "other"))

  return(my_params)}
