#' Fit a given model on simulated data with brms
#' @export
brms_fit <- function(d, model_type) {
  if (model_type == "baseline") {
    fit <- fit_baseline(d)
  } else if (model_type == "mediation") {
    fit <- fit_mediation(d)
  } else {
    fit <- fit_moderation(d)
  }

  return(fit)
}


#' Fit a baseline model with brms
fit_baseline <- function(d) {
  std_bf <- brms::bf(std ~ 1 + SES + threat + deprivation + stochasticity
                     + volatility)
  internalizing_bf <- brms::bf(internalizing ~ 1 + std + SES + threat
                               + deprivation + stochasticity + volatility)
  externalizing_bf <- brms::bf(externalizing ~ 1 + std + SES + threat
                               + deprivation + stochasticity + volatility)

  out <- brms::brm(data = d, family = gaussian, std_bf + internalizing_bf
                   + externalizing_bf + brms::set_rescor(FALSE), cores = 4,
                   control = list(max_treedepth = 10))

  return(out)
}


#' Fit a mediation model with brms
fit_mediation <- function(d) {
  std_bf <- brms::bf(std ~ 1 + SES + threat + deprivation + stochasticity
                     + volatility)
  repro_bf <- brms::bf(repro ~ 1 + std + SES + threat + deprivation
                       + stochasticity + volatility)
  withdrawal_bf  <- brms::bf(withdrawal ~ 1 + std + SES + threat + deprivation
                             + stochasticity + volatility)
  internalizing_bf <- brms::bf(internalizing ~ 1 + std + repro + withdrawal
                               + SES + threat + deprivation + stochasticity
                               + volatility)
  externalizing_bf <- brms::bf(externalizing ~ 1 + std + repro + withdrawal
                               + SES + threat + deprivation + stochasticity
                               + volatility)

  out <- brms::brm(data = d, family = gaussian, std_bf + repro_bf
                   + withdrawal_bf + internalizing_bf + externalizing_bf
                   + brms::set_rescor(FALSE), cores = 4,
                   control = list(max_treedepth = 10))

  return(out)
}


#' Fit a moderation model with brms
fit_moderation <- function(d) {
  std_bf <- brms::bf(std ~ 1 + SES + threat + deprivation + stochasticity
                     + volatility)
  repro_bf <- brms::bf(repro ~ 1 + SES + threat + deprivation + stochasticity
                       + volatility)
  withdrawal_bf <- brms::bf(withdrawal ~ 1 + SES + threat + deprivation
                            + stochasticity + volatility)
  internalizing_bf <- brms::bf(internalizing ~ 1 + std + repro + prod_std_repro
                               + withdrawal + prod_std_withdrawal
                               + SES + threat + deprivation
                               + stochasticity + volatility)
  externalizing_bf <- brms::bf(externalizing ~ 1 + std + repro + prod_std_repro
                               + withdrawal + prod_std_withdrawal
                               + SES + threat + deprivation
                               + stochasticity + volatility)

  out <- brms::brm(data = d, family = gaussian, std_bf + repro_bf
                   + withdrawal_bf + internalizing_bf + externalizing_bf
                   + brms::set_rescor(FALSE), cores = 4,
                   control = list(max_treedepth = 10))

  return(out)
}


#' Check parameter recovery
#' @export
check_params_recovery <- function(m, model_type) {
  params <- get_params_simu(model_type)

  coeffs <- tibble::as_tibble(brms::fixef(m), rownames = "parameter")
  coeffs |>
    filter(!(parameter %in% c("std_Intercept", "repro_Intercept",
                              "withdrawal_Intercept",
                              "internalizing_Intercept",
                              "externalizing_Intercept"))) |>
    select(1:2) |>
    mutate(simu = params) |>
    mutate(across(where(is.numeric), \(x) round(x, digits = 3))) |>
    mutate(across(parameter, \(x) stringr::str_replace(x, "_", " ~ ")))
}


