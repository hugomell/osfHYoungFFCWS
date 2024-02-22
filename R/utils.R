#' Generate a `_targets.R` that defines the analytical pipeline
#' @export
gen_targets_script <- function() {
    fp <- system.file("_targets.R", package = "osfHYoungFFCWS")
    file.copy(fp, ".")
}

