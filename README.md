# devbox.computer

Contains two things:

* Source code for [the website of "Sustainable Dev Environments with Docker and Bash"](https://devbox.computer)
* Scripts and templates to create your own Docker-based dev environment.

## DX - Docker-based Dev Environment

These scripts are likely ahead of the book and represent what I'm using day to day.  `bin/install` will
set it up for your projects.  Note that you cannot depend on this project directly, it just does code
generation for you.

### Setting up a New Project

1. Clone this repo somewhere, for example `~/Projects`:

   ```
   cd ~/Projects
   git clone git@github.com:davetron5000/devbox.git
   ```
2. From `~/Projects` (or wherever), run `bin/install`

   ```
   # -a -> location of your app/projects
   # -o -> org name needed to create Docker images (nothing will ever be pushed)
   # -i -> image name for your Docker image
   devbox/bin/install -a my-new-app -o my-org -i node:16
   ```

3. This created `~/Projects/my-new-app` as well as:

   * `Dockerfile.dx` - Dockerfile to create your image used to make a container where you do development.
   * `docker-compose.dx.yml` - Compose file useful to starting/stopping + adding other services like databases.
   * `dx/build` - Builds your images (never pushes)
   * `dx/start` - Starts your dev enviornment
   * `dx/exec` - Runs commands in your dev environment

4. Depending on your needs, you may need to modify `Dockerfile.dx` or `docker-compose.dx.yml`. If you
   do, stop your containers and run `dx/build` then `dx/start` again.

### Using the Dev Environment

1. Your project's directory is mapped into the container.  It uses the same path, so if your project is
   in `/home/pat-example/Projects/Personal/my-new-app`, that is where it will be inside the dev
   environment.
2. `dx/exec bash` will "log in" to the dev environment. You'll be able to run any command and have
   access to your entire project's files.
3. You can edit your code locally using the editor of your choice. Your changes will be seen instantly
   inside the dev environment.

### Credentails et. al.

Since credential file names and locations are super inconsistent, DX cannot manage them directly. It
does provide the convention of `dx/credentials` as the root of where you should store them.  You can
then create a setup script for your project that copies them from there to wherever they need to go
inside the container. `dx/credentials` is placed into `.gitignore` so you don't check it in. **Never
push your Docker images** as they would contain these credentials.


