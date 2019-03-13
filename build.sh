#!/usr/bin/env bash

REPO=szelenka
TAG=latest
for NAME in ./*;
do
  if [ ! -d "${NAME}" ]; then continue; fi
  echo ">>> Building ${NAME##*/}"
  docker build -f ${NAME}/Dockerfile ${NAME} --tag ${REPO}/${NAME##*/}:${TAG}
  docker push ${REPO}/${NAME##*/}:${TAG}
done
