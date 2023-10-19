#############################
# JUPYTER VOLUME DOCKERFILE #
#***************************#
# Enables:                  #
# Jupyter Lab               #
#############################
ARG docker_path=./dockerimg/

##############
# Base image #
##############
ARG CUDA_VERSION=12.2.0-devel-ubuntu20.04
#ARG CUDA_VERSION=12.2.0-runtime-ubuntu20.04
#ARG CUDA_VERSION=12.2.0-base-ubuntu20.04
FROM nvidia/cuda:$CUDA_VERSION

#--- Tags
LABEL maintainer="misantamaria <mi.santamaria@upm.es>"
LABEL cuda_version=${CUDA_VERSION}
##---Initialize bash
SHELL [ "/bin/bash", "--login", "-c" ]

########################
# Create non-root user #
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
COPY --chown=$uid:$gid ${docker_path}jupyter_config $HOME/.jupyter

##################
# Instal python3 #
##################
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN pip3 install jupyter
RUN pip3 install jupyterlab

RUN addgroup --gid $GID $USER
RUN adduser --disabled-password --gecos '' --uid $UID --gid $GID $USER

COPY requirements.txt /home/$USER
RUN pip3 install -r requirements.txt

################
# Final setups #
################
USER $USER
WORKDIR /home/$USER

# run the postBuild script to install the JupyterLab extensions
COPY --chown=$UID:$GID ${docker_path}postBuild /usr/local/bin
RUN chmod u+x /usr/local/bin/postBuild \
    /usr/local/bin/postBuild 

# Enable entrypoint
run id -u
ENV ENV_PREFIX $PROJECT_DIR/env
RUN chmod 777 $ENV_PREFIX/include
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]

# Open Jupyter lab!
CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter lab --ip 0.0.0.0 --no-browser"]
