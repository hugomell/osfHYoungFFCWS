#' Copy files to run demonstration pipeline in root
#' @export
setup_demo_pipeline <- function() {
  tar_script <- system.file("_targets.R", package = "osfHYoungFFCWS")
  tar_yaml <- system.file("_targets.yaml", package = "osfHYoungFFCWS")
  tar_rmd  <- system.file(
    "data-simulation-and-parameter-recovery-with-brms.rmd",
    package = "osfhyoungffcws")
  file.copy(tar_script, ".")
  file.copy(tar_yaml, ".")
  file.copy(tar_rmd, ".")
}

#' Run demonstration pipeline
#' @export
run_demo_pipeline <- function(gitpod = FALSE) {
  if (gitpod == FALSE) {
    setup_demo_pipeline()  
  }
  targets::tar_make()
}
