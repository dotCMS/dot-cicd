# Sidecar

## Overview
There are several scenarios that we may want to implement where a DotCMS instance is up and running.
An example of this is the `Vulnerability Scan`, the eventual `Cypress Tests` and even the `Postman Tests`.

The sidecar feature comes to help to reuse all that involves running a DotCMS Docker image. That is:
- A Platform License
- A starter other than the default (empty starter)
- A SSL certificate to allow to receive `HTTPS` requests

## Implementation
Those being identified, we have defined a set of steps that can reproduced every time to start a DotCMS instance.
The `pipeline/github/core/runSidecar.sh` scripts is implemented with this mind. Allowing the dev to create a piece of functionality (probably another `Dockerfile` with a corresponding `docker-compose`) and that is defined as a placeholder in the `runSidecar.sh` script.

An example of this will be at https://github.com/dotCMS/dot-cicd/tree/master/docker/images/scan/Dockerfile and https://github.com/dotCMS/dot-cicd/tree/master/docker/images/scan/dotcms-scan-service.yml. 

There are several key facts to take into consideration do so:

### Arguments
The `runSidecar` receives the first (and mandatory) argument to be considered as the "sidecar app" therefore and by convention, the script assumes there's a folder named like it at `docker/images` level.
This location can be overriden by defining the `SIDECAR_APP_CONTEXT` env-var. Then the script will try to locate the "sidecar app" folder within whatever is defined in `SIDECAR_APP_CONTEXT`.

The rest of arguments will be passed to the execution of the sidecar docker image as an env-var named `SIDECAR_ARGS`.

### Execution steps
Introducing the `runSidecar.sh` script which basically does the following steps:
- Process the arguments to establish some env-vars referencing mostly locations
- Login to docker
- Fetch the `docker` repo to build the parametrized DotCMS image
- Build that DotCMS image passing the `BUILD_ID` (commit/branch) param
- Gather all the resources needed to build the sidecar image
- Build the sidecar image
- Using `docker-compose` to start the four involved images (sidecar, parametrized DotCMS, open distro and database)
- Using `docker-compose` to stop the four involved images (sidecar, parametrized DotCMS, open distro and database)

### What happens when docker-compose starts the image bundle?
Basically it will start every service with no specific order.

For this matter, when DotCMS is started it waits un until it can establish a DB connection.
Once the DotCMS image makes sure the DB is ready it will start tomcat and deploy DotCMS.

At the same time the sidecar container should wait at least **3 minutes** to make sure DotCMS is deployed. I leave this entire to be customized by the developer.
The sidecar container runs what it was created for and once finished all involved images are stopped.

Happy sidecaring!