
<!-- README.md is generated from README.Rmd. Please edit that file -->

# larus <img src="man/figures/GullLogo.png" align="right" width = "200px"/>

<!-- badges: start -->
<!-- badges: end -->

## Installation

You can install the development version of larus from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("MiriamLL/larus")
```

# Intro

There is three key issues in determining the foraging trips in GSMs
attached to gulls:

1.  Battery charge and gaps (intervals) in the data
2.  Identify foraging trips, classify is usable or not
3.  The gulls just do whatever they want.

# ——————–

# 1. The effect of the battery

``` r
library(larus)
```

``` r
head(GSM_battery)
#>       ID             daytime         season month battery_charge gaps_min
#> 1 LALI03 2023-04-18 07:28:35 early-breeding    04             53       NA
#> 2 LALI03 2023-04-18 07:48:30 early-breeding    04             56 19.91667
#> 3 LALI03 2023-04-18 08:07:35 early-breeding    04             56 19.08333
#> 4 LALI03 2023-04-18 08:27:06 early-breeding    04             56 19.51667
#> 5 LALI03 2023-04-18 08:47:06 early-breeding    04             57 20.00000
#> 6 LALI03 2023-04-18 09:07:35 early-breeding    04             59 20.48333
```

``` r
library(scales)
library(ggplot2)
```

``` r
ggplot(GSM_battery, aes(x=daytime, y=battery_charge)) +
  geom_line() +
  scale_x_datetime(labels = date_format("%b"),date_breaks = "1 month")
```

## Battery levels classification

Considerations: Optimal battery was considered \> 75% battery Good \<
75% battery Poor \< 50% battery Low \< 25% battery

``` r
library(tidyverse)
```

``` r
GSM_battery_class <- GSM_battery%>%
  mutate(battery_class = 
         case_when(is.na(battery_charge) ~ 'U',
                   battery_charge >= 75 ~ '1Optimal (>75%)',
                   battery_charge <= 75 & battery_charge > 50 ~ '2Good (>50%)',
                   battery_charge <= 50 & battery_charge > 25 ~ '3Poor (>25%)',
                   battery_charge <= 25 ~ '4Low (<25%)',
                   TRUE ~ 'Check'))
```

``` r
GSM_battery_class %>%
  group_by(battery_class)%>%
  tally()%>%
  mutate(total=sum(n))%>%
  mutate(prop=n*100/total)
#> # A tibble: 3 × 4
#>   battery_class       n total  prop
#>   <chr>           <int> <int> <dbl>
#> 1 1Optimal (>75%) 16861 28209 59.8 
#> 2 2Good (>50%)    10515 28209 37.3 
#> 3 3Poor (>25%)      833 28209  2.95
```

## Gaps and battery relations

When studying tracking locations from GSM data, especially in the case
of birds like gulls, it’s common to encounter gaps in the data due to
factors such as loss of signal, battery limitations, or movement through
areas with poor GSM coverage.

Calculate gaps

if there is only one individual

``` r
GSM_locs$gaps_min<-as.numeric(GSM_locs$daytime - lag(GSM_locs$daytime))
```

``` r
head(GSM_locs)
#> # A tibble: 6 × 11
#>   num_seq ID     daytime             season      month Longitude Latitude inside
#>   <chr>   <chr>  <dttm>              <chr>       <chr>     <dbl>    <dbl> <chr> 
#> 1 1       LALI03 2023-04-18 07:28:35 early-bree… 04        -110.     24.3 insid…
#> 2 2       LALI03 2023-04-18 07:48:30 early-bree… 04        -110.     24.3 insid…
#> 3 3       LALI03 2023-04-18 08:07:35 early-bree… 04        -110.     24.3 insid…
#> 4 4       LALI03 2023-04-18 08:27:06 early-bree… 04        -110.     24.3 insid…
#> 5 5       LALI03 2023-04-18 08:47:06 early-bree… 04        -110.     24.3 insid…
#> 6 6       LALI03 2023-04-18 09:07:35 early-bree… 04        -110.     24.3 insid…
#> # ℹ 3 more variables: central_base <chr>, battery_charge <dbl>, gaps_min <dbl>
```

If there are more individuals

``` r
GSM_gaps <-calculate_gaps(my_locs = GSM_locs,my_datetime = 'daytime',my_separator = 'ID')
```

Considerations: Optimal gaps \< 5 minutes Good \< 15 minutes Average \<
30 minutes Poor \< 2 hours (120 minutes) Low \> 24 hours (1400 minutes)

``` r
GSM_gaps_class <- GSM_gaps %>%
  mutate(gaps_class = 
           case_when(is.na(gaps_min) ~ '8U',
                     gaps_min <= 5 ~ '1Optimal (<5mins)',
                     gaps_min >= 5 & gaps_min < 15 ~ '2Good (<15mins)',
                     gaps_min >= 15 & gaps_min < 30 ~ '3Average (<30mins)',
                     gaps_min >= 30 & gaps_min < 60 ~ '4Poor (<1hr)',
                     gaps_min >= 60 & gaps_min < 1400 ~ '5Low (>1hr)',
                     gaps_min >= 1400 ~ '6Low (onceAday)',
                     TRUE ~ '7Check'))
