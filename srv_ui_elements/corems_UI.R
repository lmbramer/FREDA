#' @details simple modal for uploading corems files
corems_manual_upload_modal <- function() {
  modalDialog(
    title = "Core-MS Data Upload",
    "Please upload your Core-MS data files",
    footer = tagList(
      fileInput("corems_files", "Browse/Drag-and-drop", multiple = TRUE)
    )
  )
}

#' @details Modal indicating corems data was successfully uploaded
corems_upload_success_modal <- function(modal_message) {
  modalDialog(
    modal_message, title = "Core-MS Upload Success",
    footer = tagList(
      div(
        style = "float:left",
        bsButton("goto_corems_creation", "Go to CoreMS-data creation tab")
      ),
      modalButton("Dismiss")
    )
  )
}

#' @details Modal indicating ftmsRanalysis::CoreMSData was successfully created.
corems_obj_creation_modal <- function() {
  modalDialog(
    "Your CoreMS data object was successfully created, continue to filtering sub-tab or dismiss to review table/plots",
    title = "Object Creation Success!",
    footer = tagList(
      div(
        style = "float:left",
        bsButton("goto_corems_filter", "Go to CoreMS filtering tab")
      ),
      modalButton("Dismiss")
    )
  )
}

#' @details Modal indicating ftmsRanalysis::conf_filter was successfully applied.
corems_filter_modal <- function() {
  modalDialog(
    "Your CoreMS data object was successfully filtered, continue to formula assignment sub-tab or dismiss to review table/plots",
    title = "Filter Success!",
    footer = tagList(
      div(
        style = "float:left",
        bsButton("goto_corems_formula", "Go to CoreMS formula assignment tab")
      ),
      modalButton("Dismiss")
    )
  )
}

#' @details Modal indicating unique formulae have been assigned
corems_unq_mf_modal <- function() {
  modalDialog(
    "Unique molecular formula were assigned to your Core-MS object, convert your object to a peakData object to continue in FREDA, or dismiss to review.",
    title = "Formulas Assigned!",
    footer = tagList(
      div(
        style = "float:left",
        actionButton("corems_to_peakdata_modal", "Convert your Core-MS data to peakData")
      ),
      modalButton("Dismiss")
    )
  )
}

##
#' Dropdowns for arguments to as.CoreMSData, all are named as
#' output$<as.coreMSData argument name>
#'

#' Helper function to make a dropdown that is  mutually exclusive with other
#' dropdowns that pull from the columns of the imported corems data.
mutually_exclusive_dropdown <- function(id, title, selected = NULL) {
  renderUI({
    choices = union(
      input[[id]],
      coreMS_remaining_choices()
    ) %>% setdiff(NULLSELECT__)

    choices = c("Select one" = NULLSELECT__, choices)
    
    if(!is.null(input[[id]])) {
      selected = input[[id]]
    }

    pickerInput(id,
      title,
      choices = choices,
      selected = selected
    )
  })
}

output$index_cname_UI <- mutually_exclusive_dropdown(
  "index_cname", "Index Column:", "Index"
)

output$obs_mass_cname_UI <- mutually_exclusive_dropdown(
  "obs_mass_cname", "Observed Mass Column:", "m/z"
)

output$calc_mass_cname_UI <- mutually_exclusive_dropdown(
  "calc_mass_cname", "Calculated Mass Column:", "Calculated m/z"
)

output$calib_mass_cname_UI <- mutually_exclusive_dropdown(
  "calib_mass_cname", "Calibrated Mass Column:", "Calibrated m/z"
)

output$pheight_cname_UI <- mutually_exclusive_dropdown(
  "pheight_cname", "Peak Height Column:", "Peak Height"
)

output$error_cname_UI <- mutually_exclusive_dropdown(
  "error_cname", "Mass Error Column:", "m/z Error (ppm)"
)

output$conf_cname_UI <- mutually_exclusive_dropdown(
  "conf_cname", "Confidence Score Column:", "Confidence Score"
)

