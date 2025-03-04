#' Add trip classification to the locations
#'
#' @param my_locs a data frame with trip parameters
#'
#' @return returns four new columns with criteria to keep or recalculate trip parameters
#' @export
#'
# @examples Inter_02locs<-classify_locs(Inter_params=Interpolation_params,Inter_locs=GSM_trips)
classify_locs<-function(Inter_params=Inter_params,
                        Inter_locs=Inter_locs){

  tripid_01trip_size<-unique(Inter_params %>%
                               dplyr::filter(trip_size == 'trip_longer_than_30mins'))$trip_id

  tripid_02analysesid<-unique(Inter_params %>%
                                dplyr::filter(params_analyses == "shorter_than_24h_keep_centralloc"))$trip_id

  tripid_03resolutionid<-unique(Inter_params %>%
                                  dplyr::filter(resolution == "ok_resolution_gaps_less_60_mins"))$trip_id

  tripid_04interpolateid<-unique(Inter_params %>%
                                   dplyr::filter(interpolation == 'gapsless60mins_shorter24hr_canditate_interpolate'))$trip_id

  Inter_locs<-Inter_locs %>%
    dplyr::mutate(trip_size =
                    dplyr::case_when(trip_number %in% tripid_01trip_size ~  'trip_longer_than_30mins',
                                     TRUE ~  'trip_shorter_than_30mins'))%>%

    dplyr::mutate(params_analyses=
                    dplyr::case_when(trip_number %in% tripid_02analysesid ~ "keep_centralloc_shorter_than_24h",
                                     TRUE ~ "reevaluate_centralloc_longer_than_24h"))%>%

    dplyr::mutate(resolution=
                    dplyr::case_when(trip_number %in% tripid_03resolutionid~ "ok_resolution_gaps_less_60_mins",
                                     TRUE ~ "low_resolution_gaps_more_60_mins"))%>%

    dplyr::mutate(interpolation=
                    dplyr::case_when(trip_number %in% tripid_04interpolateid ~ 'gapsless60mins_shorter24hr_canditate_interpolate',
                                     TRUE ~ "dont_interpolate_longer24hr"))

  return(Inter_locs)
}

