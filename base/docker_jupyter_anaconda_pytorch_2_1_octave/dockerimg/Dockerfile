#############################
# JUPYTER VOLUME DOCKERFILE #
#***************************#
# Enables:                  #
# Jupyter Lab               #
# Anaconda                  #
# Octave                    #
#############################
ARG docker_path=./dockerimg/

##############
# Base image #
##############
##--- Setup Ubuntu
ARG CUDA_VERSION=12.2.0-devel-ubuntu20.04

FROM nvidia/cuda:${CUDA_VERSION}

#--- Tags
LABEL maintainer="misantamaria <mi.santamaria@upm.es>"
LABEL cuda_version=${CUDA_VERSION}
##---Initialize bash
SHELL [ "/bin/bash", "--login", "-c" ]

##################
# Packages setup #
##################

ARG TZ=Etc/UTC 
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update --fix-missing \
    && apt-get install -y wget bzip2 curl git sudo libarchive-dev libtiff5-dev libgl1-mesa-glx \
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
    GID=$gid \
    HOME=/home/$USER
#-- Passwordless sudo (TODO: mv to root section)
RUN addgroup --gid $GID $USER  \
    && adduser --disabled-password \
    --gecos "Non-root user" \
    --uid $UID \
    --gid $GID \
    --home $HOME $USER\
    && echo "$USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Add the jupyterlab settings
COPY --chown=$UID:$GID ${docker_path}jupyter_config $HOME/.jupyter

#####################
# Install miniconda #
#####################

ENV MINICONDA_VERSION=4.10.3 \ 
    CONDA_DIR=/usr/local/share/miniconda3 
    # Make non-activate conda commands available
ENV PATH=$CONDA_DIR/bin:$PATH \
    ENV_PREFIX=${CONDA_DIR}/envs/env \
    PROJECT_DIR=$HOME 

RUN echo "HOME: ${HOME} | CONDA_DIR = ${CONDA_DIR}" \
    #-- Install MINICONDA
    && wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py38_$MINICONDA_VERSION-Linux-x86_64.sh -O  /usr/local/share/miniconda.sh  \
    && chmod +x  /usr/local/share/miniconda.sh  \
    && /usr/local/share/miniconda.sh -b -p $CONDA_DIR  \
    && rm /usr/local/share/miniconda.sh \
    # Make conda activate command available from /bin/bash --login shells
    && echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> /usr/local/share/.profile 
    # make conda activate command available from /bin/bash --interative shells
RUN conda init bash \
    # create a project directory inside user home
    && mkdir -p $PROJECT_DIR
    
WORKDIR /usr/local/share
##########################
# Install & update MAMBA #
########################## 

COPY --chown=$UID:$GID ${docker_path}environment.yml ${docker_path}requirements.txt /tmp/

RUN conda install --name base --channel conda-forge mamba \
    && mamba update --name base --channel defaults conda \
    && mamba env create --prefix ${ENV_PREFIX} --file /tmp/environment.yml \
    && conda clean --all --yes

################
# Final Setups #
################

COPY --chown=$UID:$GID ${docker_path}entrypoint.sh /usr/local/bin

# Enable entrypoint
RUN chmod u+x /usr/local/bin/entrypoint.sh \
    && id -u \
    && chmod 777 $ENV_PREFIX/include

#-- Move to user
USER $USER

WORKDIR $PROJECT_DIR

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
# Open Jupyter lab!
CMD [ "jupyter", "lab", "--no-browser", "--ip", "0.0.0.0", "--ContentsManager.allow_hidden=True"]
