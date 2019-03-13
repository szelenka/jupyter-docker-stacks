#!/usr/bin/env bash

# remove default empherial kernel
for k in $(jupyter kernelspec list | awk '{print $1}' | tail -n +2);
do
  echo ">>> Removing kernel: ${k}"
  echo y | jupyter kernelspec remove ${k}
done

# verify we have a venv setup to launch Jupyter
# ref: https://medium.com/@eleroy/jupyter-notebook-in-a-virtual-environment-virtualenv-8f3c3448247
virtualenv .env --python=$(which python) --system-site-packages --no-setuptools --no-pip --no-wheel
source .env/bin/activate
python -m ipykernel install --user --name=python3

# link /share, /data to home directory
if [ -d "/share" ] && [ ! -L "${HOME}/share" ]; then
  ln -s /share ${HOME}/share
fi

if [ -d "/data" ] && [ ! -L "${HOME}/data" ]; then
  ln -s /data ${HOME}/data
fi