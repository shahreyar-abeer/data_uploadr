#' merge_rightmove_airbnb 
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#' @noRd


get_listings_for_single_property = function(row, airbnb_data, d) {
  
  loc = c(row$longitude, row$latitude)
  locs = as.matrix(airbnb_data[, .(longitude, latitude)])
  airbnb_data$distance = geosphere::distHaversine(loc, locs)
  airbnb_data = airbnb_data[distance <= d & bedrooms >= row$no_bedrooms, ]
  listings = stringr::str_c(airbnb_data$property_id, collapse = ",")
  return(listings)
}

merge_rightmove_airbnb = function(rightmove_data, airbnb_data, d) {
  rightmove_data = rightmove_data[, listings := get_listings_for_single_property(.SD, airbnb_data, d = d), by = ref_no]
  rightmove_data = rightmove_data[, list(property_id = stringr::str_split(listings, ",")[[1]]), by = ref_no:air_dna_city]
  rightmove_data[airbnb_data, on = "property_id", nomatch = 0][order(air_dna_city, ref_no)]
}
