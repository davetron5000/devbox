# Dockbox - Create and Manage Dev Environments with Docker

Dockbox provides a way to create and manage a dev environment using containers.  It simplifies how ancillary services like databases are run, reduces the number of steps required to do development on your app, and creates a consistent base for the entire
team to work on the app. And you can use your editor on your computer to do it.

## Install

Dockbox assumes you have access to GitHub and have both bash and Docker installed.  Thus to install:

* `git clone blah blah` doesn't matter where

OR

* Download the release and expand it somewhere. Doeson't matter where

## Setup and Upgrading

Dockbox requires three steps for managing it inside your app, since Dockbox is not a
runtime dependency - it copies itself into your app directly.

1. Install Dockbox the first time
2. Per-developer setup of Dockbox
3. Upgrading Dockbox to get new features and bugfixes

### Install Dockbox the first time

Installing Dockbox amounts to copying it into your app where you will check it in.  This
means you have *no runtime dependency* on Dockbox.

1. `cd` to wherever you downloaded Dockbox
1. `bin/install «options» «snippets and services»`

   * Options:

     * `-a «path to your app»` where your app is or will be. This will be created if needed.
     * `-i «base image»` the base image of your app's dev container. Figuring this out is not necessarily that easy (see below)
     * `-o «org name»` your org on Dockerhub or GitHub. This is used for making local images for your dev container
     * `-p «project name»` optionaly to specify the name of the project. If omitted, the basename you gave to `-a` is used.
     * `-t «tag»` a Docker tag for your devcontainer image.  Ideally this is something related to your language or framework runtime requirements and not a version of your app itself. If omitted will be based on the value you gave to `-i`.

   * Snippets and Services:

     Snippets are bits of a `Dockerfile` to include in your app's development Dockerfile.
     These snippets are the canonical way to e.g. install Node, or set up Bundler. They
     are a convienience and you don't have to use them, but they should save some
     searching.

     Services are used in a `docker-compose.yml` file to stand up ancillary service, such
     as Postgres or Redis.  These are based on the vendor or Docker's accepted way to run
     the service and should save you searching for how to do it.  But, these are a
     convienience and you can omit them.

     To use them when installing Dockbox, use tab-completion inside `templates/snippets` for things to add to your Dockerfile or `templates/services` for services your app needs to run in dev.  Dockbox knows which is which.  The order of the snippets does matter as that is the order they will be placed in the Dockerfile.

#### Choosing a Base Image

Choosing a base image is surprisingly difficult, depending on what you are doing.  If
your app is primarily written in a particular programming language, you may want to use
that language's Docker image. For example, `ruby:3.2` for a Ruby or Rails app that will
use Ruby version 3.2.

If you have multiple languages or your programming language vendor does not provide you
with a reliable base image, you can use an operating system.  Dockbox is likely assuming
a Debian-based build, so you should use Debian in that case, however you can use anything
you like, just know that you may need to tweak the snippets.

#### Choosing a Tag for your Dev Image

You are building a *development image*, not something for production.  As such, the tag
is of less importance.  That said, you will one day upgrade your base image and, on that
day, you will want to be able to run both your soon-to-be old dev environment along with
your soon-to-be-current dev environment.

Thus, I recommend your development tag have a version number in it that is related to
whatever version of dependencies is meaningful.  For example, you may be doing Node
development and want to keep everyone on Node 18.  A tag like `nodejs:18` would be
appropriate.  When you want to upgrade to Node 20, the tag would become `nodejs:20`. This
would allow you to easily run both the Node 18 and the Node 20 dev images locally.

### Per-developer setup

Although Docker largely obviates the need for per-developer setup, since developers may
be on different processor architectures, it's desirable to use images for the developer's
computer.  As such, Dockbox requires this to be explicitly stated as it cannot be
reliably determined when the various scripts are run.

To do this, each developer must run `dx/setup`.  This will create the necessary
configuration and should happen one time only, or at least whenever a dev sets up a new
computer.

### Upgrade

To upgrade Dockbox:

