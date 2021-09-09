# Sample render script exports two report for southeast Baltimore neighborhoods
purrr::walk(
  c("McElderry Park", "Highlandtown"),
  ~ rmarkdown::render(
    input = "R/area_trash_profile.Rmd",
    output_dir = "output",
    output_file = glue::glue("{janitor::make_clean_names(.x)}_trash_report.html"),
    params = list(area_name = .x,
                  area_type = "neighborhood",
                  asp = "6:4")
  )
)


# Same render script showing how to pass area name and label
purrr::walk2(
  c("Ellwood Park/Monument", "Baltimore Highlands"),
  c("Ellwood Park", "Baltimore Highlands"),
  ~ rmarkdown::render(
    input = "R/area_trash_profile.Rmd",
    output_dir = "output",
    output_file = glue::glue("{janitor::make_clean_names(.x)}_trash_report.html"),
    params = list(area_name = .x,
                  area_label = .y,
                  area_type = "neighborhood",
                  asp = "6:4")
  )
)



