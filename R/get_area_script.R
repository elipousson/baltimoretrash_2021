# Get an sf object with all neighborhoods unioned into a single area
area <- get_area(params$area_type,
                 params$area_name,
                 union = params$union)

nearby_areas <- get_nearby_areas(area, type = params$area_type)

if (params$union) {
  area$name <- params$union_name
  
  # Get an sf object with no union
  area_not_union <-
    get_area(
      params$area_type,
      params$area_name,
      union = FALSE)
}

area_layer <- geom_sf(data = area, fill = NA, color = "black", linetype = "dashed")
