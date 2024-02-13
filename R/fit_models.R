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
        std_bf + internalizing_bf + externalizing_bf +
        brms::set_rescor(FALSE),
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
        dplyr::filter(!(parameter %in% c("std_Intercept",
            "repro_Intercept", "internalizing_Intercept",
            "externalizing_Intercept"))
        ) |>
        dplyr::select(1:2) |>
        dplyr::mutate(brms = params)
}
