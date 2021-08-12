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
      description = replace( # Fixes one typo where "Accumulation" was spelled with two I's.
        description, description == "TRASH ACCUMULATIION", "TRASH ACCUMULATION"
      )
    )

  # TODO: Decide if limiting citation data to last 6 months (or 12 months) is helpful in simplifying the analysis or presentation of the analysis
  recent_citations <- citations %>%
    filter(
      violation_date >= (lubridate::ymd(Sys.Date()) - lubridate::dmonths(months_prior))
    )
}

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
