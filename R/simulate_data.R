# Create environment to keep tracks of internal state
the <- new.env(parent = emptyenv())

# Simulation parameters for the baseline model
the$params_simu_baseline <- c(
  `std ~ SES` = 0.05,
  `std ~ threat` = 0.05,
  `std ~ deprivation` = 0.05,
  `std ~ stochasticity` = 0.01,
  `std ~ volatility` = 0.1,
  `internalizing ~ std` = 0.05,
  `internalizing ~ SES` = 0.1,
  `internalizing ~ threat` = 0.015,
  `internalizing ~ deprivation` = -0.02,
  `internalizing ~ stochasticity` = -0.03,
  `internalizing ~ volatility` = 0.06,
  `externalizing ~ std` = 0.3,
  `externalizing ~ SES` = 0.1,
  `externalizing ~ threat` = 0.11,
  `externalizing ~ deprivation` = 0.04,
  `externalizing ~ stochasticity` = -0.01,
  `externalizing ~ volatility` = 0.04
)

# Simulation parameters for the mediation model
the$params_simu_mediation <- c(
  `std ~ SES` = 0.05,
  `std ~ threat` = 0.05,
  `std ~ deprivation` = 0.05,
  `std ~ stochasticity` = 0.01,
  `std ~ volatility` = 0.1,
  `repro ~ std` = 0.2,
  `repro ~ SES` = 0.1,
  `repro ~ threat` = 0.08,
  `repro ~ deprivation` = 0.03,
  `repro ~ stochasticity` = 0.01,
  `repro ~ volatility` = 0.1,
  `withdrawal ~ std` = 0.2,
  `withdrawal ~ SES` = 0.1,
  `withdrawal ~ threat` = 0.08,
  `withdrawal ~ deprivation` = 0.03,
  `withdrawal ~ stochasticity` = 0.01,
  `withdrawal ~ volatility` = 0.1,
  `internalizing ~ std` = 0.05,
  `internalizing ~ repro` = -0.02,
  `internalizing ~ withdrawal` = 0.2,
  `internalizing ~ SES` = 0.1,
  `internalizing ~ threat` = 0.015,
  `internalizing ~ deprivation` = -0.02,
  `internalizing ~ stochasticity` = -0.03,
  `internalizing ~ volatility` = 0.06,
  `externalizing ~ std` = 0.3,
  `externalizing ~ repro` = 0.13,
  `externalizing ~ withdrawal` = -0.1,
  `externalizing ~ SES` = 0.1,
  `externalizing ~ threat` = 0.11,
  `externalizing ~ deprivation` = 0.04,
  `externalizing ~ stochasticity` = -0.01,
  `externalizing ~ volatility` = 0.04
)

