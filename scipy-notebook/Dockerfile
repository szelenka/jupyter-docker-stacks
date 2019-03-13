# inspired from
# https://github.com/jupyter/docker-stacks/blob/master/scipy-notebook/Dockerfile

FROM szelenka/base-notebook-db-drivers:latest
LABEL maintainer="Scott Zelenka <https://github.com/szelenka>"

USER root

# matplotlib cache directory
ENV XDG_CACHE_HOME=/home/$NB_USER/.cache/ \
    CHROMEDRIVER_VERSION=73.0.3683.20 \
    JUPYTERLAB_MANAGER_VERSION=0.38.1 \
    JUPYTERLAB_BOKEH_VERSION=0.6.3

COPY ./requirements-apt.txt /tmp/requirements-apt.txt
COPY ./requirements-pre.txt /tmp/requirements-pre.txt
COPY ./requirements-compile.txt /tmp/requirements-compile.txt
COPY ./requirements.txt /tmp/requirements.txt
ENV DEBIAN_FRONTEND noninteractive
RUN set -e \
  && DISTRIBUTION='stretch' \
  && buildDeps=' \
    apt-transport-https \
    build-essential \
    gcc \
    gfortran \
    python3-dev \
    pax-utils \
    curl \
    gnupg \
  ' \
  && echo "deb http://http.us.debian.org/debian sid main" >> /etc/apt/sources.list \
  && apt-get update -yqq \
  && apt-get dist-upgrade -yqq \
  && apt-get install -yqq --no-install-recommends $buildDeps \
#  && pip install --no-cache-dir --compile -U pip setuptools \
  && cat /tmp/requirements-apt.txt | egrep -v "^\s*(#|$)" | xargs apt-get install -yqq \
  && /usr/local/bin/pip install --no-cache-dir -r /tmp/requirements.txt \
  && CFLAGS="-Os -g0 -Wl,--strip-all" /usr/local/bin/pip install \
    --compile \
    --no-cache-dir \
    --global-option=build_ext \
    --global-option="-I/usr/include:/usr/local/include" \
    --global-option="-L/usr/lib:/usr/local/lib" \
    --global-option="-j 4" \
    -r /tmp/requirements-pre.txt \
  && CFLAGS="-Os -g0 -Wl,--strip-all" /usr/local/bin/pip install \
    --compile \
    --no-cache-dir \
    --global-option=build_ext \
    --global-option="-I/usr/include:/usr/local/include" \
    --global-option="-L/usr/lib:/usr/local/lib" \
    --global-option="-j 4" \
    -r /tmp/requirements-compile.txt \
  && echo ">>> Download English model for spaCy" \
  && /usr/local/bin/python -m spacy download en \
#  && echo ">>> Install Graph-Tool" \
#  && echo "deb http://downloads.skewed.de/apt/${DISTRIBUTION} ${DISTRIBUTION} main" > /etc/apt/sources.list.d/graph-tool.list \
#  && apt-key adv --keyserver pgp.skewed.de --recv-key 612DEFB798507F25 \
#  && apt-get update \
#  && apt-get install -yqq python-graph-tool \
  && echo ">>> Activate ipywidgets extension in the environment that runs the notebook server" \
  && jupyter nbextension enable --py widgetsnbextension --sys-prefix \
  && echo ">>> Activate ipywidgets extension for JupyterLab" \
  && echo ">>> Check this URL for most recent compatibilities" \
  && echo ">>> https://github.com/jupyter-widgets/ipywidgets/tree/master/packages/jupyterlab-manager"\
  && jupyter labextension install @jupyter-widgets/jupyterlab-manager@^${JUPYTERLAB_MANAGER_VERSION} \
  && jupyter labextension install jupyterlab_bokeh@${JUPYTERLAB_BOKEH_VERSION} \
  && echo ">>> Install facets which does not have a pip package at the moment" \
  && git clone https://github.com/PAIR-code/facets.git /tmp/facets \
  && jupyter nbextension install /tmp/facets/facets-dist/ --sys-prefix \
  && npm cache clean --force \
  && echo ">>> download selenium drivers" \
  && curl https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip -o /tmp/chromedriver_linux64.zip \
  && runDeps="$( \
    scanelf --needed --nobanner --recursive /usr/local \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u | cut -c4- \
      | xargs dpkg --search \
      | cut -d ':' -f 1 | sort -u \
  )" \
  && apt-get install -yqq --no-install-recommends $runDeps \
  && apt-get purge --auto-remove -yqq $buildDeps \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf \
    /etc/apt/sources.list.d/* \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
    /usr/share/man \
    /usr/share/doc \
    /usr/share/doc-base \
    /usr/local/share/jupyter/lab/staging \
    /usr/local/share/.cache \
    /usr/local/share/.node-gyp \
    /usr/local/share/.npm \
    ${XDG_CACHE_HOME}/* \
    ${HOME}/.config/configstore/*

COPY init-matplotlib.sh /usr/local/bin/start-notebook.d/
RUN chmod 777 /usr/local/bin/start-notebook.d/init-matplotlib.sh

USER ${NB_UID}