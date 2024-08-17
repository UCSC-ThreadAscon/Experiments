# The location of each of the repositories.
ESP_IDF_LOC=${HOME}/esp/esp-idf
OPENTHREAD_LOC=${HOME}/esp/esp-idf/components/openthread/openthread
NET_PERF_FTD_LOC=$HOME/Desktop/Repositories/network-performance-ftd
DELAY_SERVER_LOC=$HOME/Desktop/Repositories/delay-server

function print_delimiter() {
  echo "-----------------------------------------------------------------------------------------"
}

# Command Line Format:
#   update_repo [branch] [path to repository]
#
function update_repo() {
  print_delimiter
  cd $2
  printf "Currently at repository: %s\n" "$(pwd)"

  git restore .
  echo "Removing ALL unstaged changes with GIT RESTORE."

  git checkout --recurse-submodules $1
  git pull

  # https://stackoverflow.com/a/7737071/6621292
  git --no-pager log --pretty=oneline -n1
  print_delimiter
}

date

update_repo "main" $NET_PERF_FTD_LOC
update_repo "main" $DELAY_SERVER_LOC

update_repo "main" $OPENTHREAD_LOC
update_repo "experiment" $OPENTHREAD_LOC

update_repo "master" $ESP_IDF_LOC