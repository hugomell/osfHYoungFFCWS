FROM docker.io/rocker/rstudio:4.4.1 AS base

# {renv} - restore project library
RUN mkdir -p renv
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R

## install renv
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@v1.0.7')"

## restore project library
ENV RENV_PATHS_LIBRARY "${PWD}"/renv/library
RUN R -e "renv::restore()"

# stan - install cmdstan using {cmdstanr}
COPY container-scripts/ /container-scripts
RUN /container-scripts/install_stan.sh

# install project package
RUN R -e "renv::install('devtools')"
RUN R -e "devtools::install_github('hugomell/osfHYoungFFCWS', dependencies = FALSE)"