```

``` r
GSM_gaps_class %>%
  group_by(gaps_class)%>%
  tally()
#> # A tibble: 6 × 2
#>   gaps_class             n
#>   <chr>              <int>
#> 1 1Optimal (<5mins)   2958
#> 2 2Good (<15mins)    18986
#> 3 3Average (<30mins)  5919
#> 4 4Poor (<1hr)         343
#> 5 5Low (>1hr)            2
#> 6 8U                     1
```

## Compare

``` r
library(patchwork)
#> Warning: package 'patchwork' was built under R version 4.4.3
```

### Battery and gaps per month

``` r
GSM_battery_class %>%
  group_by(month,battery_class)%>%
  tally()%>%
  mutate(total=sum(n))%>%
  mutate(prop=n*100/total) %>%
  
ggplot(aes(fill=battery_class, y=prop, x=month)) + 
  geom_bar(stat="identity")+
  scale_fill_manual(values=c('#d7263d','#f46036','#2e294e'))+
  theme_classic()+
  scale_y_continuous(expand = c(0,0)) +
  
GSM_gaps_class %>%
  group_by(month,gaps_class)%>%
  tally()%>%
  mutate(total=sum(n))%>%
  mutate(prop=n*100/total)%>%
  filter(gaps_class!='8U') %>% #expect first position to be empty
  
ggplot(aes(fill=gaps_class, y=prop, x=month)) +
  geom_bar(stat="identity") +
  scale_fill_manual(values=c('#d7263d','#f46036','#ffc857','#c5d86d','#1b998b','#2e294e'))+
  theme_classic()+
  scale_y_continuous(expand = c(0,0)) +
  
plot_layout(ncol = 1)
```

<img src="man/figures/README-unnamed-chunk-18-1.png" width="100%" />

# ——————–

## 2. Identify trips

Making the separation by individual and month, is more time consuming
but assures that you can have an overview of the trips and the
calculations.

Also the birds might leave the nest at some point and you need to
recalculate the central location.

### Step 1: subset month

``` r
library(tidyverse)
```

``` r
This_month<-'07'
This_month_text<-'Jun'
```

``` r
Trips_01locs<-GSM_locs %>%
  dplyr::filter(month==This_month)
```

### Step 2: plot_check

``` r
my_central_location<-data.frame(Longitude=-110.33979846296234,Latitude=24.28728834326802)
```

``` r
plot_check(my_locs=Trips_01locs,my_central_location = my_central_location)
```

### Step 3: remove central locations

``` r
Trips_02outside<-Trips_01locs %>%
  filter(inside=='outside_central')