1. `cd` to wherever you downloaded Dockbox
1. `bin/upgrade -a «path to project»

This will *only* upgrade the scripts in `dx/` and it will overwrite them without asking.

## Usage

Dockbox installs all its files into `dx/` at the root of your app's directory.

* `dx/start` - start the dev environment. This will build the container for your app if
needed
* `dx/exec` - run a command inside your app's container

## Customization

There are a few ways to customize the behavior of Dockbox:

* Modify the Dockerfile or Docker Compose YAML file
* Change the image, project, or default service name
* Create hooks to run at certain parts of the development lifecycle
* Eject from Dockbox entirely

### Modify `Dockerfile.dx` or `docker-compose.dx.yml`

Dockbox bootstraps `Dockerfile.dx` (which describes your app's dev environment) and
`docker-compose.dx.yml` (which describes the services your app needs to run locally).
Currently, Dockbox does not maintain these.

Thus, you can modify these as needed, and Dockbox will not overwrite them.  These are
standard files used by Docker, so the Docker documentation can tell you what is possible.
The most common needs would be to add more software to the dev environment (add stuff to `Dockerfile.dx`) or modify the services you are using (change `docker-compose.dx.yml`)

### Change image, project, or default service name

If you look at `dx/docker-compose.base.env`, this contains environment variables that are
made available to `docker compose`.  You can change these values to suit your needs:

* `IMAGE` - this is the name of the dev image that gets built.  You would change this if
you are e.g. upgrading some fundamental dependency and wish to run both the old and new
dev images as containers.
* `PROJECT_NAME` - This is used with `docker compose` and essentially annotates your
containers with this name.  `dx/prune` uses this to identify containers related to your
project.
* `DEFAULT_SERVICE` - This is the service used when you run `dx/exec`.  When you set up
Dockbox the first time, the value of this will match the service name in
`docker-compose.dx.yml` for your app.  If you change this value, you should change the
service name in `docker-compose.dx.yml` to match.

### Create hooks to run at certain parts of the development lifecycle

Each script responds to `-h` and will tell you if it will execute hooks.  For example:

```
> dx/build -h
usage: dx/build [-h] 

DESCRIPTION
    Builds the Docker image based on the Dockerfile

HOOKS
    build.pre - if present, called before the main action
    build.post - if present, called after the main action
```

This says that if an executable named `dx/build.pre` is found, it will be run before
`docker build` is run.  If that script exits nonzero, `dx/build` is aborted.  This also
shows that if `dx/build.post` exists and is executable, it will run after `docker build`
is run.

These files are not managed by Dockbox, so if you need slight customizations when a `dx/`
script is run, create a hook.  That way, when you upgrade Dockbox, you won't lost your
customizations.

### Eject from Dockbox entirely

Since Dockbox copies its files to your app and creates no runtime dependency, you are
free to never use it again, and customize the scripts to your heart's content.  Just know
that `bin/upgrade` *will overwrite your files* so if you *do* customize scripts in `dx/`,
you cannot run `bin/upgrade` safely.

# Example Workflows

## Set up Your Dev Environment

Assuming you are setting up a fresh environment for an app using Dockbox:

1. Install Docker
1. Install your source control program (e.g. Git)
1. Install your favorite code editor
1. Clone the app's source code
1. `dx/setup`

## Start Up Your Dev Envrionment

1. `cd` to your app's source code
1. `dx/start`
1. In another terminal, `dx/exec bash`. You are now "logged in" to your dev environment.

That's it!  You are now ready to go

## Do a Test-Driven-Development Cycle

Suppose you are writing a Rails app, and you have a test called `test/system/buy_merch_test.rb`.

1. Set up and start your dev environment (see above)
1. Edit the file `test/system/buy_merch_test.rb` on your computer with whatever editor you want. This does not have to happen inside the running Docker container.
1. `dx/exec bin/rails test test/system/buy_merch_test.rb`
1. View the output of the test
1. Edit your app's code to make the test pass (again, the editing in your editor on your computer)
1. `dx/exec bin/rails test test/system/buy_merch_test.rb`
1. The test passes!

Note that this should be almost identical to doing dev on your computer.  You can alleviate the need for `dx/exec` each time like
so:

1. `dx/exec bash`
1. Edit the file `test/system/buy_merch_test.rb` on your computer.
1. `bin/rails test test/system/buy_merch_test.rb`
1. View the output of the test
1. Edit your app's code to make the test pass (again, the editing in your editor on your computer)
1. `bin/rails test test/system/buy_merch_test.rb`
1. The test passes!

## Run Your App Locally

Let's suppose your app has a script named `bin/run` that runs it on port 3000.

1. `dx/exec bin/run`
1. Open up `http://localhost:3000` on your computer in whatever browser you want.

The point is that *any* command-line based flow can be mapped to Dockbox by running your command line commands inside the dev
container using `dx/exec`

### Core Values

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

# Q&A

## Why Bash Scripts Copied to a Repo?

By nature, dev environment setup occurs in a system in a state of nascency. You cannot really assume *any* software exists to rely upon.  Dockbox assumes Docker and bash are installed, as this is a good assumption.  Dockbox does not, for example, assume any package manager, or any programming language like Ruby or Python.

## Why not `curl | bash` installation?

If you are going to copy and paste something into your terminal to install it, it might as well be more likely to be a command you can inspect and understand.  `git clone` is fine.

## Why not `dx start`?

To the extent that devs are typing commands on the command-line, they should be short, auto-completeable on a stock shell, and not require spaces or complex subcommands.
