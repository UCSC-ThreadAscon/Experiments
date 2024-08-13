# The commit IDs that will be used in all Delay experiments.
ESP_IDF_COMMIT=6377abb842705a5aa8feb00ef1996f236f64b5dd
OPENTHREAD_COMMIT=a011df52f209726bf9b9dc5ae123ec53bceafe7e

# This commit ID is shared by both the Network Performance FTD and the Delay Server,
# as they are both local copies of the same repository.
DRIVER_CODE_FTD_COMMIT=f2d86f5210284c8cd54e3315bafb197513c18ab9

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
function change_repo_commit() {
  print_delimiter

  # Go to the local Git repository.
  cd $2
  printf "Currently in repository: %s\n\n" "$(pwd)"

  # Clean the repo of all unstaged changes.
  git restore .
  echo "Did a GIT RESTORE to clear all unstaged changes."

  printf "\nCommit BEFORE Checkout: %s.\n" "$(git rev-parse HEAD)"

  # Change repo to the version that we want to use in the experiments.
  # https://stackoverflow.com/a/45652159/6621292
  git -c advice.detachedHead=false checkout $3

  # Prove that the repository is at the correct commit ID,
  # and that no unstaged changes have been made to the repository.
  #
  printf "Repository is now at EXPERIMENT COMMIT ID: %s.\n\n" "$(git rev-parse HEAD)"

  git status
  printf "\n"

  # https://stackoverflow.com/a/7737071/6621292
  git --no-pager log --pretty=oneline -n1
  print_delimiter
}

# Update OpenThread first, as it's a submodule of ESP-IDF
change_repo_commit "OpenThread" $OPENTHREAD_LOC $OPENTHREAD_COMMIT
change_repo_commit "ESP-IDF" $ESP_IDF_LOC $ESP_IDF_COMMIT

change_repo_commit "Network Performance FTD" $NET_PERF_FTD_LOC $DRIVER_CODE_FTD_COMMIT
change_repo_commit "Delay Server" $DELAY_SERVER_LOC $DRIVER_CODE_FTD_COMMIT