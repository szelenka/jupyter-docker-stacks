#!/usr/bin/env bash

export XDG_CACHE_HOME=${HOME}/.cache/
echo ">>> Import matplotlib the first time to build the font cache."
MPLBACKEND=Agg /usr/local/bin/python -c "import matplotlib.pyplot"