output$heteroatom_cname_UI <- mutually_exclusive_dropdown(
  "heteroatom_cname", "Heteroatom Column:", "Heteroatom Class"
)

output$iontype_cname_UI <- mutually_exclusive_dropdown(
  "iontype_cname", "Ion Type Column:", "Ion Type"
)

output$file_cname_UI <- mutually_exclusive_dropdown(
  "file_cname", "Filename/Sample Column:", "Filename"
)

output$monoiso_index_cname_UI <- mutually_exclusive_dropdown(
  "monoiso_index_cname", "Mono Isotopic Index Column:", "Mono Isotopic Index"
)

output$mf_cname_UI <- mutually_exclusive_dropdown(
  "mf_cname", "Molecular Formula Column:", "Molecular Formula"
)

#' @details Preview table
output$cms_raw_data <- DT::renderDT(
  corems_revals[['combined_tables']],
  options = list(dom = 'ftp',
    scrollX = TRUE)
)

#' @details display plot of unique masses per sample
#' @app_location CoreMS Creation Tab
output$cmsdat_plot <- renderPlotly({
  req(cms_data())
  p <- plot(cms_data())
  p %>% 
    layout(
      xaxis = list(tickangle = -45),
      margin = list(b = 160)
    )
})

#' @details data table with kept/removed peaks
#' @app_location Confidence Filtering Tab
output$filt_peaks_dt <- DT::renderDT(
  ftmsRanalysis:::conf_filter_dt(cms_data(), input$min_conf),
  options = list(dom = 't', scrollX = T)
)

#' @details Plot of filtered corems data
#' @app_location Confidence Filtering Tab
output$cms_filt_plot <- renderPlotly({
  validate(need(tryCatch(cms_data_filtered(), error=function(e) NULL), "Create your filtered data to view filter plot"))
  p <- plot(cms_data_filtered())
  p %>% 
    layout(
      xaxis = list(tickangle = -45),
      margin = list(b = 160)
    )
})

#' @details display mass error plot with min_conf slider values
#' @app_location Confidence Filtering Tab
output$me_plot <- renderPlotly({
  validate(
    need(tryCatch(cms_data(), error=function(e) NULL), "No CoreMS object found.  Please create your coreMS data object in the 'Create CoreMS Object tab'.")
  )
  mass_error_plot(cms_data(), min_conf = input$min_conf)
})

#' @details Molecular formula plot
#' @app_location Unique molecular formula assignment tab
output$mf_plot <- renderPlotly({
  validate(need(cms_dat_unq_mf(), "Please assign molecular formulae to your CoreMS data"))
  p <- plot(cms_dat_unq_mf())
  p %>% layout(
    xaxis = list(tickangle = -45),
    margin = list(b = 160)
  )
})

#' @details data table with kept/removed peaks
#' @app_location Confidence Filtering Tab
output$filt_peaks_dt <- DT::renderDT(
  ftmsRanalysis:::conf_filter_dt(cms_data(), input$min_conf),
  options = list(dom = 't', scollX = T)
)

#' @details Isotopic peaks after formula assignment
#' @app_location Core-MS formula assignment tab
output$assign_formula_iso <- DT::renderDT({
  req(cms_dat_unq_mf())
  cms_dat_unq_mf()$iso_data
},
options = list(dom = 't', scrollX = T)
)

#' @details Mono-isotopic peaks after formula assignment
#' @app_location Core-MS formula assignment tab
output$assign_formula_monoiso <- DT::renderDT({
  req(cms_dat_unq_mf())
  cms_dat_unq_mf()$monoiso_data
},
options = list(dom = 't', scrollX = T)
)

#' @details Button to convert corems data to ftmsRanalysis peakData
output$corems_to_peakdata_UI <- renderUI({
  req(cms_dat_unq_mf())
  req(grepl("^CoreMS", input$top_page))
  actionButton("corems_to_peakdata", "Convert to peak data", class = "btn-primary")
})
