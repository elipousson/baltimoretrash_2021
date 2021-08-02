area_property <-
  get_area_property(area = area, crop = FALSE)

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

street_blocks <- area_property %>% 
  group_by(street_block_number) %>% 
  summarise(
    geometry = st_union(geometry)
  )
