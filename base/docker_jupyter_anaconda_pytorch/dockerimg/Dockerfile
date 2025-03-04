#############################
# JUPYTER VOLUME DOCKERFILE #
#***************************#
# Enables:                  #
# Jupyter Lab               #
# Anaconda                  #
#############################
ARG docker_path=./dockerimg/

##############
# Base image #
##############
##--- Setup Ubuntu
ARG CUDA_VERSION=12.2.0-devel-ubuntu20.04
#ARG CUDA_VERSION=12.2.0-runtime-ubuntu20.04
#ARG CUDA_VERSION=12.2.0-base-ubuntu20.04
FROM nvidia/cuda:${CUDA_VERSION}

#--- Tags
LABEL maintainer="misantamaria <mi.santamaria@upm.es>"
LABEL cuda_version=${CUDA_VERSION}
##---Initialize bash
SHELL [ "/bin/bash", "--login", "-c" ]

##################
# Packages setup #
##################
RUN apt-get update --fix-missing \
    && apt-get install -y wget bzip2 curl git sudo \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/*


##################################
# Get user environment variables #
##################################
ARG USER
ARG UID
ARG GID

########################
# Create non-root user # #Neccesary for jupyter
########################
ARG username=user
ARG uid=1000
ARG gid=1000
ENV USER=$username \
    UID=$uid \
    GID=$gid 
ENV HOME=/home/$USER
#-- Passwordless sudo (TODO: mv to root section)
RUN addgroup --gid $GID $USER  \
    && adduser --disabled-password \
    --gecos "Non-root user" \
    --uid $UID \
    --gid $GID \
    --home $HOME $USER\
    && echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
#-- Move to user
USER $USER

# Add the jupyterlab settings
COPY --chown=$UID:$GID ${docker_path}jupyter_config $HOME/.jupyter

#####################
# Install miniconda #
#####################

ENV MINICONDA_VERSION=4.10.3 \ 
    CONDA_DIR=$HOME/miniconda3 \
    # Make non-activate conda commands available
    PATH=$CONDA_DIR/bin:$PATH \
    PROJECT_DIR=$HOME 
RUN echo "HOME: ${HOME} | CONDA_DIR = ${CONDA_DIR}" 
#-- Install MINICONDA
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py38_$MINICONDA_VERSION-Linux-x86_64.sh -O ~/miniconda.sh && \
    chmod +x ~/miniconda.sh && \
    ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh

    # Make conda activate command available from /bin/bash --login shells
RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ~/.profile 
    # make conda activate command available from /bin/bash --interative shells
RUN conda init bash\
    # create a project directory inside user home
    && mkdir -p $PROJECT_DIR
    
WORKDIR $PROJECT_DIR
##########################
# Install & update MAMBA #
########################## 
ENV ENV_PREFIX $PROJECT_DIR/env

RUN conda install --name base --channel conda-forge mamba \
    #sudo apt-get update -y
    && mamba update --name base --channel defaults conda 
#-- Build the mamba environment
COPY --chown=$UID:$GID ${docker_path}environment.yml ${docker_path}requirements.txt /tmp/
RUN mamba env create --prefix $ENV_PREFIX --file /tmp/environment.yml --force  \ 
    && conda clean --all --yes

###########################
# Editable packages (pip) #
########################### 
#RUN mkdir /home/$USER/lib \
#    && conda activate $ENV_PREFIX \
#    && cd /home/$USER/lib \
    # Install tsai (v0.3.5)
#    && rm -rf tsai \
#    && git clone -b 0.3.5 --single-branch https://github.com/timeseriesAI/tsai.git \
#    && cd tsai \ 
#    && pip install --no-deps -e . \
#    && conda deactivate

################
# Final Setups #
################

# run the postBuild script to install the JupyterLab extensions
COPY --chown=$UID:$GID ${docker_path}postBuild /usr/local/bin
RUN chmod u+x /usr/local/bin/postBuild \
    && conda activate $ENV_PREFIX  \
    && /usr/local/bin/postBuild  \
    && conda deactivate \
    # Make bash automatically activate the conda environment
    && echo "conda activate $ENV_PREFIX" >> ~/.bashrc

COPY --chown=$UID:$GID ${docker_path}entrypoint.sh /usr/local/bin
RUN chmod u+x /usr/local/bin/entrypoint.sh

# Enable entrypoint
run id -u
RUN chmod 777 $ENV_PREFIX/include
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

# Open Jupyter lab!
CMD [ "jupyter", "lab", "--no-browser", "--ip", "0.0.0.0", "--ContentsManager.allow_hidden=True"]
