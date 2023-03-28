# Dockbox - Create and Manage Dev Environments with Docker

Dockbox provides a way to create and manage a dev environment using containers.  It simplifies how ancillary services like
databases are run, reduces the number of steps required to do development on your app, and creates a consistent base for the entire
team to work on the app. And you can use your editor on your computer to do it.

Isn't this just Docker and a `docker-compose.yml` file?  Mostly, but it's also part convention and part light scripting to make the
process easier.

# Example Workflows

## Set up Your Dev Environment

Assuming you are setting up a fresh environment for an app using Dockbox:

1. Install Docker
1. Install your source control program (e.g. Git)
1. Install your favorite code editor
1. Clone the app's source code
1. `dx/start`


That's it!  You are now ready to go

## Do a Test-Driven-Development Cycle

Suppose you are writing a Rails app, and you have a test called `test/system/buy_merch_test.rb`.

1. Edit the file `test/system/buy_merch_test.rb` on your computer.
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

# Set Up

There are two types of setup needed to use Dockbox.  The first is to install Dockbox in your app. The second is for each developer
to configure Dockbox for their computer.

## Install Dockbox in an App

1. Make sure your app is checked out somewhere
1. Clone this Repo
1. `bin/init`
1. Follow the prompts

Once done, several files will have been added to your app's repo. If your app has a `.gitignore`, will have been modified.  Review
these, then commit them.

## Per-Developer Dockbox Setup

Because you may have a mix of hardware architectures on the team, each developer needs to do their own setup to ensure they are
running appropriate images for the services and for the app.

1. Make sure the app is checked out
1. `dx/setup`
1. Follow the prompts

That's it!

## Update Your Dockbox Configure When Dockbox has a New Version

While Dockbox is not a "live" dependency of your app (meaning you can install it and then manage the scripts and files yourself), you can refresh your app's Dockbox installation if and when Dockbox changes:

1. Make sure your app is checked out and you have `cd`ed there
1. `dx/update-dx`
1. This will clone Dockbox from GitHub and compare to your copies of the files.  It will show you what it's going to do and ask for confirmation:
   1. Each script in `dx/`
   1. Add any new scripts
   1. Remove any old scripts
   1. Analyze `docker-compose.dx.yml` for incompatibilities
   1. Output manual instructions for changes needed to `docker-compose.dx.yml` and `Dockerfile.dx`

# Details

If you look at what all this does, it's basically:

* A `Dockerfile.dx` where your app can run and be tested.
* A `docker-compose.dx.yml` that configures your app and any needed services.
* A `dx/` folder with some bash scripts
* Three configuration files:
  * `dx/docker-compose.env.base` - per project environment variables needed by `docker-compose.dx.yml` (this is checked in)
  * `dx/docker-compose.env.local` - per developer environment variables needed by `docker-compose.dx.yml` (this is not checked in)
  * `dx/docker-compose.env` - a summation of the previous two files becuase `docker compose --env-file` requires one file (this is not checked in)

Once `bin/init` has been run, it's helpful to consider your relationship with Dockbox:

* `Dockerfile.dx` and `docker-compose.dx.yml` - You own these and should change them as needed to make sure you have the services
* `dx/` folder can be managed by Dockbox and doesn't need to change.  But, because Dockbox is not a system dependency you install
globablly, you can just change stuff here if you like.

## How it Works

(If you do not know about Docker, [learn about it first](./docker.md) so this section will make sense)

`Dockerfile.dx` is not intended for production. It's entire purpose is to setup and install the tools needed to run your app.  If all your app needs is a programming language, `Dockerfile.dx` will be pretty minimal.  In particular, you won't find `RUN`, `EXPOSE`, or any other stuff like that, because it's not needed. You will never just run an image based off this `Dockerfile`.

`docker-compose.dx.yml` is a Docker Compose file that will run a container for the app and then any other services needed.  The
stanza for the app is what's important: It sets up a port mapping, configures a bind mount to access the app's source code, and
sets a few other things needed to make it easy to "log in" to this container.

`dx/docker-compose.env` (which is created by summing `docker-compose.env.base` and `docker-compose.env.local`) is needed to control the behavior of the Docker system. In particular, it will control the architecture used for pulling images of related services, will ensure that the image built by `dx/build` is used here, and provide a project name which is needed to manage running containers.

The scripts in `bin/` basically wrap commands to the `docker` command-line client.

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

By nature, dev environment setup occurs in a system in a state of nascency. You cannot really assume *any* software exists to rely
upon.  Dockbox assumes Docker and bash are installed, as this is a good assumption.  Dockbox does not, for example, assume any
package manager, or any programming language like Ruby or Python.

## Why not `curl | bash` installation?

If you are going to copy and paste something into your terminal to install it, it might as well be more likely to be a command you
can inspect and understand.  `git clone` is fine.

## Why not `dx start`?

To the extent that devs are typing commands on the command-line, they should be short, auto-completeable on a stock shell, and not
require spaces or complex subcommands.