```

### Step 4: trip_number_sequence

``` r
Previous_params<-data.frame(trip_id=c("trip_00001"))
```

``` r
trip_number_sequence<-continue_trip_sequence(my_previous=Previous_params$trip_id)
#> [1] "trip_00001"
#> [1] 1
```

``` r
Trips_03trips<-Trips_02outside %>%
  mutate(num_seq=as.numeric(num_seq))%>%
  mutate(trip_number = (cumsum(c(1L, diff(num_seq)) !=   1L)))%>%
  mutate(trip_number = trip_number +1 + trip_number_sequence)%>%
  mutate(trip_number = stringr::str_pad(trip_number,  5, pad = "0"))%>%
  mutate(trip_number = paste0("trip_", trip_number))
```

### Step 5: plot_trips

Visualize trips

``` r
plot_trips(my_locs=Trips_03trips,my_central_location=my_central_location)
```

### Step 6: calculate_params

Create data frame with trip_start, trip_end, duration, gap minimum, gap
maximum per trip

``` r
Trips_04params<-calculate_params(my_locs=Trips_03trips,
                                 my_daytime='daytime',
                                 my_format="%Y-%m-%d %H:%M:%S",
                                 my_units="hours",
                                 my_divider="trip_number",
                                 my_gaps='gaps_min')
```

Define trip_month_id in case there are outliers and the locations need
to be subset

``` r
Trips_05params<-Trips_04params %>%
  mutate(trip_month_id=paste0(This_month_text,"_a_",trip_id))%>%
  mutate(central_loc='colony')
```

### Step 7: compare_notrips

Check that the same number of trips are in the locations and in the
parameters

``` r
compare_notrips(my_params=GSM_params,my_locs=GSM_trips)
#> [1] "There are 133 trips in locations, and 133 in parameters"
#> [1] "There are 0 trips missing in locations, and 0 in parameters"
```

# ——————–

# 3. Classify params

## Step 1: classify_params

Add information of the criteria to keep or not some trips based on trip
duration (trip_size), resolution (recording intervals), duration (trips
should be shorter than 24 hrs), interpolation (just trips that are
longer than 30 minutes, have intervals of \< 60 minutes and last then
than 24 hours would be considered for interpolation)

``` r
Params_00criteria<-classify_params(my_params=GSM_params)
```

## Step 2: check_trip_criteria

Foraging trips were only considered when the animal was more than 1 km
away from the colony and lasting longer than 30 min (Shaffer et
al. 2017, Guerra et al. 2022).

If trips had a gap of \> 1hr and/or included overnight locations without
a clear central location, they were excluded from the interpolation.

``` r
check_trip_criteria(my_params=Params_00criteria)
#> [1] "From 133 trips: 20.3% were trip_longer_than_30mins and 79.7% were trip_shorter_than_30mins. Trips shorter than 30 minutes are not considered real trips. Remove these trips from analyses. "
```

Remove short trips from the foraging trips

``` r
Params_01criteria<-Params_00criteria %>%
  dplyr::filter(trip_size == 'trip_longer_than_30mins')
```

## Step 3: check_resolution_criteria

Check if the intervals affected the trips detected

``` r
check_resolution_criteria(my_params=Params_resolution)
#> [1] "From 27 trips: 3.7 % (n = 1) were low_resolution_gaps_more_60_mins and 96.3 % (n = 26) were ok_resolution_gaps_less_60_mins. Evaluate if trips with low resolution are to be kept"
```

If they do not pass the criteria remove from the dataframe

``` r
Params_02criteria<-Params_01criteria %>%
  dplyr::filter(resolution == 'ok_resolution_gaps_less_60_mins')
