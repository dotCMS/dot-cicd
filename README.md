# Dot CI/CD

## Overview
The purpose of yhis project is to store no application code but the required functionality to throw into CI (**Travis** and soon into **Github Actions**) the code found in **core** (and probably more).

It includes from bare bash scripts, initial setup files to **Docker** images. In other words everything else that is not, in this first initiaive, the **core** application code.

The code and resources stored in this repo are meant to be consumed by the current CI, which in this case is **Travis**. But soon enough there should be some **Github Actions** pieces of work around.

## Resources
The CI configured in the application project will import the code found in this repo to make it available to its CI workspace.

This is the current directory structure.
```
dot-cicd
└──docker
|  └──setup
|  |  └──db
|  |     └──mssql
|  |     └──mysql
|  |     └──oracle
|  |     └──postgres
|  └──tests
|     └──curl
|     └──integration
|     └──seed
|     └──shared
|     └──sidecar
└──pipeline
   └──travis
      └──core
```

There are 2 types of identified resources that are consequently located in two main directories.

### Docker Resources
That's everything under `dot-cicd/docker` folder. It has two subtypes of *Docker Resources*: `setup` and `tests`.

#### Setup
It contains files to be eventually mounted as volumes in Docker. For this specific case it has the initialization scripts for the supported database images.

#### Tests
Here we have divided by the three types of tests: unit, integration and postman (curl), some shared resources and a **DotCMS** base image with everything it needs to be an operational instance.

It consits of ***Dockerfiles***, **Docker Compose**, even scripts to embed in the actual image, and maybe script to invoke the whole thing.

### Pipeline
This located under the `dot-cicd/pipeline` directory.

These are actual scripts that are considered the entry points to the *pipeline*. When using **Travis**, the `.travis.yml` file will reference scripts in this folder, which will use **Google Cloud** YAML files to build images and run the containers using **Docker Compose**.

This kind reources can be found at `dot-cicd/pipeline/travis` and specifically for the `core` project at `dot-cicd/pipeline/travis`. Meaning that a project can be "onboarded" to this new pattern by adding the corresponding directory here.

At the same time and by convetion, projects using a different CI/CD technology, should be included in `dot-cicd/pipeline` (e.g. `dot-cicd/pipeline/github-actions`) and subsequently "onboard" the desired projects onto it.

## Caveats
This is a first initiative to satisfy the need of adding postman tests for the `core` project to the current **Travis CI**. Therefore a lot of things were implemented with `core` and **Travis** in mind.

There will certainly be major changes to this structure and the way of doing things as we include more CI/CD technologies and/or projects. So the refactoring to turn this as generic as we can will probably be an ongoing process until it reachs some maturity.
