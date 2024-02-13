# Create environment to keep tracks of internal state
the <- new.env(parent = emptyenv())

# Simulation parameters for the baseline model
the$params_simu_baseline <- c(
    `std ~ SES` = 0.05,
    `std ~ threat` = .05,
    `std ~ deprivation` = .05,
    `internalizing ~ std` = .05,
    `internalizing ~ SES` = 0.1,
    `internalizing ~ threat` = 0.015,
    `internalizing ~ deprivation` = -0.02,
    `externalizing ~ std` = 0.3,
    `externalizing ~ SES` = 0.1,
    `externalizing ~ threat` = 0.11,
    `externalizing ~ deprivation` = 0.04
)

# Simulation parameters for the mediation model
the$params_simu_mediation <- c(
    `std ~ SES` = 0.05,
    `std ~ threat` = 0.05,
    `std ~ deprivation` = 0.05,
    `repro ~ std` = 0.2,
    `repro ~ SES` = 0.1,
    `repro ~ threat` = 0.08,
    `repro ~ deprivation` = 0.03,
    `internalizing ~ std` = 0.05,
    `internalizing ~ repro` = -0.02,
    `internalizing ~ SES` = 0.1,
    `internalizing ~ threat` = 0.015,
    `internalizing ~ deprivation` = -0.02,
    `externalizing ~ std` = 0.3,
    `externalizing ~ repro` = 0.13,
    `externalizing ~ SES` = 0.1,
    `externalizing ~ threat` = 0.11,
    `externalizing ~ deprivation` = 0.04
)

# Simulation parameters for the moderation model
the$params_simu_moderation <- c(
    `std ~ SES` = 0.05,
    `std ~ threat` = 0.05,
    `std ~ deprivation` = 0.05,
    `repro ~ SES` = 0.1,
    `repro ~ threat` = 0.08,
    `repro ~ deprivation` = 0.03,
    `internalizing ~ std` = 0.05,
    `internalizing ~ repro` = -0.02,
    `internalizing ~ prod_std_repro` = 0.008,
    `internalizing ~ SES` = 0.1,
    `internalizing ~ threat` = 0.015,
    `internalizing ~ deprivation` = -0.02,
    `externalizing ~ std` = 0.3,
    `externalizing ~ repro` = 0.13,
    `externalizing ~ prod_std_repro` = 0.1,
    `externalizing ~ SES` = 0.1,
    `externalizing ~ threat` = 0.11,
    `externalizing ~ deprivation` = 0.04
)


#' Return data simulation parameters for a given model
#' @export
get_params_simu <- function(model_type) {
    params_name <- glue::glue("params_simu_{model_type}")
    the[[params_name]]
}


#' Set data simulation parameters for a given model
#' @export
set_params_simu <- function(x, model_type) {
    params_name <- glue::glue("params_simu_{model_type}")
    old <- the[[params_name]]
    the[[params_name]] <- x
    invisible(old)
}