```

## Step 4: check_lenght_criteria

Check if the trips were not longer than 24 hrs
(longer_than_24h_reevaluate_centralloc)

``` r
check_length_criteria(my_params=Params_resolution)
#> [1] "From 27 trips: 14.81% (n = 4) were longer_than_24h_reevaluate_centralloc and 85.19% (n = 23) were shorter_than_24h_keep_centralloc. Evaluate if trips longer than 24 hrs is because of a change in central location"
```

If there are trips longer than 24 hrs reevaluate their central location

## Step 5: classify_locs

Add the information from the parameters data frame to the locations

``` r
Locs_01class<-classify_locs(Inter_params=Interpolation_params,
                            Inter_locs=GSM_trips)
```

# ——————–

# 4. Reevaluate

## Reevaluate trips

Some trips might not seem real, is it because of the resolution or
because the animal move from central location?

## Step 1: check outliers

Which trips were longer than 24 hrs?

``` r
Trips_05params %>%
  arrange(-duration)
#> # A tibble: 162 × 8
#>    trip_id    trip_start          trip_end            duration min_gap max_gap
#>    <chr>      <dttm>              <dttm>                 <dbl>   <dbl>   <dbl>
#>  1 trip_00163 2023-07-31 04:58:52 2023-07-31 21:58:55     17.0    9.2     29.8
#>  2 trip_00118 2023-07-23 06:24:09 2023-07-23 21:54:04     15.5    9.08    15.9
#>  3 trip_00157 2023-07-30 06:58:50 2023-07-30 20:39:02     13.7    4.28    20.3
#>  4 trip_00012 2023-07-04 04:08:46 2023-07-04 16:38:47     12.5    4.05    10.2
#>  5 trip_00119 2023-07-24 05:53:31 2023-07-24 17:43:31     11.8    9.98    10.0
#>  6 trip_00123 2023-07-26 04:14:12 2023-07-26 15:35:28     11.4    9.4     29.0
#>  7 trip_00065 2023-07-15 03:38:47 2023-07-15 14:58:50     11.3    9.08    11.4
#>  8 trip_00121 2023-07-25 04:13:31 2023-07-25 15:33:24     11.3    9.18    11.2
#>  9 trip_00148 2023-07-29 03:53:47 2023-07-29 15:03:47     11.2    4.85    10.8
#> 10 trip_00075 2023-07-18 09:18:47 2023-07-18 20:18:48     11.0    9.4     10.4
#> # ℹ 152 more rows
#> # ℹ 2 more variables: trip_month_id <chr>, central_loc <chr>
```

## Step 2: extract locs

Identify ids and use the ids to subset the locations

``` r
Reevaluate_tripid<-'trip_00163'
Reevaluate_tripid
#> [1] "trip_00163"
```

``` r
Reevaluate_01locs<-Trips_03trips %>%
  dplyr::filter(trip_number %in% Reevaluate_tripid)%>%
  dplyr::relocate(ID,trip_number,daytime,gaps_min)
head(Reevaluate_01locs)
#> # A tibble: 6 × 12
#>   ID     trip_number daytime             gaps_min num_seq season month Longitude
#>   <chr>  <chr>       <dttm>                 <dbl>   <dbl> <chr>  <chr>     <dbl>
#> 1 LALI03 trip_00163  2023-07-31 04:58:52    10.0    15553 late-… 07        -110.
#> 2 LALI03 trip_00163  2023-07-31 05:09:12    10.3    15554 late-… 07        -110.
#> 3 LALI03 trip_00163  2023-07-31 05:18:49     9.62   15555 late-… 07        -110.
#> 4 LALI03 trip_00163  2023-07-31 05:28:59    10.2    15556 late-… 07        -110.
#> 5 LALI03 trip_00163  2023-07-31 05:38:49     9.83   15557 late-… 07        -110.
#> 6 LALI03 trip_00163  2023-07-31 05:49:16    10.4    15558 late-… 07        -110.
#> # ℹ 4 more variables: Latitude <dbl>, inside <chr>, central_base <chr>,
#> #   battery_charge <dbl>
```

## Step 3: identify new central location

Use the plot to change the central location, either by seeing all trips
or one trip at a time

``` r
new_central_location<-data.frame(Longitude=-110.325,Latitude=24.17)
```

``` r
plot_check(my_locs=Reevaluate_01locs,my_central_location = my_central_location)+
  ggplot2::geom_point(data=new_central_location, ggplot2::aes(x=Longitude, y=Latitude),color='orange',shape=17, size=5)