# Simulation parameters for the moderation model
the$params_simu_moderation <- c(
  `std ~ SES` = 0.05,
  `std ~ threat` = 0.05,
  `std ~ deprivation` = 0.05,
  `std ~ stochasticity` = 0.01,
  `std ~ volatility` = 0.1,
  `repro ~ SES` = 0.1,
  `repro ~ threat` = 0.08,
  `repro ~ deprivation` = 0.03,
  `repro ~ stochasticity` = 0.01,
  `repro ~ volatility` = 0.1,
  `withdrawal ~ SES` = 0.1,
  `withdrawal ~ threat` = 0.08,
  `withdrawal ~ deprivation` = 0.03,
  `withdrawal ~ stochasticity` = 0.01,
  `withdrawal ~ volatility` = 0.1,
  `internalizing ~ std` = 0.05,
  `internalizing ~ repro` = -0.02,
  `internalizing ~ prod_std_repro` = 0.008,
  `internalizing ~ withdrawal` = 0.2,
  `internalizing ~ prod_std_withdrawal` = 0.008,
  `internalizing ~ SES` = 0.1,
  `internalizing ~ threat` = 0.015,
  `internalizing ~ deprivation` = -0.02,
  `internalizing ~ stochasticity` = -0.03,
  `internalizing ~ volatility` = 0.06,
  `externalizing ~ std` = 0.3,
  `externalizing ~ repro` = 0.13,
  `externalizing ~ prod_std_repro` = 0.1,
  `externalizing ~ withdrawal` = -0.1,
  `externalizing ~ prod_std_withdrawal` = -0.01,
  `externalizing ~ SES` = 0.1,
  `externalizing ~ threat` = 0.11,
  `externalizing ~ deprivation` = 0.04,
  `externalizing ~ stochasticity` = -0.01,
  `externalizing ~ volatility` = 0.04
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
#' @export
gen_model_formula <- function(model_type) {
  params_name <- glue::glue("params_simu_{model_type}")
  params <- the[[params_name]]

  # lavaan syntax for baseline model
  if (model_type == "baseline") {
    formula <- glue::glue(
      "std ~ {params[1]} * SES + {params[2]} * threat\\
      + {params[3]} * deprivation\\
      + {params[4]} * stochasticity + {params[5]} * volatility
      ",
      "internalizing ~ {params[6]} * std + {params[7]} * SES\\
      + {params[8]} * threat + {params[9]} * deprivation\\
      + {params[10]} * stochasticity + {params[11]} * volatility
      ",
      "externalizing ~ {params[12]} * std + {params[13]} * SES\\
      + {params[14]} * threat + {params[15]} * deprivation\\
      + {params[16]} * stochasticity + {params[17]} * volatility
      "
    )
    # lavaan syntax for mediation model
  } else if (model_type == "mediation") {
    formula <- glue::glue(
      "std ~ {params[1]} * SES + {params[2]} * threat\\
      + {params[3]} * deprivation\\
      + {params[4]} * stochasticity + {params[5]} * volatility
      ",
      "repro ~ {params[6]} * std + {params[7]} * SES\\
      + {params[8]} * threat + {params[9]} * deprivation\\
      + {params[10]} * stochasticity + {params[11]} * volatility
      ",
      "withdrawal ~ {params[12]} * std + {params[13]} * SES\\
      + {params[14]} * threat + {params[15]} * deprivation\\
      + {params[16]} * stochasticity + {params[17]} * volatility
      ",
      "internalizing ~ {params[18]} * std + {params[19]} * repro\\
      + {params[20]} * withdrawal\\
      + {params[21]} * SES + {params[22]} * threat\\
      + {params[23]} * deprivation\\
      + {params[24]} * stochasticity + {params[25]} * volatility
      ",
      "externalizing ~ {params[26]} * std + {params[27]} * repro\\
      + {params[28]} * withdrawal\\
      + {params[29]} * SES + {params[30]} * threat\\
      + {params[31]} * deprivation\\
      + {params[32]} * stochasticity + {params[33]} * volatility
      "
    )
    # lavaan syntax for moderation model
  } else {
    formula <- glue::glue(
      "std ~ {params[1]} * SES + {params[2]} * threat\\
      + {params[3]} * deprivation\\
      + {params[4]} * stochasticity + {params[5]} * volatility
      ",
      "repro ~ {params[6]} * SES + {params[7]} * threat\\
      + {params[8]} * deprivation\\
      + {params[9]} * stochasticity + {params[10]} * volatility
      ",
      "withdrawal ~ {params[11]} * SES + {params[12]} * threat\\
      + {params[13]} * deprivation\\
      + {params[14]} * stochasticity + {params[15]} * volatility
      ",
      "internalizing ~ {params[16]} * std + {params[17]} * repro\\
      + {params[18]} * prod_std_repro\\
      + {params[19]} * withdrawal + {params[20]} * prod_std_withdrawal\\
      + {params[21]} * SES\\
      + {params[22]} * threat + {params[23]} * deprivation\\
      + {params[24]} * stochasticity + {params[25]} * volatility
      ",
      "externalizing ~ {params[26]} * std + {params[27]} * repro\\
      + {params[28]} * prod_std_repro\\
      + {params[29]} * withdrawal + {params[30]} * prod_std_withdrawal\\
      + {params[31]} * SES\\
      + {params[32]} * threat + {params[33]} * deprivation\\
      + {params[34]} * stochasticity + {params[35]} * volatility
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
    skewness <- c(0, 0.9, 0.9, 0.8, 0.9, 0.9, 0.5, 0.2)
    kurtosis <- c(0, 0.5, 0.6,   0, 0.6, 0.6, 0.2, 0)
  } else if (model_type == "mediation") {
    formula <- gen_model_formula("mediation")
    skewness <- c(0, 0.7, 0.9, 0.9, 0.8, 0.9, 0.9, 0.9, 0.5, 0.2)
    kurtosis <- c(0, 0.2, 0.5, 0.6,   0, 0.6, 0.6, 0.6, 0.2, 0)
  } else {
    formula <- gen_model_formula("moderation")
    skewness <- c(0, 0.7, 0.9, 0.9, 0.8, 0.9, 0.9, 0.9, 0.5, 0.2, 0, 0)
    kurtosis <- c(0, 0.2, 0.5, 0.6,   0, 0.6, 0.6, 0.6, 0.2,   0, 0, 0)
  }

  fake_data <- lavaan::simulateData(
    model = formula, model.type = "sem", int.ov.free = TRUE,
    auto.var = TRUE, auto.cov.y = TRUE, sample.nobs = 2000L,
    skewness = skewness,
    kurtosis = kurtosis
  )

  return(fake_data)
}


#' Generate histograms for each variable in simulated dataset
#' @export
hist_sim <- function(d) {
  d |>
    tidyr::pivot_longer(colnames(d)) |>
    ggplot(aes(x = value)) +
      geom_histogram() +
      facet_wrap(~ name, scales = "free")
}
