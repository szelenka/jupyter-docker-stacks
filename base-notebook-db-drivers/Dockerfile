FROM szelenka/base-notebook:latest as base
LABEL maintainer="Scott Zelenka <https://github.com/szelenka>"

USER root

COPY ./instantclient-basiclite-linux.x64-12.2.0.1.0.zip /opt/oracle/instantclient-basic-12.zip
COPY ./instantclient-basiclite-linux.x64-18.3.0.0.0dbru.zip /opt/oracle/instantclient-basic-18.zip
RUN buildDeps='\
    unzip\
    ' \
    && apt-get update \
    && apt-get install -y $buildDeps --no-install-recommends \
    && unzip /opt/oracle/instantclient-basic-12.zip -d /opt/oracle \
    && unzip /opt/oracle/instantclient-basic-18.zip -d /opt/oracle \
    && rm \
      /opt/oracle/instantclient-basic-12.zip \
      /opt/oracle/instantclient-basic-18.zip \
    && apt-get purge -y --auto-remove $buildDeps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# copy over only the extracted files, reduce the size slightly
FROM szelenka/base-notebook:latest

USER root

COPY --from=base /opt/oracle /opt/oracle
COPY ./requirements-apt.txt /tmp/requirements-apt.txt
COPY ./requirements.txt /tmp/requirements.txt

# set oracle driver environment variables
ENV NLS_LANG=AMERICAN_AMERICA.AL32UTF8 \
    LD_LIBRARY_PATH=/opt/oracle/instantclient_12_2:/opt/oracle/instantclient_18_3:$LD_LIBRARY_PATH \
    DEBIAN_FRONTEND=noninteractive

RUN set -e \
  && echo '/opt/oracle/instantclient_12_2 \n/opt/oracle/instantclient_18_3' > /etc/ld.so.conf.d/oracle-instantclient.conf \
  && ldconfig \
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
  && apt-get update -yqq \
  && apt-get install -yqq --no-install-recommends $buildDeps \
  && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && curl https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/mssql-release.list \
  && apt-get update -yqq \
  && apt-get dist-upgrade -yqq \
#  && pip install --no-cache-dir --compile -U pip setuptools \
  && cat /tmp/requirements-apt.txt | egrep -v "^\s*(#|$)" | ACCEPT_EULA=Y xargs apt-get install -yqq \
  && CFLAGS="-Os -g0 -Wl,--strip-all" /usr/local/bin/pip install \
    --no-cache-dir \
    --compile \
    --global-option=build_ext \
    --global-option="-I/usr/include:/usr/local/include" \
    --global-option="-L/usr/lib:/usr/local/lib" \
    --global-option="-j 4" \
    -r /tmp/requirements.txt \
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
    /usr/share/doc-base

USER ${NB_UID}