```

## Step 4: create_buffer

Use the central location to make a buffer

``` r
new_central_buffer<-create_buffer(central_point=new_central_location,buffer_km=0.3)
#> Warning in CPL_crs_from_input(x): GDAL Message 1: +init=epsg:XXXX syntax is
#> deprecated. It might return a CRS with a non-EPSG compliant axis order.
```

## Step 5: from_df_to_sf

Convert the locations into a sf

``` r
Reevaluate_01locs<-Reevaluate_01locs%>%
  dplyr::filter(trip_number %in% Reevaluate_tripid)%>%
  dplyr::relocate(ID,trip_number,daytime,gaps_min)
```

``` r
Reevaluate_02sf<-from_df_to_st(Reevaluate_01locs)
```

## Step 6: over

This function gives the information if the location was in or out of the
central location

``` r
new_central_buffer<-create_buffer(central_point=new_central_location,buffer_km=0.3)
```

Check nrows should correspond.

``` r
Reevaluate_01locs$central_location<- larus::over(my_locations=Reevaluate_02sf,
                                               my_polygon=Reevaluate_polygon)
```

## Step 7: add_trip_number

This function adds a trip number on the locations.  
Take care to have the correct information on previous params

``` r
Previous_params<-Trips_05params$trip_id
```

``` r
new_trip_number_sequence<-continue_trip_sequence(my_previous=Previous_params)
#> [1] "trip_00163"
#> [1] 163
```

``` r
Reevaluate_02trips<-add_trip_number(my_df=Reevaluate_01locs,
                                    my_trip_number_sequence=new_trip_number_sequence)
```

Plot to check that the central location corresponds to your example

``` r
new_central_location<-data.frame(Longitude=-110.325,Latitude=24.17)
plot_trips(my_locs=Reevaluate_02trips,my_central_location=new_central_location)
```

## Step 8: calculate params

Identify trip_start, end, duration and gaps

``` r
Reevaluate_03params<-calculate_params(my_locs=Reevaluate_02trips,
                                 my_daytime='daytime',
                                 my_format=  "%Y-%m-%d %H:%M:%S",
                                 my_units="hours",
                                 my_divider="trip_number",
                                 my_gaps='gaps_min'
                                 )
```

Add this information on the parameters

``` r
Reevaluate_03params<-Reevaluate_03params %>%
  dplyr::mutate(trip_month_id=paste0(This_month_text,"_b_",trip_id))%>%
  dplyr::mutate(central_loc='south_of_colony')
```

## Step 9: plot_trips

Check the new trip separation

``` r
plot_trips(my_locs=Reevaluate_02trips,my_central_location = new_central_location)+
  ggplot2::geom_point(data=new_central_location, ggplot2::aes(x=Longitude, y=Latitude),color='blue',shape=17, size=5)
```

## Step 10: classify params

Add classification information to see if fits the criteria

``` r
Params_04reevaluate<-classify_params(my_params=Reevaluate_03params)
```

# ——————–

# 5. Merge

## Step 1: Merge params

Add criteria classifications

``` r
Params_merged<-rbind(Params_02criteria %>% dplyr::filter(!trip_id %in% Reevaluate_tripid),
                     Params_04reevaluate)
