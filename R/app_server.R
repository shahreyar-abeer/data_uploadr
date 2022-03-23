#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny data.table
#' @noRd
app_server <- function( input, output, session ) {
  # Your application server logic 
  
  options(shiny.maxRequestSize=1500*1024^2)
  
  r = reactiveValues(
    merged_data = NULL
  )
  
  data_rightmove = datamods::import_file_server(
    id = "import_rightmove",
    read_fns = list(
      csv = function(file) {
        data.table::fread(file) %>% 
          janitor::clean_names()
      }
    ),
    return_class = "data.table",
    btn_show_data = FALSE
  )
  
  data_airbnb = datamods::import_file_server(
    id = "import_airbnb",
    read_fns = list(
      csv = function(file) {
        data.table::fread(file, drop = c("Listing Main Image URL", "Listing Images", "Amenities")) %>% 
          janitor::clean_names()
      }
    ),
    return_class = "data.table",
    btn_show_data = FALSE
  )
  
  # observeEvent(data_rightmove$data(), {
  #   print(data_rightmove$data())
  # })
  # 
  # observeEvent(data_airbnb$data(), {
  #   print(str(data_airbnb$data()))
  # })
  
  output$table = reactable::renderReactable({
    req(data_airbnb$data(), data_rightmove$data(), input$d)
    
    print("here")
    r$merged_data = merge_rightmove_airbnb(data_rightmove$data()[c(1,4),], data_airbnb$data()[1:1000], input$d)
    r$merged_data %>% 
      reactable::reactable(
        defaultPageSize = 5,
        columns = list(
          url = reactable::colDef(
            html = TRUE
          )
        ),
        theme = reactable::reactableTheme(
          color = "hsl(233, 9%, 87%)",
          backgroundColor = "hsl(233, 9%, 19%)",
          borderColor = "hsl(233, 9%, 22%)",
          stripedColor = "hsl(233, 12%, 22%)",
          highlightColor = "hsl(233, 12%, 24%)",
          inputStyle = list(backgroundColor = "hsl(233, 9%, 25%)"),
          selectStyle = list(backgroundColor = "hsl(233, 9%, 25%)"),
          pageButtonHoverStyle = list(backgroundColor = "hsl(233, 9%, 25%)"),
          pageButtonActiveStyle = list(backgroundColor = "hsl(233, 9%, 28%)")
        )
      )
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("matches", ".csv", sep = "")
    },
    content = function(file) {
      vroom::vroom_write(r$merged_data, file, delim = ",")
    }
  )
  
}
