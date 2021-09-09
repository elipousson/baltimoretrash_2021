## ----get_area----------------------------------------------------------------------------

area <- get_area(
  params$area_type,
  params$area_name
)

nearby_areas <- get_nearby_areas(area, type = params$area_type)

if (is.null(params$area_label)) {
  area_label <- as.character(knitr::combine_words(params$area_name))
} else {
  area_label <- params$area_label
}

area_layer <- geom_sf(data = area, fill = NA, color = "black", linetype = "dashed")

## ----get_requests----------------------------------------------------------------------------

months_prior <- 6

# Define list of trash-related request types
select_request_types <-
  c(
    "HCD-Sanitation Property",
    "HCD-Illegal Dumping",
    "SW-Dirty Street",
    "SW-Dirty Alley"
  )

# Additional trash-related request types with limited use based on testing
# c("SW-Municipal Trash Can Concern", "SW-Municipal Trash Can Stolen/Lost", "SW-Public (Corner) Trash Can Issue",
#  "SW-Public (Corner) Trash Can Request/Removal", "SW-Trash Can/Recycling Container Complaint", "SW-Park Cans")

possible_get_area_requests <-
  purrr::possibly(
    .f = get_area_requests,
    otherwise = NULL
  )

# Get 2021 requests of each type
requests <-
  purrr::map_dfr(
    select_request_types,
    ~ possible_get_area_requests(
      area = bind_rows(area, nearby_areas),
      year = 2021,
      request_type = .x,
      trim = TRUE
    )
  ) %>%
  filter(
    # Filter to requests created in past 6 months
    created_date >= (lubridate::ymd(Sys.Date()) - lubridate::dmonths(months_prior))
  ) %>%
  mutate(
    # Remove agency prefix for service request type
    sr_type = str_remove(sr_type, "(HCD-)|(SW-)")
  )


# Filtering requests by attribute only works if the area type is neighborhood, council district, or police district
# Using "area_requests" will only call the requests within the chosen neighborhood.
# Using "requests" will call the requests within the chosen neighborhood, AND the requests from the nearby areas combined.
if (params$area_type == "neighborhood") {
  requests <- requests %>%
    filter(neighborhood %in% c(params$area_name, nearby_areas$name))

  area_requests <- requests %>%
    filter(neighborhood %in% params$area_name)

  nearby_area_requests <- requests %>%
    filter(neighborhood %in% nearby_areas$name)
} else if (params$area_type == "council district") {
  requests <- requests %>%
    filter(council_district %in% c(params$area_name, nearby_areas$name))

  area_requests <- requests %>%
    filter(council_district %in% params$area_name)

  nearby_area_requests <- requests %>%
    filter(council_district %in% nearby_areas$name)
} else if (params$area_type == "police district") {
  requests <- requests %>%
    filter(police_district %in% c(params$area_name, nearby_areas$name))

  area_requests <- requests %>%
    filter(police_district %in% params$area_name)

  nearby_area_requests <- requests %>%
    filter(police_district %in% nearby_areas$name)
}

## ----get_citations----------------------------------------------------------------------------

# YYYY-MM-DD format required for get_area_citations start_date parameter
start_date <- paste0(params$year_start, "-01-01")


possible_get_area__citations <-
  purrr::possibly(
    .f = get_area_citations,
    otherwise = NULL
  )

if (params$area_type %in% c("neighborhood", "council district", "police district")) {
  citations <-
    purrr::map_dfr(
      c(params$area_name, nearby_areas$name),
      ~ possible_get_area__citations(
        area_type = params$area_type,
        area_name = .x,
        description = "TRASH",
        start_date = start_date
      )
    )

  citations <- citations %>%
    # Pull street number (address), block number, and street name from location
    mutate(
      street_number = readr::parse_number(violation_location),
      block_number = floor(street_number / 100) * 100,
      street_name = str_trim(str_remove(violation_location, glue::glue("^{street_number}|^0{street_number}"))),
      citation_status = case_when(
        citation_status == "A" ~ "Appealed",
        citation_status == "O" ~ "Open",
        citation_status == "P" ~ "Paid",
        citation_status == "V" ~ "Voided", # TODO: Should voided citations be excluded?
      ),
      # Fixes one typo where "Accumulation" was spelled with two I's.
      description = replace(
        description, description == "TRASH ACCUMULATIION", "TRASH ACCUMULATION"
      ),
      # Changes spelling of Description
      description = case_when(
        description == "BULK TRASH" ~ "Bulk Trash",
        description == "EXTERIOR SANITARY MAINTENANCE - TRASH, GARBAGE AND DEBRIS" ~ "Exterior Sanitary Maintenance",
        description == "SANITARY MAINTENANCE - OCCUPANT TRASH DISPOSAL" ~ "Trash Disposal",
        description == "TRASH ACCUMULATION" ~ "Trash Accumulation"
      )
    )

  # TODO: Decide if limiting citation data to last 6 months (or 12 months) is helpful in simplifying the analysis or presentation of the analysis
  recent_citations <- citations %>%
    filter(
      violation_date >= (lubridate::ymd(Sys.Date()) - lubridate::dmonths(months_prior))
    )
}

# Use "area_citations" to use citations that are in the selected neighborhood ONLY.
# Using the variable "citations" will include the neighborhood citations, and the nearby areas' citations combined
if (params$area_type == "neighborhood") {
  area_citations <- citations %>%
    filter(neighborhood %in% params$area_name)

  nearby_citations <- citations %>%
    filter(neighborhood %in% nearby_areas$name)
} else if (params$area_type == "council district") {
  area_citations <- citations %>%
    filter(council_district %in% params$area_name)

  nearby_citations <- citations %>%
    filter(council_district %in% nearby_areas$name)
} else if (params$area_type == "police district") {
  area_citations <- citations %>%
    filter(police_district %in% params$area_name)

  nearby_citations <- citations %>%
    filter(police_district %in% nearby_areas$name)
}

citations <- citations %>%
  mutate(
    nearby = if_else(
      citation_no %in% nearby_citations$citation_no,
      "Nearby areas",
      area_label
    )
  )

citations_source <- "Source: Environmental Control Board (ECB) Citations/Open Baltimore"

## ----get_area_blocks----------------------------------------------------------------------------

# calls the selected area
area_property <-
  get_area_property(area = area, crop = TRUE)

# Combines the block number with the street name
area_property <- area_property %>%
  mutate(
    block_number = floor(bldg_num / 100) * 100,
    street_block_number = paste(block_number, street_dirpre, street_name, street_type)
  )

blocks <- area_property %>%
  group_by(block) %>%
  summarise(
    geometry = st_union(geometry)
  )

# Creates new spatial data with unioned blocks
street_blocks <- area_property %>%
  group_by(street_block_number) %>%
  summarise(
    geometry = st_union(geometry)
  )
