# Sample render script exports four reports for different southeast Baltimore neighborhoods
purrr::map(
  c("Ellwood Park/Monument", "Baltimore Highlands", "McElderry Park", "Highlandtown"),
  ~ rmarkdown::render(
    input = "R/trash_2.Rmd",
    output_dir = "output",
    output_file = glue::glue("{janitor::make_clean_names(.x)}_trash_report.html"),
    params = list(area_name = .x,
                  area_type = "neighborhood",
                  asp = "6:4")
  )
)


