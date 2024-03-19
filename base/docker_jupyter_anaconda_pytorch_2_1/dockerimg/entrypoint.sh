#!/bin/bash --login
set -e
echo 'activate conda'
conda activate $ENV_PREFIX
#echo 'about to get /home/'${USER_NAME}'/work file list'
#ls /home/${USER_NAME}/work

#echo 'install work'
#pip install -e /home/${USER_NAME}/work

echo 'go exec!' $@
exec "$@"
