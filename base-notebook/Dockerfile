# inspired from
# https://github.com/jupyter/docker-stacks/tree/master/base-notebook

# Specify Python package versions
ARG PYTHON_VERSION='3.7'

# Specify base image to start this image build
FROM python:${PYTHON_VERSION}-slim-stretch
LABEL maintainer="Scott Zelenka <https://github.com/szelenka>"

ARG NB_USER='jovyan'
ARG NB_UID='1000'
ARG NB_GID='0'
ARG TINI_VERSION='0.18.0'
ARG HUB_EXTENSION_VERSION='0.12.0'
ARG NODEJS_VERSION='11'

# Configure environment
ENV SHELL=/bin/bash \
    NB_USER=${NB_USER} \
    NB_UID=${NB_UID} \
    NB_GID=${NB_GID} \
    LC_ALL='en_US.UTF-8' \
    LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TINI_VERSION=${TINI_VERSION} \
    HUB_EXTENSION_VERSION=${HUB_EXTENSION_VERSION} \
    NODEJS_VERSION=${NODEJS_VERSION} \
    HOME=/home/${NB_USER}

USER root

# Install all OS dependencies
COPY ./requirements.txt /tmp/requirements.txt
ENV DEBIAN_FRONTEND noninteractive
RUN set -e \
  && useradd -m -s /bin/bash -N -u ${NB_UID} -g ${NB_GID} ${NB_USER} \
  && buildDeps=' \
    apt-transport-https \
    build-essential \
    gcc \
    gfortran \
    python3-dev \
    pax-utils \
    curl \
    gnupg \
    dirmngr \
  ' \
  && basePackages=" \
    git \
    bzip2 \
    ca-certificates \
    sudo \
    fonts-liberation \
  " \
  && apt-get update -yqq \
  && apt-get install -yqq locales \
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && locale-gen \
  && apt-get dist-upgrade -yqq \
  && apt-get install -yqq --no-install-recommends $buildDeps $basePackages \
  && echo ">>> install tini" \
  && TINI_HOME="/usr/bin" \
  && curl -fSL "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini" -o "${TINI_HOME}/tini" \
  && curl -fSL "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static" -o "${TINI_HOME}/tini-static" \
  && ln -s "${TINI_HOME}/tini" /usr/local/bin/tini \
  && ln -s "${TINI_HOME}/tini-static" /usr/local/bin/tini-static \
  && chmod +x "${TINI_HOME}/tini" "${TINI_HOME}/tini-static" \
  && echo ">>> install nodejs" \
  && curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION}.x | bash - \
  && apt-get install -y nodejs \
  && echo ">>> install python modules" \
#  && /usr/local/bin/pip install --no-cache-dir --compile -U pip setuptools
  && CFLAGS="-Os -g0 -Wl,--strip-all" /usr/local/bin/pip install \
    --no-cache-dir \
    --compile \
    --global-option=build_ext \
    --global-option="-I/usr/include:/usr/local/include" \
    --global-option="-L/usr/lib:/usr/local/lib" \
    --global-option="-j 4" \
    -r /tmp/requirements.txt \
  && jupyter labextension install @jupyterlab/hub-extension@^${HUB_EXTENSION_VERSION} \
  && jupyter notebook --generate-config \
  && echo ">>> compress jupyter-lab javascript" \
  && npm install terser -g \
  && for js in /usr/local/share/jupyter/lab/static/*.js; \
      do \
        if [ -d "${js}" ]; then continue; fi \
        && echo ">>> Compressing ${js##*/}" \
        && terser -c -o ${js} ${js} \
        ; \
      done \
  && npm cache clean --force \
  && echo ">>> cleanup" \
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
    ${HOME}/.cache \
    ${HOME}/.npm \
    /usr/local/share/.cache \
    /usr/local/share/.node-gyp \
    /usr/local/share/.npm \
    ${HOME}/.config/configstore/*

COPY start.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
COPY docker-entrypoint.sh /usr/local/bin/
COPY jupyter_notebook_config.py /etc/jupyter/
COPY setup-venv.sh /usr/local/bin/start-notebook.d/
RUN ln -s /usr/local/bin/docker-entrypoint.sh / \
  && mkdir -p \
    /home/ \
    /etc/jupyter/ \
    /usr/local/bin/start-notebook.d \
    /usr/local/bin/before-notebook.d \
  && chgrp -R ${NB_GID} \
    /home/ \
    /usr/local/bin/docker-entrypoint.sh \
    /etc/passwd \
    /etc/jupyter/ \
    /usr/local/share/jupyter/ \
    /usr/local/bin/start-notebook.d \
    /usr/local/bin/before-notebook.d \
  && chmod -R g+rwX \
    /home/ \
    /usr/local/bin/docker-entrypoint.sh \
    /etc/passwd \
    /etc/jupyter/ \
    /usr/local/share/jupyter/ \
    /usr/local/bin/start-notebook.d \
    /usr/local/bin/before-notebook.d \
  && chmod -R 777 \
    /usr/local/bin/docker-entrypoint.sh \
    /usr/local/bin/start-singleuser.sh \
    /usr/local/bin/start.sh \
    /usr/local/bin/start-notebook.d \
    /usr/local/bin/before-notebook.d

# Switch back to jovyan to avoid accidental container runs as root
USER ${NB_UID}

EXPOSE 8888
WORKDIR ${HOME}

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["docker-entrypoint.sh"]