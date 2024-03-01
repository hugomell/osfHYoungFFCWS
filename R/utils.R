#' Generate a `_targets.R` that defines the analytical pipeline
#' @export
gen_targets_script <- function() {
  tar_script <- system.file("_targets.R", package = "osfHYoungFFCWS")
  file.copy(fp, ".")
  tar_rmd  <- system.file(
    "vignettes/articles/Data-simulation-and-parameter-recovery-with-brms.Rmd",
    package = "osfHYoungFFCWS")
}

