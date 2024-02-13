library(tidyr)
library(ggplot2)

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


#' Generate the model formula for the given model type
gen_model_formula <- function(model_type) {
    params_name <- glue::glue("params_simu_{model_type}")
    params <- the[[params_name]]

    # lavaan syntax for baseline model
    if (model_type == "baseline") {
        formula <- glue::glue(
            "std ~ {params[1]} * SES + {params[2]} * threat\\
            + {params[3]} * deprivation
            ",
            "internalizing ~ {params[4]} * std + {params[5]} * SES\\
            + {params[6]} * threat + {params[7]} * deprivation
            ",
            "externalizing ~ {params[8]} * std + {params[9]} * SES\\
            + {params[10]} * threat + {params[11]} * deprivation
            "
        )
    # lavaan syntax for mediation model
    } else if (model_type == "mediation") {
        formula <- glue::glue(
            "std ~ {params[1]} * SES + {params[2]} * threat\\
            + {params[3]} * deprivation
            ",
            "repro ~ {params[4]} * std + {params[5]} * SES\\
            + {params[6]} * threat + {params[7]} * deprivation
            ",
            "internalizing ~ {params[8]} * std + {params[9]} * repro\\
             + {params[10]} * SES + {params[11]} * threat\\
             + {params[12]} * deprivation
            ",
            "externalizing ~ {params[13]} * std + {params[14]} * repro\\
             + {params[15]} * SES + {params[16]} * threat\\
             + {params[17]} * deprivation
            "
        )
    # lavaan syntax for moderation model
    } else {
        formula <- glue::glue(
            "std ~ {params[1]} * SES + {params[2]} * threat\\
            + {params[3]} * deprivation
            ",
            "repro ~ {params[4]} * SES + {params[5]} * threat\\
            + {params[6]} * deprivation
            ",
            "internalizing ~ {params[7]} * std + {params[8]} * repro\\
             + {params[9]} * prod_std_repro + {params[10]} * SES\\
             + {params[11]} * threat + {params[12]} * deprivation
            ",
            "externalizing ~ {params[13]} * std + {params[14]} * repro\\
             + {params[15]} * prod_std_repro + {params[16]} * SES\\
             + {params[17]} * threat + {params[18]} * deprivation
            "
        )
    }

    return(formula)
}


#' Simulate data for a given model
#' @export
simulate_dataset <- function(model_type, seed = 1234) {
    set.seed(seed)

    if (model_type == "baseline") {
        formula <- gen_model_formula("baseline")
        skewness <- c(0, 0.9, 0.9, 0.8, 0.5, 0.2)
        kurtosis <- c(0, 0.5, 0.6,   0, 0.2, 0)
    } else if (model_type == "mediation") {
        formula <- gen_model_formula("mediation")
        skewness <- c(0, 0.7, 0.9, 0.9, 0.8, 0.5, 0.2)
        kurtosis <- c(0, 0.2, 0.5, 0.6,   0, 0.2, 0)
    } else {
        formula <- gen_model_formula("moderation")
        skewness <- c(0, 0.7, 0.9, 0.9, 0.8, 0.5, 0.2, 0)
        kurtosis <- c(0, 0.2, 0.5, 0.6,   0, 0.2,   0, 0)
    }

    fake_data <- lavaan::simulateData(
        model = formula, model.type = "sem", int.ov.free = TRUE,
        auto.var = TRUE, auto.cov.y = TRUE, sample.nobs = 2000L,
        skewness = skewness,
        kurtosis = kurtosis
        )

    return(fake_data)
}


hist_sim <- function(d) {
    d |>
       pivot_longer(colnames(d)) |>
        ggplot(aes(x = value)) +
            geom_histogram() +
            facet_wrap(~ name, scales = "free")
}
