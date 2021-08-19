# Define list of trash-related request types
select_request_types <-
  c(
    "HCD-Sanitation Property",
    "HCD-Illegal Dumping",
    "SW-Dirty Street",
    "SW-Dirty Alley" #,
    # Exclude request types with few requests
    #"SW-Municipal Trash Can Concern",
    #"SW-Municipal Trash Can Stolen/Lost",
    #"SW-Public (Corner) Trash Can Issue",
    #"SW-Public (Corner) Trash Can Request/Removal",
    #"SW-Trash Can/Recycling Container Complaint",
    #"SW-Park Cans"
  )

months_prior <- 6

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
