ARG target

FROM docker.io/rocker/rstudio:4.4.1 AS base

WORKDIR /home/root/project

# {renv} - restore project library
RUN mkdir -p renv
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R

## install renv
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@v1.0.7')"

## restore project library
ENV RENV_PATHS_LIBRARY /home/root/renv/library
RUN R -e "renv::restore()"

# stan - install cmdstan using {cmdstanr}
COPY container-scripts/ /container-scripts
RUN /container-scripts/install_stan.sh

# install project package
RUN R -e "renv::install('devtools')"
RUN echo "-ANCHOR-"
RUN R -e "devtools::install_github('hugomell/osfHYoungFFCWS', dependencies = FALSE)"

# copy package files to project library
RUN R -e "renv::isolate()"

# Multi-stage builds for different RStudio server configurations
FROM base AS target-local
RUN echo 'session-default-working-dir=/home/root/project' >> \
      /etc/rstudio/rsession.conf && \
    echo 'session-default-new-project-dir=/home/root/project' >> \
      /etc/rstudio/rsession.conf

FROM base AS target-gitpod
RUN echo "RENV_PATHS_LIBRARY=/home/root/renv/library" >> /usr/local/lib/R/etc/Renviron
RUN echo 'session-default-working-dir=/workspace/osfHYoungFFCWS' >> \
      /etc/rstudio/rsession.conf && \
    echo 'session-default-new-project-dir=/workspace/osfHYoungFFCWS' >> \
      /etc/rstudio/rsession.conf
RUN echo 'auth-none=1' >> \
      /etc/rstudio/rserver.conf && \
    echo 'auth-validate-users=0' >> \
      /etc/rstudio/rsession.conf

FROM target-${target} AS final
ARG target
RUN echo Successfully built $target image!
