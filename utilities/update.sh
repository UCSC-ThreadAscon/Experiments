ESP_IDF_LOC=${HOME}/esp/esp-idf
OPENTHREAD_LOC=${HOME}/esp/esp-idf/components/openthread/openthread

DELAY_SERVER_LOC=$HOME/Desktop/Repositories/delay-server
DELAY_CLIENT_LOC=$HOME/Desktop/Repositories/delay-client

NET_PERF_FTD_LOC=$HOME/Desktop/Repositories/network-performance-ftd
NET_PERF_BORDER_ROUTER_LOC=$HOME/Desktop/Repositories/br_netperf

ENERGY_SED_LOC=$HOME/Desktop/Repositories/energy-usage-sed-simple
ENERGY_BORDER_ROUTER_LOC=$HOME/Desktop/Repositories/br_energy

EXPERIMENTS_LOC=$HOME/Desktop/Repositories/Experiments
GRAPHS_LOC=$HOME/Desktop/Repositories/graphs

function print_delimiter() {
  echo "-----------------------------------------------------------------------------------------"
}

# Command Line Format:
#   update_repo [branch] [path to repository]
#
# Sources Utilized:
#   https://stackoverflow.com/a/61751340/6621292
#   https://stackoverflow.com/a/7737071/6621292
#
function update_repo() {
  print_delimiter
  cd $2
  printf "Currently at repository: %s\n" "$(pwd)"

  git restore . --recurse-submodules
  echo "Removing ALL unstaged changes with GIT RESTORE (--recursed-submodules)."

  git clean -f
  echo "Did a GIT CLEAN to remove all untracked files."

  git checkout --recurse-submodules $1
  git pull

  git restore . --recurse-submodules
  echo "Doing a GIT RESTORE (--recursed-submodules) to make sure that the submodules (if any) are at the correct commits."

  git --no-pager log --pretty=oneline -n1

  print_delimiter
}

# Command Line Format:
#   update_repo [branch] [main branch]
#
# Sources Utilized:
#   https://stackoverflow.com/a/62797361/6621292
#
function merge_with_main() {
  print_delimiter

  git checkout --recurse-submodules $2
  git pull
  git checkout --recurse-submodules $1

  echo "Merging branch $1 with $2".
  git merge $2 --commit --no-edit
  git push

  print_delimiter
}

date

update_repo "main" $OPENTHREAD_LOC
update_repo "experiment" $OPENTHREAD_LOC
update_repo "master" $ESP_IDF_LOC

update_repo "main" $NET_PERF_BORDER_ROUTER_LOC
update_repo "main" $ENERGY_BORDER_ROUTER_LOC
update_repo "main" $EXPERIMENTS_LOC
update_repo "main" $GRAPHS_LOC

update_repo "main" $NET_PERF_FTD_LOC

update_repo "delay-server" $DELAY_SERVER_LOC
merge_with_main "delay-server" "main" $DELAY_SERVER_LOC

update_repo "delay-client" $DELAY_CLIENT_LOC
merge_with_main "delay-client" "main" $DELAY_CLIENT_LOC

update_repo "main" $ENERGY_SED_LOC

update_repo "air-quality" $ENERGY_SED_LOC
merge_with_main "air-quality" "main" $ENERGY_SED_LOC

update_repo "back-door" $ENERGY_SED_LOC
merge_with_main "back-door" "main" $ENERGY_SED_LOC

update_repo "front-door" $ENERGY_SED_LOC
merge_with_main "front-door" "main" $ENERGY_SED_LOC