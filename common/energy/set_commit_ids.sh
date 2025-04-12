# The commit ID of the ESP-IDF repository.
ESP_IDF_COMMIT=9b33081ad38dae47ee01d6420881e1fcde948b47

# The commit ID of the Border Router.
BORDER_ROUTER_COMMIT=33a71dfd2f3ac5aafc9dc19e9ab3e8e4576d4919

# The commit ID of the SEDs.
FRONT_DOOR_COMMIT=e9b3fa6bbfeac8db1994ab3e09a90871f39a1600
WINDOW_COMMIT=d755d55aa9ab268c87516e6a54c063515db76c16
AIR_QUALITY_COMMIT=89ed0ba0c64cf160ad9bd68f77f06923d068b62d
SED_COMMIT=4d999903881e37f46ff9bde23885dab5756f8526

# The location of each of the repositories.
ESP_IDF_LOC=${HOME}/esp/esp-idf
OPENTHREAD_LOC=${HOME}/esp/esp-idf/components/openthread/openthread
BORDER_ROUTER_LOC=$HOME/Desktop/Repositories/br_energy/examples/basic_thread_border_router

FRONT_DOOR_LOC=$HOME/Desktop/Repositories/front-door
WINDOW_LOC=$HOME/Desktop/Repositories/window
AIR_QUALITY_LOC=$HOME/Desktop/Repositories/air-quality
SED_LOC=$HOME/Desktop/Repositories/energy-usage-sed-simple

function print_delimiter() {
  echo "-----------------------------------------------------------------------------------------"
}

function show_last_commit() {
  git --no-pager log -n1
}

# Command Format:
#   change_repo_commit [name of repo as string] [path to local repo] [expected experiment commit id]
#
#   [name of repo as string] =          $1
#   [path to local repo] =              $2
#   [expected experiment commit id] =   $3
#
# Example:
#   change_repo_commit "ESP-IDF" "$ESP_IDF_LOC" "$ESP_IDF_COMMIT"
#
# Sources Used:
#   https://stackoverflow.com/a/45652159/6621292
#   https://stackoverflow.com/a/43854593/6621292
#   https://stackoverflow.com/a/7737071/6621292
#   https://stackoverflow.com/a/61751340/6621292
#
function change_repo_commit() {
  print_delimiter

  # Go to the local Git repository.
  cd $2
  printf "Currently in repository: %s\n\n" "$(pwd)"

  # Clean the repo of all unstaged changes.
  git restore . --recurse-submodules
  echo "Did a GIT RESTORE (with --recurse-submodules) to clear all unstaged changes."

  git clean -f
  echo "Did a GIT CLEAN to remove all untracked files."

  printf "\nCommit BEFORE Checkout: %s.\n" "$(git rev-parse HEAD)"

  # Change repo to the version that we want to use in the experiments.
  git -c advice.detachedHead=false checkout --recurse-submodules $3
  echo "Completed git checkout (with --recurse-submodules)."

  # Prove that the repository is at the correct commit ID,
  # and that no unstaged changes have been made to the repository.
  #
  printf "Repository is now at EXPERIMENT COMMIT ID: %s.\n\n" "$(git rev-parse HEAD)"

  git status
  printf "\n"

  git --no-pager log --pretty=oneline -n1
  print_delimiter
}

# Command Format:
#   print_commit [name of repo as string] [path to local repo]
#
# Sources Used:
#   https://stackoverflow.com/a/7737071/6621292
#   https://stackoverflow.com/a/7737071/6621292
#
function print_commit() {
  print_delimiter

  cd $2
  printf "Currently in repository '%s': %s\n\n" "$1" "$(pwd)"
  printf "Repository is currently at COMMIT ID: %s.\n\n" "$(git rev-parse HEAD)"

  git --no-pager log --pretty=oneline -n1

  print_delimiter
}

# Move ESP-IDF and its submodules to correct commit ID, then
# show commit ID of OpenThread submodule.
#
change_repo_commit "ESP-IDF" $ESP_IDF_LOC $ESP_IDF_COMMIT
print_commit "OpenThread" $OPENTHREAD_LOC

change_repo_commit "Border Router" $BORDER_ROUTER_LOC $BORDER_ROUTER_COMMIT
change_repo_commit "SED" $SED_LOC $SEDS_COMMIT_ID

change_repo_commit "Front Door" $FRONT_DOOR_LOC $FRONT_DOOR_COMMIT
change_repo_commit "Window" $WINDOW_LOC $WINDOW_COMMIT
change_repo_commit "Air Quality" $AIR_QUALITY_LOC $AIR_QUALITY_COMMIT