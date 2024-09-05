# The commit ID that will be used in all Delay experiments.
ESP_IDF_COMMIT=f1c0e745a545d100a1a24f5dd17fc8eb7eec44d2

# This commit ID is shared by both the Network Performance FTD and the Delay Server,
# as they are both local copies of the same repository.
DRIVER_CODE_FTD_COMMIT=36e3bf094bf7d0d0f2b4fd09b8153c69c41a8309

# The location of each of the repositories.
ESP_IDF_LOC=${HOME}/esp/esp-idf
OPENTHREAD_LOC=${HOME}/esp/esp-idf/components/openthread/openthread
NET_PERF_FTD_LOC=$HOME/Desktop/Repositories/network-performance-ftd
DELAY_SERVER_LOC=$HOME/Desktop/Repositories/delay-server

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

# https://www.atatus.com/blog/bash-scripting/
setup_client=false
setup_server=false
while getopts "cs" flag; do
  case $flag in
    c)
      echo "Setting the Commit IDs for the DELAY CLIENT."
      setup_client=true
      ;;
    s)
      echo "Setting the Commit IDs for the DELAY SERVER."
      setup_server=true
      ;;
    \?)
      "Flag -${flag} is in invalid option."
      exit 1
  esac
done

# Move ESP-IDF and its submodules to correct commit ID, then
# show commit ID of OpenThread submodule.
#
change_repo_commit "ESP-IDF" $ESP_IDF_LOC $ESP_IDF_COMMIT
print_commit "OpenThread" $OPENTHREAD_LOC

if $setup_client;
then
  change_repo_commit "Network Performance FTD" $NET_PERF_FTD_LOC $DRIVER_CODE_FTD_COMMIT
fi

if $setup_server;
then
  change_repo_commit "Delay Server" $DELAY_SERVER_LOC $DRIVER_CODE_FTD_COMMIT
fi