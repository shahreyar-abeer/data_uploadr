#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny bs4Dash
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic 
    bs4Dash::bs4DashPage(
      dark = TRUE,
      header = bs4Dash::dashboardHeader(
        title = h5("Data uploader", style = "padding-left:.5rem; padding-bottom:.3rem; padding-top:.55rem; font-weight: 600")
        # navMenu(
        #   id = "menu",
        #   navTab(tabName = "single_assets", "Single Asset Plots"),
        #   navTab(tabName = "single_asset_tables", "Single Asset Tables"),
        #   navTab(tabName = "combined_assets", "Combined Assets"),
        #   navTab(tabName = "tab4", "Tab 4")
        # )
      ),
      sidebar = bs4Dash::dashboardSidebar(disable = TRUE),
      
      body = bs4Dash::bs4DashBody(
        
        fresh::use_googlefont("Maven Pro"),
        fresh::use_theme(fresh::create_theme(
          theme = "default",
          fresh::bs4dash_font(
            family_base = "Maven Pro",
            weight_normal = 500,
            weight_bold = 600
          )
        )),
        
        
        fluidRow(
          column(
            width = 4,
            #offset = 2,
            bs4Dash::box(
              #id = ns("table1_box"),
              title = "rightmove data",
              width = NULL,
              collapsible = FALSE,
              status = "gray",
              style = "text-align: center",
              datamods::import_file_ui(
                id = "import_rightmove",
                title = NULL,
                file_extensions = "csv",
                preview_data = FALSE
              )
            ),
            hr(),
            bs4Dash::box(
              #id = ns("table1_box"),
              title = "airbnb data",
              width = NULL,
              collapsible = FALSE,
              status = "gray",
              style = "text-align: center",
              datamods::import_file_ui(
                id = "import_airbnb",
                title = NULL,
                file_extensions = "csv",
                preview_data = FALSE
              )
            ),
            sliderInput("d", "distance", 1, 5000, 500, 10, width = "100%", ticks = FALSE),
            downloadButton("downloadData", "Download merged data", class = "btn-danger")
          ),
          
          column(
            width = 8,
            reactable::reactableOutput("table")
          )
          
        )
        
        
      )
      
      
    )
    
  )
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
 
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'data.uploadr'
    ),
    waiter::autoWaiter()
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}

