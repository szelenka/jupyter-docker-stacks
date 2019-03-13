# Jupyter Docker Stacks (custom)

Jupyter Docker Stacks are a set of ready-to-run Docker images containing Jupyter applications and interactive computing tools.

This is inspired from the official [Jupyter Docker Stacks](https://github.com/jupyter/docker-stacks) repo, butwith custom Docker images to dramatically reduce the image sizes and use official Python (rather than Anaconda):

It also adds more useful packages than the standard scipy-notebook.

## Image size comparison

As of 2019-03-13:

Image|Jupyter|Mine|
|---|---|---|
base-notebook|767MB|602MB|
minimal-notebook|2.9GB|-|
base-notebook-db-drivers|-|942MB|
scipy-notebook|4.15GB|2.88GB|
tensorflow-notebook|4.85GB|-|
tensorflow-gpu-notebook|-|5.53GB|
datascience-notebook|5.64GB|-|

## Image Repos

* [szelenka/base-notebook](./jhub-base) inspired by [jupyter/base-notebook](https://github.com/jupyter/docker-stacks/tree/master/base-notebook)
* [szelenka/db-drivers](./db-drivers) simply installing python database drivers
* [szelenka/scipy-notebook](./ds-workspace) inspired by [jupyter/scipy-notebook](https://github.com/jupyter/docker-stacks/tree/master/scipy-notebook)
* [szelenka/tensorflow-notebook](./ds-workflow-gpu) inspired by [jupyter/tensorflow-notebook](https://github.com/jupyter/docker-stacks/tree/master/tensorflow-notebook)
* [szelenka/k8s-singleuser](./k8-data-science) inspired by [jupyterhub/k8s-singleuser-sample]()
