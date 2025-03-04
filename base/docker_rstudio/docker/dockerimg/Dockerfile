#FROM vrodriguezf/rstudio-server-shiny-development
# Adds rstudio server, tiyverse, devtools to rocker/cuda
FROM rocker/ml:4.2

SHELL [ "/bin/bash", "--login", "-c" ]

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A4B469963BF863CC 
RUN apt-get update
RUN apt-get install -y python3-pip
RUN python3 -m pip install --upgrade pip
RUN apt-get install -y python3-venv libxt-dev

## Install R packages

RUN R -e "install.packages(c('shiny', 'pals', 'shinyWidgets', 'dygraphs', 'shinycssloaders', 'shinyjs', 'Rcpp'))"
RUN R -e "remotes::install_github('r-lib/later')"

## Install reticulate and create virtual environment using default Ubuntu installed Python
RUN R -e "install.packages('reticulate')"

ARG USER=user
ARG UID=1000
ARG GID=1000
ENV HOME /home/$USER
ENV ENV_PREFIX $HOME/env

RUN addgroup --gid $GID $USER
RUN adduser --disabled-password \
    --gecos "Non-root user" \
    --uid $UID \
    --gid $GID \
    --home $HOME \
    $USER

ARG RETICULATE_MINICONDA_PATH=/usr/local/share/r-miniconda
ARG RETICULATE_PYTHON_ENV=/usr/virtualenvs/venv_shiny_app
ENV RETICULATE_PYTHON=${RETICULATE_PYTHON_ENV}/bin/python/

RUN echo "RETICULATE_PYTHON_ENV=${RETICULATE_PYTHON_ENV}" >> ${HOME}/.Renviron
RUN echo "RETICULATE_PYTHON=${RETICULATE_PYTHON}" >> ${HOME}/.Renviron


RUN echo "CHOWN"
COPY --chown=${UID}:${GID} docker/entrypoint-rstudio.sh /usr/local/bin
RUN chmod u+x /usr/local/bin/entrypoint-rstudio.sh
ENTRYPOINT [ "/usr/local/bin/entrypoint-rstudio.sh" ]

# Rewrite the miniconda path environment in case it has been redefined in the compose file
RUN echo "RETICULATE_MINICONDA_PATH=${RETICULATE_MINICONDA_PATH}" >> ${HOME}/.Renviron

# make non-activate conda commands available
ENV PATH=${RETICULATE_MINICONDA_PATH}/bin:${PATH}