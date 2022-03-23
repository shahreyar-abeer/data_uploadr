

drop_airbnb = c("Listing Main Image URL", "Listing Images", "Amenities")

airbnb = data.table::fread("../gb_LTM_Property_Extended_Match_2022-03-07.csv",
                           drop = drop_airbnb)
rightmove = data.table::fread("../rightmove_20220318 1013.csv")

airbnb = janitor::clean_names(airbnb)
rightmove = janitor::clean_names(rightmove)

get_listings_for_single_property = function(single_data, airbnb_data, d) {
  
  loc = c(single_data$longitude, single_data$latitude)
  locs = as.matrix(airbnb_data[, .(longitude, latitude)])
  airbnb_data$distance = geosphere::distHaversine(loc, locs)
  airbnb_data = airbnb_data[distance <= d & bedrooms >= single_data$no_bedrooms, ]
  listings = stringr::str_c(airbnb_data$property_id, collapse = ",")
  return(listings)
}

merge_rightmove_airbnb = function(rightmove_data, airbnb_data, d) {
  rightmove_data = rightmove_data[, listings := get_listings_for_single_property(.SD, airbnb, d = d), by = ref_no]
  rightmove_data = rightmove_data[, list(property_id = stringr::str_split(listings, ",")[[1]]), by = ref_no:air_dna_city]
  rightmove_data[airbnb_data, on = "property_id", nomatch = 0][order(air_dna_city, ref_no)]
}

x5 = merge_rightmove_airbnb(rightmove, airbnb, 500)

View(x5)
