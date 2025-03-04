#!/bin/bash --login
set -e

echo ". ${HOME}/miniconda3/etc/profile.d/conda.sh" >> ${HOME}/.bashrc
# Make bash automatically activate the conda environment
echo "conda activate ${ENV_PREFIX}" >> ~/.bashrc

# Define an array of environment variable names from the ENV_VARS Compose variable
IFS=',' read -ra ENV_VAR_NAMES <<< "$ENV_VARS"

echo "ENV_VAR_NAMES=${ENV_VAR_NAMES[@]}"

# Loop through the array of environment variable names and set the variables
for ENV_VAR_NAME in "${ENV_VAR_NAMES[@]}"; do
  ENV_VAR_VALUE="${!ENV_VAR_NAME:-default}"
  echo "$ENV_VAR_NAME=$ENV_VAR_VALUE" >> ${HOME}/.Renviron
done

# start rstudio server
/init
exec "$@"