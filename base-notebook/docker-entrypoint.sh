#!/bin/bash

set -e

# if the running user is an Arbitrary User ID which is not present in whoami
if ! whoami &> /dev/null; then
  echo "make sure we have read/write access to /etc/passwd"
  if [ -w /etc/passwd ]; then
    echo "write a line in /etc/passwd for the Arbitrary User ID in the 'root' group"
    USERNAME=${JUPYTERHUB_USER:-default}
    HOME="/home/${USERNAME}"
    echo "${USERNAME}:x:$(id -u):0:${USERNAME} user:${HOME}:/sbin/nologin" >> /etc/passwd
    echo "set arbitrary user to $(whoami)"
    NB_USER=$(whoami)
  else
    echo "read-write access denied for USER_ID:$(id -u) on /etc/passwd"
    exit 1
  fi
fi


# set the users home as it's working directory
cd ${HOME}

# launch Jupyter
if [[ ! -z "${JUPYTERHUB_API_TOKEN}" ]]; then
  # launched by JupyterHub, use single-user entrypoint
  exec /usr/local/bin/start-singleuser.sh "$@"
elif [[ ! -z "${JUPYTER_ENABLE_LAB}" ]]; then
  . /usr/local/bin/start.sh jupyter lab "$@"
else
  . /usr/local/bin/start.sh jupyter notebook "$@"
fi