```

## Step 2: Locs merged

Use the parameters information to add classification to locations

``` r
Locs_merged <-rbind(Trips_03trips %>% 
                      dplyr::filter(!trip_number %in% Reevaluate_tripid)%>%
                      dplyr::select(ID,daytime,season,month,
                             Longitude,Latitude,
                             central_base,inside,num_seq,
                             gaps_min,battery_charge,
                             trip_number),
                    
                    Reevaluate_02trips %>%
                      dplyr::select(ID,daytime,season,month,
                             Longitude,Latitude,
                             central_base,inside,num_seq,
                             gaps_min,battery_charge,
                             trip_number))
```

# ——————–

# 6. Path lenght

## Step 1: Remove small trips

``` r
my_trips<-GSM_trips
short_trips<-my_trips %>%
  dplyr::group_by(trip_number)%>%
  dplyr::tally()%>%
  dplyr::arrange(-n)%>%
  dplyr::filter(n<3)
Path_trips<-GSM_trips %>%
  dplyr::filter(!trip_number %in% unique(short_trips$trip_number))
```

## Step 2: distances_per_trip

This function is a loop that separates trip per divider and calculate
distances per trip and adds them to the locations

Be careful, to calculate path distances you must have at least three
locations per trip Takes time

``` r
Path_distances<-distances_per_trip(my_df=Path_trips,
                                   my_divider='trip_number')
```

``` r
Path_distances %>% 
  dplyr::group_by(trip_number)%>%
  dplyr::summarise(path_lenght_km=sum(pointsdist_km,na.rm=TRUE))%>%
  dplyr::mutate(trip_id=trip_number)
```

## Step 3: calculate leaving and returning distance

``` r
Path_leaving_returning<-calculate_leaving_returning(my_locs=Path_trips,
                                                    my_central_location=data.frame(Longitude=-110.33,Latitude=24.287))
```

Careful: exclude those trips that the central_location was south of the
colony for the corrections.

# ——————–

# 7. Maximum distances

## Step 1: Calculate maximum distances per trip, returns parameters

``` r
Maxdist_params<-calculate_maxdist(my_data =GSM_trips, 
                                    central_location = data.frame(Longitude=-110.34,Latitude=24.28),
                                    divider="trip_number")
```

# ——————–

# 8. Interpolations

Whether to interpolate the data depends on your research goals and the
nature of the gaps.

Here’s a breakdown of considerations to help you decide:

- Short Gaps: If the gaps are short (e.g., a few minutes to an hour),
  interpolation might be justifiable, especially if you assume that the
  bird’s movement is relatively constant during the gap. For example,
  linear interpolation can estimate a reasonable position based on
  previous and subsequent data points.
- Long Gaps: If the gaps are long (e.g., several hours or days),
  interpolation might introduce unrealistic results, especially if the
  bird’s movement during that time period was unknown. Interpolating
  long gaps could lead to misleading conclusions about the bird’s actual
  path or behavior. If your study’s analysis can handle missing data or
  gaps (e.g., for high-level migration patterns), you might consider
  leaving the gaps unfilled. This avoids the risk of introducing
  erroneous data but may reduce the overall precision. If your analysis
  is based on trajectory or movement behavior, you could use gap-filling
  approaches like predicting the bird’s behavior based on its last known
  location and surrounding environmental context (such as weather, time
  of day, etc.).

## Step 1: interpolate

``` r
Interpolation_trips<-Interpolation_trips
```

Check criteria

``` r
Interpolation_trips %>%
  group_by(interpolation)%>%
  tally()
#> # A tibble: 1 × 2
#>   interpolation                                        n
#>   <chr>                                            <int>
#> 1 gapsless60mins_shorter24hr_canditate_interpolate   376
```

Funcion interpolate_trips

``` r
Interpolated_locs<-interpolate_trips(my_df=Interpolation_trips,
                                    interval='900 sec',
                                    column_datetime='daytime',
                                    column_trip='trip_number',
                                    column_lat='Latitude',
                                    column_lon='Longitude',
                                    datetime_format="%Y-%m-%d %H:%M:%S")
```

# ——————–

# end of document