#' Return a label for a given parameter
get_target_label <- function(param) {

  lookup <- c(
    "b_std_SES" = "std ~ SES",
    "b_std_threat" = "std ~ threat",
    "b_std_deprivation" = "std ~ deprivation",
    "b_std_volatility" = "std ~ volatility",
    "b_std_stochasticity" = "std ~ stochasticity",
    "b_repro_std" = "reproduction ~ std",
    "b_repro_SES" = "reproduction ~ SES",
    "b_repro_threat" = "reproduction ~ threat",
    "b_repro_deprivation" = "reproduction ~ deprivation",
    "b_repro_volatility" = "reproduction ~ volatility",
    "b_repro_stochasticity" = "reproduction ~ stochasticity",
    "b_withdrawal_std" = "withdrawal ~ std",
    "b_withdrawal_SES" = "withdrawal ~ SES",
    "b_withdrawal_threat" = "withdrawal ~ threat",
    "b_withdrawal_deprivation" = "withdrawal ~ deprivation",
    "b_withdrawal_volatility" = "withdrawal ~ volatility",
    "b_withdrawal_stochasticity" = "withdrawal ~ stochasticity",
    "b_internalizing_std" = "internalizing ~ std",
    "b_internalizing_repro" = "internalizing ~ reproduction",
    "b_internalizing_withdrawal" = "internalizing ~ withdrawal",
    "b_internalizing_SES" = "internalizing ~ SES",
    "b_internalizing_threat" = "internalizing ~ threat",
    "b_internalizing_deprivation" = "internalizing ~ deprivation",
    "b_internalizing_volatility" = "internalizing ~ volatility",
    "b_internalizing_stochasticity" = "internalizing ~ stochasticity",
    "b_internalizing_prod_std_repro" = "internalizing ~ std*reproduction",
    "b_internalizing_prod_std_withdrawal" = "internalizing ~ std*withdrawal",
    "b_externalizing_std" = "externalizing ~ std",
    "b_externalizing_repro" = "externalizing ~ reproduction",
    "b_externalizing_withdrawal" = "externalizing ~ withdrawal",
    "b_externalizing_SES" = "externalizing ~ SES",
    "b_externalizing_threat" = "externalizing ~ threat",
    "b_externalizing_deprivation" = "externalizing ~ deprivation",
    "b_externalizing_volatility" = "externalizing ~ volatility",
    "b_externalizing_stochasticity" = "externalizing ~ stochasticity",
    "b_externalizing_prod_std_repro" = "externalizing ~ std*reproduction",
    "b_externalizing_prod_std_withdrawal" = "externalizing ~ std*withdrawal"
  )

  return(lookup[param])

}

