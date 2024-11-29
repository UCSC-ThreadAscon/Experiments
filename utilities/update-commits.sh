# RESOURCES UTILIZED:
# https://unix.stackexchange.com/a/159369/635993
# https://stackoverflow.com/a/617188/6621292

ESP_IDF_LOC=${HOME}/esp/esp-idf
FTD_LOC=$HOME/Desktop/Repositories/network-performance-ftd
BORDER_ROUTER_LOC=$HOME/Desktop/Repositories/br_netperf/examples/basic_thread_border_router
DELAY_SERVER_LOC=$HOME/Desktop/Repositories/delay-server
DELAY_CLIENT_LOC=$HOME/Desktop/Repositories/delay-client

SET_COMMIT_IDS_SCRIPT=$HOME/Desktop/Repositories/Experiments/common/set_commit_ids.sh

function print_delimiter() {
  echo "-----------------------------------------------------------------------------------------"
}
# Command Line Format:
#   update_commit [branch] [path to repository] [variable in `set_commit_ids.sh`]
#
function update_commit() {
  print_delimiter
  cd $2
  printf "Currently at repository: %s.\n" "$(pwd)"

  new_commit=$(git rev-parse HEAD)
  printf "New commit is at %s.\n" $new_commit

  current_commit_string=$(cat $SET_COMMIT_IDS_SCRIPT | grep $3=)
  new_commit_string="$3=$new_commit"
  sed -i -e "s/$current_commit_string/$new_commit_string/g" $SET_COMMIT_IDS_SCRIPT

  printf "The commit is now set to be at $(cat $SET_COMMIT_IDS_SCRIPT | grep $3)."
  print_delimiter
}

bash ./update.sh

update_commit "main" $ESP_IDF_LOC ESP_IDF_COMMIT
