# The location of each of the repositories.
ESP_IDF_LOC=${HOME}/esp/esp-idf
FTD_LOC=$HOME/Desktop/Repositories/network-performance-ftd
BORDER_ROUTER_LOC=$HOME/Desktop/Repositories/br_netperf/examples/basic_thread_border_router
DELAY_SERVER_LOC=$HOME/Desktop/Repositories/delay-server
DELAY_CLIENT_LOC=$HOME/Desktop/Repositories/delay-client

SET_COMMIT_IDS_SCRIPT=$HOME/Desktop/Repositories/Experiments/utilities/update-commits.sh

function print_delimiter() {
  echo "-----------------------------------------------------------------------------------------"
}
# Command Line Format:
#   update_commit [branch] [path to repository] [variable in `set_commit_ids.sh`]
#
# Resources Utilized:
#   https://unix.stackexchange.com/a/159369/635993
#
function update_commit() {
  print_delimiter
  cd $2
  printf "Currently at repository: %s.\n" "$(pwd)"

  new_commit=$(git rev-parse HEAD)
  printf" Current commit is at %s.\n" $current_commit

  current_commit_string=$(cat $SET_COMMIT_IDS_SCRIPT | grep $3)
  sed -i -e "s/$current_commit_string/$3=$current_commit/g" $SET_COMMIT_IDS_SCRIPT

  print_delimiter
}

bash ./update.sh

update_commit "main" $ESP_IDF_LOC "ESP_IDF_COMMIT"
