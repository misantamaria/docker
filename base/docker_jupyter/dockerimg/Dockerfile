#ARG CUDA_VERSION=12.2.0-devel-ubuntu20.04
#ARG CUDA_VERSION=12.2.0-runtime-ubuntu20.04
ARG CUDA_VERSION=12.2.0-base-ubuntu20.04
FROM nvidia/cuda:$CUDA_VERSION

ARG UID=1004
ARG GID=1004
ARG USER=macu

RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN pip3 install jupyter
RUN pip3 install jupyterlab

RUN addgroup --gid $GID $USER
RUN adduser --disabled-password --gecos '' --uid $UID --gid $GID $USER

USER $USER
WORKDIR /home/$USER

COPY requirements.txt /home/$USER
RUN pip3 install -r requirements.txt

WORKDIR /home/$USER
CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter lab --ip 0.0.0.0 --no-browser"]
