# DevBox - Create and Manage Dev Environments with Docker

DevBox provides a way to create and manage a dev environment using containers.  In its current incarnation, it provides a way to
create a `Dockerfile.dx` and `docker-compose.dx.yml` to run your app and its services *and* scripts for managing all of that.

It does this with no runtime or devtime dependency.

In the future it could also make it easier to figure out the canonical way to do things in Docker and Compose.

## Install

DevBox assumes you have access to GitHub and have both bash and Docker installed.  Thus to install:

1. `git clone https://github.com/davetron5000/dockbox` anywhere you want, doesn't matter

OR

1. Download the release and expand it somewhere. Doeson't matter where.

## Usage

There are three parts of using DevBox:

1. Installing it into your app for the first time
2. Using it for day-to-day development
3. Upgrading it when DevBox fixes bugs and adds features

### Install DevBox Into Your App

Installing DevBox will generate some files and copy some scripts:

1. `cd` to wherever you downloaded DevBox
1. `bin/install «options» «snippets and services»`

   * Options:

     * `-a «path to your app»` where your app is or will be. This will be created if needed.
     * `-i «base image»` the base image of your app's dev container. Figuring this out is not necessarily that easy (see below)
     * `-o «org name»` your org on DevBox or GitHub. This is used for making local images for your dev container
     * `-p «project name»` optionaly to specify the name of the project. If omitted, the basename you gave to `-a` is used.
     * `-t «tag»` a DevBox tag for your devcontainer image.  Ideally this is something related to your language or framework runtime requirements and not a version of your app itself. If omitted will be based on the value you gave to `-i`.

   * Snippets and Services:

     - Snippets are bits of a `Dockerfile` to install software. In theory, these are based on the vendor-provided,
       canonical way to install software.  **Experimental - review these after install**

     - Services are stanzas for Docker Compose to run a service alongside your app.  In theory, the image names
       and any configuration are based on the vendor-provided images (or Docker The Company-provided).
       **Experimental - review these after install**
1. Review `Dockerfile.dx` and `docker-compose.dx.yml` that were copied into your app

*NOTE* at this point, **you own** `Dockerfile.dx` and `docker-compose.dx.yml`. DevBox won't change them.  But **DevBox** owns the
scripts it copied into `dx/`.  See below for how to inject behavior into these scripts.  When you upgrade DevBox, the scripts it
owns will be overwritten.

### Day to Day Development

1. `dx/build` to build an image from `Dockerfile.dx` (needed at least once, but not frequently)
2. `dx/start` to start up all images for development
3. `dx/exec` to run commands inside the container for your app. You can `dx/exec bash` to "log in" to the app's container and run commands.  Your app's source code is available inside the container.
4. `dx/stop` to shut it all down

### Upgrading DevBox in Your App

1. `cd` to wherever you installed DevBox
1. Update it, either via git or re-downloading
1. `bin/upgrade -a «path to your project»`

**This will overwrite `dx/` scripts** that DevBox owns.  Scripts you created here are untouched, as are any `.pre` or `.post`.

## Core Values

I know, how can a few shell scripts have *values*, right?  Well, they do.

* Versions of software and tools used to build an app should be consistent across its developers
* Your computer is not your app's dev environment, but instead *runs* it
* You should edit code in the editor of your choice
* Scripts are better than documentation or shell aliases

These values have consequences:

* Your dev environment should be *virtual*
* Your dev environment's primary functions should be *scripted* and not require any flags or options by default
* Your app's source code should be accessible to both the dev environment and your computer
* Only the most minimal configuration that is developer-specific should be required to be specified by each developer

