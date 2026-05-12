# This should contain Bash settings needed for the entire
# project that everyone should use. This should be checked
# into version control.
if [ -z "$PROJECT_ROOT" ]; then
  echo "[ customizations.project.bash ] WARNING: PROJECT_ROOT is not set - this will break various package managers"
fi
export PATH=${PATH}:/home/appuser/.local/bin
