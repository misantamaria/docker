#!/bin/bash --login
set -e
echo 'activate conda'
conda activate $ENV_PREFIX
#echo 'install -e /home/'$USER'/work'
#pip install -e /home/$USER/work
echo 'exec' $@
exec "$@"