#' Return a simulation coefficient for a given parameter
get_target_coeff <- function(param, model_type) {

  lookup <- c(
    "b_std_SES" =
      get_params_simu(model_type)[["std ~ SES"]],
    "b_std_threat" =
      get_params_simu(model_type)[["std ~ threat"]],
    "b_std_deprivation" =
      get_params_simu(model_type)[["std ~ deprivation"]],
    "b_std_volatility" =
      get_params_simu(model_type)[["std ~ volatility"]],
    "b_std_stochasticity" =
      get_params_simu(model_type)[["std ~ stochasticity"]],
    "b_repro_std" =
      ifelse(model_type == "mediation",
             get_params_simu(model_type)[["repro ~ std"]],
             NA),
    "b_repro_SES" =
      ifelse(model_type != "baseline",
             get_params_simu(model_type)[["repro ~ SES"]],
             NA),
    "b_repro_threat" =
      ifelse(model_type != "baseline",
             get_params_simu(model_type)[["repro ~ threat"]],
             NA),
    "b_repro_deprivation" =
      ifelse(model_type != "baseline",
             get_params_simu(model_type)[["repro ~ deprivation"]],
             NA),
    "b_repro_volatility" =
      ifelse(model_type != "baseline",
             get_params_simu(model_type)[["repro ~ volatility"]],
             NA),
    "b_repro_stochasticity" =
      ifelse(model_type != "baseline",
             get_params_simu(model_type)[["repro ~ stochasticity"]],
             NA),
    "b_withdrawal_std" =
      ifelse(model_type == "mediation",
             get_params_simu(model_type)[["withdrawal ~ std"]],
             NA),
    "b_withdrawal_SES" =
      ifelse(model_type != "baseline",
             get_params_simu(model_type)[["withdrawal ~ SES"]],
             NA),
    "b_withdrawal_threat" =
      ifelse(model_type != "baseline",
             get_params_simu(model_type)[["withdrawal ~ threat"]],
             NA),
    "b_withdrawal_deprivation" =
      ifelse(model_type != "baseline",
             get_params_simu(model_type)[["withdrawal ~ deprivation"]],
             NA),
    "b_withdrawal_volatility" =
      ifelse(model_type != "baseline",
             get_params_simu(model_type)[["withdrawal ~ volatility"]],
             NA),
    "b_withdrawal_stochasticity" =
      ifelse(model_type != "baseline",
             get_params_simu(model_type)[["withdrawal ~ stochasticity"]],
             NA),
    "b_internalizing_std" =
      get_params_simu(model_type)[["internalizing ~ std"]],
    "b_internalizing_repro" =
      ifelse(model_type != "baseline",
             get_params_simu(model_type)[["internalizing ~ repro"]],
             NA),
    "b_internalizing_withdrawal" =
      ifelse(model_type != "baseline",
             get_params_simu(model_type)[["internalizing ~ withdrawal"]],
             NA),
    "b_internalizing_SES" =
      get_params_simu(model_type)[["internalizing ~ SES"]],
    "b_internalizing_threat" =
      get_params_simu(model_type)[["internalizing ~ threat"]],
    "b_internalizing_deprivation" =
      get_params_simu(model_type)[["internalizing ~ deprivation"]],
    "b_internalizing_volatility" =
      get_params_simu(model_type)[["internalizing ~ volatility"]],
    "b_internalizing_stochasticity" =
      get_params_simu(model_type)[["internalizing ~ stochasticity"]],
    "b_internalizing_prod_std_repro" =
      ifelse(model_type == "moderation",
             get_params_simu(model_type)[["internalizing ~ prod_std_repro"]],
             NA),
    "b_internalizing_prod_std_withdrawal" =
      ifelse(model_type == "moderation",
             get_params_simu(model_type)[["internalizing ~ prod_std_withdrawal"]],
             NA),
    "b_externalizing_std" =
      get_params_simu(model_type)[["externalizing ~ std"]],
    "b_externalizing_repro" =
      ifelse(model_type != "baseline",
             get_params_simu(model_type)[["externalizing ~ repro"]],
             NA),
    "b_externalizing_withdrawal" =
      ifelse(model_type != "baseline",
             get_params_simu(model_type)[["externalizing ~ withdrawal"]],
             NA),
    "b_externalizing_SES" =
      get_params_simu(model_type)[["externalizing ~ SES"]],
    "b_externalizing_threat" =
      get_params_simu(model_type)[["externalizing ~ threat"]],
    "b_externalizing_deprivation" =
      get_params_simu(model_type)[["externalizing ~ deprivation"]],
    "b_externalizing_volatility" =
      get_params_simu(model_type)[["externalizing ~ volatility"]],
    "b_externalizing_stochasticity" =
      get_params_simu(model_type)[["externalizing ~ stochasticity"]],
    "b_externalizing_prod_std_repro" =
      ifelse(model_type == "moderation",
             get_params_simu(model_type)[["externalizing ~ prod_std_repro"]],
             NA),
    "b_externalizing_prod_std_withdrawal" =
      ifelse(model_type == "moderation",
             get_params_simu(model_type)[["externalizing ~ prod_std_withdrawal"]],
             NA)
  )

  return(lookup[param])

}




#' Plot posterior distributions
#' @export
plot_posteriors <- function(m, y, model_type, plot_title, ncol = 3) {

  colors <- list(std = "#1B9E77", repro = "#D95F02",
                 internalizing = "#7570B3", externalizing = "#66A61E")
  ## Colors taken from {RColorBrewer}:
  ## RColorBrewer::display.brewer.pal(n = 8, name = 'Dark2')
  ## RColorBrewer::brewer.pal(n = 8, name = 'Dark2')

  # get draws from model posterior distribution
  draws <- brms::as_draws_df(m)

  draws |>
    select(starts_with("b_") & !ends_with("_Intercept")) |>
    tidyr::pivot_longer(cols = everything()) |>
    filter(stringr::str_detect(name, glue::glue("b_{y}_.*"))) |>
    mutate(name_labels = get_target_label(name)) |>
    mutate(target_coeff = get_target_coeff(name, model_type)) |>
    ggplot(aes(x = value)) +
    tidybayes::stat_halfeye(point_interval = tidybayes::mode_hdi,
                            .width = c(.95, .5), slab_fill = colors[[y]],
                            slab_color = "black", slab_linewidth = 0.6) +
    geom_vline(aes(xintercept = target_coeff), linewidth = 1.4, alpha = 0.7) +
    scale_y_continuous(NULL, breaks = NULL) +
    theme_ggdist() +
    facet_wrap(~ name_labels, scales = "free", ncol = ncol) +
    xlab(expression(beta ~ "coefficient")) +
    ggtitle(plot_title, subtitle = paste("Density, mean values (dots),",
                                         "66% and 95% intervals and ",
                                         "simulation values (vertical lines).")
    )
}
