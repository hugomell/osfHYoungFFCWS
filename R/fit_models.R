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
    std_bf <- brms::bf(std ~ 1 + SES + threat + deprivation)
    internalizing_bf <- brms::bf(internalizing ~ 1 + std + SES + threat
                                 + deprivation)
    externalizing_bf <- brms::bf(externalizing ~ 1 + std + SES + threat
                                 + deprivation)

    out <- brms::brm(
        data = d, family = gaussian,
        std_bf + internalizing_bf + externalizing_bf + brms::set_rescor(FALSE),
        cores = 4, control = list(max_treedepth = 10))

    return(out)
}


#' Fit a mediation model with brms
fit_mediation <- function(d) {
    std_bf <- brms::bf(std ~ 1 + SES + threat + deprivation)
    repro_bf <- brms::bf(repro ~ 1 + std + SES + threat + deprivation)
    internalizing_bf <- brms::bf(internalizing ~ 1 + std + repro + SES
                                 + threat + deprivation)
    externalizing_bf <- brms::bf(externalizing ~ 1 + std + repro + SES
                                 + threat + deprivation)

    out <- brms::brm(
        data = d, family = gaussian,
        std_bf + repro_bf + internalizing_bf + externalizing_bf +
        brms::set_rescor(FALSE),
        cores = 4, control = list(max_treedepth = 10))

    return(out)
}


#' Fit a moderation model with brms
fit_moderation <- function(d) {
    std_bf <- brms::bf(std ~ 1 + SES + threat + deprivation)
    repro_bf <- brms::bf(repro ~ 1 + SES + threat + deprivation)
    internalizing_bf <- brms::bf(internalizing ~ 1 + std + repro
                                 + prod_std_repro + SES + threat + deprivation)
    externalizing_bf <- brms::bf(externalizing ~ 1 + std + repro
                                 + prod_std_repro + SES + threat + deprivation)

    out <- brms::brm(
        data = d, family = gaussian,
        std_bf + repro_bf + internalizing_bf + externalizing_bf +
        brms::set_rescor(FALSE),
        cores = 4, control = list(max_treedepth = 10))

    return(out)
}


#' Check parameter recovery
#' @export
check_params_recovery <- function(m, model_type) {
    params <- get_params_simu(model_type)

    coeffs <- tibble::as_tibble(brms::fixef(m), rownames = "parameter")
    coeffs |>
        filter(!(parameter %in% c("std_Intercept", "repro_Intercept",
            "internalizing_Intercept", "externalizing_Intercept"))) |>
        select(1:2) |>
        mutate(brms = params)
}


#' Return a label for a given parameter
get_target_label <- function(param) {

    lookup <- c(
        "b_std_SES" = "short-term deliberation ~ SES",
        "b_std_threat" = "short-term deliberation ~ threat",
        "b_std_deprivation" = "short-term deliberation ~ deprivation",
        "b_repro_std" = "reproduction ~ short-term deliberation",
        "b_repro_SES" = "reproduction ~ SES",
        "b_repro_threat" = "reproduction ~ threat",
        "b_repro_deprivation" = "reproduction ~ deprivation",
        "b_internalizing_std" = "internalizing ~ short-term deliberation",
        "b_internalizing_repro" = "internalizing ~ reproduction",
        "b_internalizing_SES" = "internalizing ~ SES",
        "b_internalizing_threat" = "internalizing ~ threat",
        "b_internalizing_deprivation" = "internalizing ~ deprivation",
        "b_internalizing_prod_std_repro" = "internalizing ~ interaction short-term deliberation reproduction",
        "b_externalizing_std" = "externalizing ~ short-term deliberation",
        "b_externalizing_repro" = "externalizing ~ reproduction",
        "b_externalizing_SES" = "externalizing ~ SES",
        "b_externalizing_threat" = "externalizing ~ threat",
        "b_externalizing_deprivation" = "externalizing ~ deprivation",
        "b_externalizing_prod_std_repro" = "externalizing ~ interaction short-term deliberation reproduction"
    )

    return(lookup[param])
    
}

#' Return a simulation coefficient for a given parameter
get_target_coeff <- function(param, model_type) {

    lookup <- c(
        "b_std_SES" = get_params_simu(model_type)[["std ~ SES"]],
        "b_std_threat" = get_params_simu(model_type)[["std ~ threat"]],
        "b_std_deprivation" = get_params_simu(model_type)[["std ~ deprivation"]],
        "b_repro_std" = ifelse(
            model_type == "mediation",
            get_params_simu(model_type)[["repro ~ std"]], NA),
        "b_repro_SES" = ifelse(
            model_type != "baseline",
            get_params_simu(model_type)[["repro ~ SES"]], NA),
        "b_repro_threat" = ifelse(
            model_type != "baseline",
            get_params_simu(model_type)[["repro ~ threat"]], NA),
        "b_repro_deprivation" = ifelse(
            model_type != "baseline",
            get_params_simu(model_type)[["repro ~ deprivation"]], NA),
        "b_internalizing_std" = get_params_simu(model_type)[["internalizing ~ std"]],
        "b_internalizing_repro" = ifelse(
            model_type != "baseline",
            get_params_simu(model_type)[["internalizing ~ repro"]], NA),
        "b_internalizing_SES" = get_params_simu(model_type)[["internalizing ~ SES"]],
        "b_internalizing_threat" = get_params_simu(model_type)[["internalizing ~ threat"]],
        "b_internalizing_deprivation" = get_params_simu(model_type)[["internalizing ~ deprivation"]],
        "b_internalizing_prod_std_repro" = ifelse(
            model_type == "moderation",
            get_params_simu(model_type)[["internalizing ~ prod_std_repro"]], NA),
        "b_externalizing_std" = get_params_simu(model_type)[["externalizing ~ std"]],
        "b_externalizing_repro" = ifelse(
            model_type != "baseline",
            get_params_simu(model_type)[["externalizing ~ repro"]], NA),
        "b_externalizing_SES" = get_params_simu(model_type)[["externalizing ~ SES"]],
        "b_externalizing_threat" = get_params_simu(model_type)[["externalizing ~ threat"]],
        "b_externalizing_deprivation" = get_params_simu(model_type)[["externalizing ~ deprivation"]],
        "b_externalizing_prod_std_repro" = ifelse(
            model_type == "moderation",
            get_params_simu(model_type)[["externalizing ~ prod_std_repro"]], NA)
    )

    return(lookup[param])
    
}




#' Plot posterior distributions
#' @export
plot_posteriors <- function(m, y, model_type) {

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
        geom_vline(aes(xintercept = target_coeff)) +
        scale_y_continuous(NULL, breaks = NULL) +
        theme_ggdist() +
        facet_wrap(~ name_labels, scales = "free")
}
