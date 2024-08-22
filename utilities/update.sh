ESP_IDF_LOC=${HOME}/esp/esp-idf
OPENTHREAD_LOC=${HOME}/esp/esp-idf/components/openthread/openthread

DELAY_SERVER_LOC=$HOME/Desktop/Repositories/delay-server

NET_PERF_FTD_LOC=$HOME/Desktop/Repositories/network-performance-ftd
NET_PERF_BORDER_ROUTER_LOC=$HOME/Desktop/Repositories/br_netperf

ENERGY_SED_LOC=$HOME/Desktop/Repositories/energy-usage-sed-simple
ENERGY_BORDER_ROUTER_LOC=$HOME/Desktop/Repositories/br_energy

function print_delimiter() {
  echo "-----------------------------------------------------------------------------------------"
}

# Command Line Format:
#   update_repo [branch] [path to repository]
#
# Sources Used:
#   https://stackoverflow.com/a/61751340/6621292
#   https://stackoverflow.com/a/7737071/6621292
#
function update_repo() {
  print_delimiter
  cd $2
  printf "Currently at repository: %s\n" "$(pwd)"

  git restore . --recurse-submodules
  echo "Removing ALL unstaged changes with GIT RESTORE (--recursed-submodules)."

  git checkout --recurse-submodules $1
  git pull

  git --no-pager log --pretty=oneline -n1
  print_delimiter
}

date

update_repo "main" $OPENTHREAD_LOC
update_repo "experiment" $OPENTHREAD_LOC
update_repo "master" $ESP_IDF_LOC

update_repo "main" $DELAY_SERVER_LOC

update_repo "main" $NET_PERF_FTD_LOC
update_repo "main" $NET_PERF_BORDER_ROUTER_LOC

update_repo "main" $ENERGY_SED_LOC
update_repo "air-quality" $ENERGY_SED_LOC
update_repo "back-door" $ENERGY_SED_LOC
update_repo "front-door" $ENERGY_SED_LOC
update_repo "main" $ENERGY_BORDER_ROUTER_LOC