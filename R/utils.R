#' Generate a `_targets.R` that defines the analytical pipeline
#' @export
setup_demo_pipeline <- function() {
  tar_script <- system.file("_targets.R", package = "osfHYoungFFCWS")
  tar_yaml <- system.file("_targets.yaml", package = "osfHYoungFFCWS")
  tar_rmd  <- system.file(
    "Data-simulation-and-parameter-recovery-with-brms.Rmd",
    package = "osfHYoungFFCWS")
  file.copy(tar_script, ".")
  file.copy(tar_yaml, ".")
  file.copy(tar_yaml, ".")
}

