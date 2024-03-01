

# Code and dependencies to run the demonstration pipeline


This repository is a companion to an [OSF pre-registration](XXX). It is
organized as an R package and can be installed with:

```r
remotes::install_github(hugomell/osfHYoungFFCWS)
```

It provides R code and instructions to run a demonstration pipeline that (i)
simulates fake datasets based on the equations described for the three main
models in the pre-registration, (ii) attempts to recover the structural
parameters used for the simulation by estimating path models with `{brms}`.
Tables and plots obtained after running the demonstration pipeline can be
found
[here](https://hugomell.github.io/osf-heloise-young-fragile-family/articles/Data-simulation-and-parameter-recovery-with-brms.html).

To ensure that the analysis pipeline is ***reproducible***, we detail in
the next sections how to: (i) set up the computing environment with all the
required dependencies, and (ii) run the demonstration pipeline.




## Setting up the computing environment


Two strategies are proposed to get all required dependencies up and running
on a new machine. The first strategy uses a container image to generate on
demand *virtualized* computing environments isolated from the rest of
the host machine and with all the tools necessary to run the pipeline
pre-installed. The second strategy uses [`{renv}`](https://rstudio.github.io/renv/articles/renv.html) to create a project
local library with the appropriate versions of the R dependencies.

The second strategy is less reproducible since the R installation and the
system dependencies will need to be managed by the user. For instance, the
installation of the `Stan` probabilistic programming language used by `{brms}`
to fit path models using bayesian estimation procedures is not recorded by
`{renv}` and will need to be performed in a separate step. Nevertheless, it
has the advantage that it does not require the installation and use of
specialized software for launching and managing containers, which might not be
familiar to certain R users.

### Using the container image

First, you will need a machine with [Podman](https://podman.io/) installed
([Docker](https://www.docker.com/) might also work but has not been properly
tested). Instructions for the installation of Podman on various platforms can
be found in their official
[documentation](https://podman.io/docs/installation).

In a terminal, you can then execute the following podman command which will
*pull* the container image on your local machine:

```bash
podman pull docker.io/ipea7892/osf-hyoung-ffcws-dev:latest 
```

Once the image has been downloaded, to launch a container:

1. Open a terminal in your project directory

2. Copy/paste the following command in the terminal:

```bash
podman run --rm -it -p -e DISABLE_AUTH=true -p 127.0.0.1:8787:8787 \
       -v "$(pwd)":/home/root/project "osf-hyoung-ffcws-dev:latest"
```
  
   This will create a container based on the container image you just pulled
   and will automatically start an RStudio server session from within the
   container.

3. Open a web browser and type `localhost:8787` in your address bar.
  
   Now you will be connected to the RStudio session that is running from the
   container. You will have access to the files in your project directory and
   to all the packages used by the demonstration pipeline.

To stop the container press `Ctrl-c` in the terminal to close the RStudio
session and type `exit` to leave and destroy the running container.

### Using `{renv}`

### Restoring R dependencies

First, you need to copy the `renv.lock` located at the root of the github
[repository](https://github.com/hugomell/osf-heloise-young-fragile-family) to
your project folder.
This is the file used by `{renv}` to record the exact versions of the R
dependencies that need to be present to execute the code for the project.

Then, to restore the computing environment run `renv::init()` and select the
`Restore the project from the lockfile` option. This will install all the
necessary R packages in a new `renv/` folder at the root of your project.




## Running the demonstration pipeline


The analysis pipeline is managed using the R package `{targets}`.

To execute the pipeline on your machine, you first need to run
`osfHYoungFFCWS::get_targets_files()` from an R environnement with our package
installed. This will copy two files to the root of your working directory:
`_targets.R` and `Data-simulation-and-parameter-recovery-with-brms.Rmd`.
The former defines all the steps of our pipeline and the later is an R
Markdown file used to generate an HTML report with tables and plots.

Then, simply execute `targets::tar_make()` which will run the pipeline. This
command will create at the root of the working directory a `_targets/` folder
used internally by `{targets}` to store the results of the computations. A
`Data-simulation-and-parameter-recovery-with-brms.hmtl` should also have been
generated automatically from the R Markdown file. The same report is available
as a `{pkgdown}`
[article](https://hugomell.github.io/osf-heloise-young-fragile-family/articles/Data-simulation-and-parameter-recovery-with-brms.html).


See the [Getting started](https://hugomell.github.io/osf-heloise-young-fragile-family/articles/osfHYoungFFCWS.html)
as well as the [Reference](https://hugomell.github.io/osf-heloise-young-fragile-family/reference/index.html) sections for more information on the functions
used in the pipeline and ways to modify the default values for the
simulation parameters and the models' priors.

To learn more about managing R pipelines with `{targets}`, you can refer to
the package's [User Guide](https://books.ropensci.org/targets/).
