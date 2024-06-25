# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(packages = "osfHYoungFFCWS")

# Replace the target list below with your own:
list(
  tar_target(
    name = sim_data_baseline,
    command = simulate_dataset(model_type = "baseline")
  ),
  tar_target(
    name = sim_data_mediation,
    command = simulate_dataset(model_type = "mediation")
  ),
  tar_target(
    name = sim_data_moderation,
    command = simulate_dataset(model_type = "moderation")
  ),
  tar_target(
    name = fit_baseline,
    command = brms_fit(sim_data_baseline, model_type = "baseline")
  ),
  tar_target(
    name = fit_mediation,
    command = brms_fit(sim_data_mediation, model_type = "mediation")
  ),
  tar_target(
    name = fit_moderation,
    command = brms_fit(sim_data_moderation, model_type = "moderation")
  ),
  # Generate Rmd report
  tar_render(
    report,
    path = "Data-simulation-and-parameter-recovery-with-brms.Rmd"
  )
)
