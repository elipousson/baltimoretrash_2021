
# baltimoretrash_2021

<!-- badges: start -->
<!-- badges: end -->

The goal of baltimoretrash_2021 is to explore service requests, environmental citations, and other related open data to present an area-level analysis of trash conditions in Baltimore, Maryland. This project is developed by German Paredes (Towson University) through the [University of Baltimore Data Science Corps program](https://bniajfi.org/currentprojects/data_science_corps/) with support from Eli Pousson at the [Neighborhood Design Center](https://ndc-md.org/).

## Key Questions
### Help residents answer key questions about trash in their neighborhoods

1. Where are the worst issues with trash in the neighborhood?
2. Are issues with trash getting better or worse over time? (Low Priority)
3. How do issues with trash in the neighborhood compare to other nearby neighborhoods?
4. What types of issues with trash are taking place in the neighborhood? e.g. illegal dumping, trash in yards (aka trash accumulation)

### Help residents work with city agencies to effectively direct city services

1. Are there areas where there are fewer service requests or fewer citations or unpaid citations?

## Features

- Creates a base map of the selected neighborhood.
- Displays the type and location of 311 Service Requests.
- Displays the type and location of ECB Citations.
- Displays the blocks within the neighborhood with their block number and street name.
- Compares the selected neighborhood with its nearby neighborhoods.
- Displays citations over time.
- Knitting the document provides an HTML output with all the information.

## How It Works

This repository contains three main scripts:

- `area_trash_profile.Rmd`: A parameterized RMarkdown report for describing area trash conditions using 311 service request and environmental control board citation data. Supported parameters include `area_name` (the name(s) of the area); `area_type` (a neighborhood, council district, or police district); and `year_start` (used to filter the citation data - requests are filtered to past 6 months). `area_name` and `area_type` must match the supported values for the `get_area` function from the [mapbaltimore package](https://elipousson.github.io/mapbaltimore/reference/get_area.html)).
- `misc.R`: A set of scripts to get the area, requests (using [get_area_requests](https://elipousson.github.io/mapbaltimore/reference/get_area_requests.html)), citations (using [get_area_citations](https://elipousson.github.io/mapbaltimore/reference/get_area_citations.html)), and property data for the basemap (using [get_area_property](https://elipousson.github.io/mapbaltimore/reference/get_area_property.html))). These scripts are loaded into `area_trash_profile.Rmd` using knitr::read_chunks().
- `render_area_trash_profile.R`: Two example scripts showing how to knit the RMarkdown report with parameters for multiple neighborhoods.

For the Rmarkdown report, modifying the parameters changes the output of the code. The code, the scripts, and the graph descriptions should update automatically once it is run with the new parameters. The colons within the code are being used as HTML divs to modify the output after the code is knitted. To get a better idea of how these divisions are being used, check [style.css](https://github.com/elipousson/baltimoretrash_2021/blob/master/R/style.css).
