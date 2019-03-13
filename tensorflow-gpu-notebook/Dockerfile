# inspired from
# https://github.com/tensorflow/tensorflow/blob/master/tensorflow/tools/dockerfiles/dockerfiles/gpu.Dockerfile
# https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/10.0/base/Dockerfile
# https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/10.0/runtime/Dockerfile
# https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/10.0/runtime/cudnn7/Dockerfile

FROM szelenka/scipy-notebook:latest
LABEL maintainer="Scott Zelenka <https://github.com/szelenka>"

ARG CUDA=10.0
ENV CUDA_VERSION=10.0.130 \
    CUDNN_VERSION=7.5.0.56 \
    NCCL_VERSION=2.4.2

ENV CUDA_PKG_VERSION 10-0=${CUDA_VERSION}-1

USER root

# TODO:
# number, install basic mkl libraries
# https://gist.github.com/mgoldey/f3886b7accc0cd730e37528e09f7bc81

# install python packages
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements-apt.txt /tmp/requirements-apt.txt
ENV DEBIAN_FRONTEND noninteractive
RUN set -e \
  && buildDeps=' \
    build-essential \
    ca-certificates \
    apt-transport-https \
    gnupg \
    curl \
    software-properties-common \
    unzip \
    libfreetype6-dev \
    libhdf5-serial-dev \
    libzmq3-dev \
    pkg-config \
  ' \
  && apt-get update -yqq \
  && apt-get dist-upgrade -yqq \
  && apt-get install -yqq --no-install-recommends $buildDeps \
  && NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 \
  && NVIDIA_GPGKEY_FPR=ae09fe4bbd223a84b2ccfce3f60f4b3d7fa2af80 \
  && apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub \
  #&& apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +5 > cudasign.pub \
  #&& echo "$NVIDIA_GPGKEY_SUM  cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub \
  && echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list \
  && echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list \
  && apt-get update -yqq \
  && cudaDeps=" \
    cuda-cudart-${CUDA_PKG_VERSION} \
    cuda-compat-10-0=410.48-1  \
    cuda-command-line-tools-${CUDA_PKG_VERSION} \
    cuda-cublas-${CUDA} \
    cuda-cufft-${CUDA_PKG_VERSION} \
    cuda-curand-${CUDA_PKG_VERSION} \
    cuda-cusolver-${CUDA_PKG_VERSION} \
    cuda-cusparse-${CUDA_PKG_VERSION} \
    libcudnn7=${CUDNN_VERSION}-1+cuda${CUDA} \
    nvinfer-runtime-trt-repo-ubuntu1604-5.0.2-ga-cuda${CUDA} \
  " \
  && apt-get install -yqq --no-install-recommends $cudaDeps \
  && apt-mark hold libcudnn7 \
  && ln -s cuda-10.0 /usr/local/cuda \
  && echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
  && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf \
  && apt-get update \
  && apt-get install -yqq --no-install-recommends libnvinfer5=5.0.2-1+cuda${CUDA} \
  && pip install --no-cache-dir --compile -U pip setuptools \
  && cat /tmp/requirements-apt.txt | egrep -v "^\s*(#|$)" | xargs apt-get install -yqq \
  && /usr/local/bin/pip install tensorflow-gpu==1.13.1 \
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
  && echo ">>> Install http_over_ws extension" \
  && jupyter serverextension enable --py jupyter_http_over_ws \
  && apt-get install -yqq --no-install-recommends $runDeps \
  && apt-get purge --auto-remove -yqq $buildDeps \
  && apt-get autoremove -yqq --purge \
  && apt-get clean \
  && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
    /usr/share/man \
    /usr/share/doc \
    /usr/share/doc-base

# For CUDA profiling, TensorFlow requires CUPTI.
ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH} \
    LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=compute,utility \
    NVIDIA_REQUIRE_CUDA="cuda>=10.0 brand=tesla,driver>=384,driver<385"

# TODO:
# numba pointers to CUDA
# http://numba.pydata.org/numba-doc/latest/user/installing.html
ENV NUMBAPRO_CUDA_DRIVER='' \
    NUMBAPRO_NVVM='' \
    NUMBAPRO_LIBDEVICE=''

# TensorBoard
EXPOSE 6006

USER ${NB_UID}