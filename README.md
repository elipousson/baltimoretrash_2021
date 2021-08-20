
# baltimoretrash_2021

<!-- badges: start -->
<!-- badges: end -->

The goal of baltimoretrash_2021 is to explore service requests, ECB citations, and other related open data to present an area-level analysis of trash and environmental health conditions in Baltimore, Maryland. This project is developed by the [Neighborhood Design Center](https://ndc-md.org/) with support from the [University of Baltimore Data Science Corps program](https://bniajfi.org/currentprojects/data_science_corps/).

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

Modifying the parameters changes the output of the code. The code, the scripts, and the graph descriptions should update automatically once it is run with the new parameters.
- `area_name` specifies the chosen neighborhood (or group of neighborhoods).
- `area_type` can be either "neighborhood" or "union."
- `year_start` can be changed to any year from 2016 onwards.

The colons within the code are being used as HTML divs to modify the output after the code is knitted. To get a better idea of how these divisions are being used, check the [style_sheet.css](https://github.com/elipousson/baltimoretrash_2021/blob/master/R/style_sheet.css) file.
