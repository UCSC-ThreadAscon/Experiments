# The commit ID of the ESP-IDF repository.
ESP_IDF_COMMIT=f52856788278f3dc620d62f99f884b5577d982a7

# The commit ID of the FTD.
FTD_COMMIT=a9e62371f51087c50d81a801249a9d8276954e3f

# The commit ID of the Delay Server.
DELAY_SERVER_COMMIT=436b8d5e43c1093c88fca66e014906a6e65e1772

# The commit ID of the Delay Client.
DELAY_CLIENT_COMMIT=73f9387d87d4e2443848805cf78a3ea8c9d0401b

# The commit ID of the Border Router.
BORDER_ROUTER_COMMIT=8d0bdc89b8e7b1faffbfacf8904add02dc68d062

# The location of each of the repositories.
ESP_IDF_LOC=${HOME}/esp/esp-idf
OPENTHREAD_LOC=${HOME}/esp/esp-idf/components/openthread/openthread
FTD_LOC=$HOME/Desktop/Repositories/network-performance-ftd
BORDER_ROUTER_LOC=$HOME/Desktop/Repositories/br_netperf/examples/basic_thread_border_router
DELAY_SERVER_LOC=$HOME/Desktop/Repositories/delay-server
DELAY_CLIENT_LOC=$HOME/Desktop/Repositories/delay-client

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

setup_ftd=false
setup_border_router=false
setup_delay_server=false
setup_delay_client=false

# https://www.atatus.com/blog/bash-scripting/
while getopts "fbsc" flag; do
  case $flag in
    f)
      echo "Setting the Commit IDs for the FTD."
      setup_ftd=true
      ;;
    b)
      echo "Setting the Commit IDs for the BORDER ROUTER."
      setup_border_router=true
      ;;
    s)
      echo "Setting the Commit IDs for the DELAY SERVER."
      setup_delay_server=true
      ;;
    c) echo "Setting the Commit IDs for the DELAY CLIENT."
      setup_delay_client=true
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

if $setup_ftd;
then
  change_repo_commit "Network Performance FTD" $FTD_LOC $FTD_COMMIT
fi

if $setup_border_router;
then
  change_repo_commit "Border Router" $BORDER_ROUTER_LOC $BORDER_ROUTER_COMMIT
fi

if $setup_delay_server;
then
  change_repo_commit "Delay Server" $DELAY_SERVER_LOC $DELAY_SERVER_COMMIT
fi

if $setup_delay_client;
then
  change_repo_commit "Delay Client" $DELAY_CLIENT_LOC $DELAY_CLIENT_COMMIT
fi