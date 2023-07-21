
<!-- README.md is generated from README.Rmd. Please edit that file -->

# larus

<!-- badges: start -->
<!-- badges: end -->

The goal of larus is to …

## Installation

You can install the development version of larus from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("MiriamLL/larus")
```

# Data

## gull_data

Contains data from one gull tagged at La Paz, Mexico

``` r
library(larus)
```

``` r
gull_data<-gull_data
```

## Functions

Find gaps

``` r
gull_gaps<-calculate_gaps(GPS_data = gull_data,
                          column_datetime = 'DateTime',
                          column_tripnumber = 'trip_number')
```

``` r
range(gull_gaps$timedif_min,na.rm=TRUE)
#> [1]   9.18 120.25
```
