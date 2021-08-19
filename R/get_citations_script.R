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
        description = "TRASH"
      )
    )

  citations <- citations %>%
    filter(
      year(violation_date) >= params$year_start
    ) %>%
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
      #Changes spelling of Description
      description = case_when(
        description == "BULK TRASH" ~ "Bulk Trash",
        description == "EXTERIOR SANITARY MAINTENANCE - TRASH, GARBAGE AND DEBRIS" ~ "Exterior Sanitary Maintenance",
        description == "SANITARY MAINTENANCE - OCCUPANT TRASH DISPOSAL" ~ "Sanitary Maintenance",
        description == "TRASH ACCUMULATION" ~ "Trash Accumulation"
      )
    )

  # TODO: Decide if limiting citation data to last 6 months (or 12 months) is helpful in simplifying the analysis or presentation of the analysis
  recent_citations <- citations %>%
    filter(
      violation_date >= (lubridate::ymd(Sys.Date()) - lubridate::dmonths(months_prior))
    )
}

#Use "area_citations" to use citations that are in the selected neighborhood ONLY.
#Using the variable "citations" will include the neighborhood citations, and the nearby areas' citations combined
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
      as.character(knitr::combine_words(area$name))
    )
  )


citations_source <- "Source: Environmental Control Board (ECB) Citations/Open Baltimore"
