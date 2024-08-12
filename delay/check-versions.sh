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

function start_delimiter() {
  printf -- "-----------------------------------"
}

function end_delimiter() {
  printf -- "-----------------------------------\n"
}

function show_last_commit() {
  git --no-pager log -n1
}

# $1 => "ESP-IDF"
# $2 => ESP_IDF_LOC
# $3 => ESP_IDF_COMMIT

# Command Format:
#   commit_id_check [name of repo as string] [path to local repo] [expected experiment commit id]
#
#   [name of repo as string] =          $1
#   [path to local repo] =              $2
#   [expected experiment commit id] =   $3
#
# Example:
#   commit_id_check "ESP-IDF" $ESP_IDF_LOC $ESP_IDF_COMMIT
#
function commit_id_check() {
  start_delimiter

  cd $2
  git restore .
  local_commit=$(git rev-parse HEAD)

  if [ $local_commit = $3 ]
  then
    printf "\n%s is using Commit ID: %s.\n\n" "$1" $local_commit
    show_last_commit
    end_delimiter
  else
    printf "\n%s Commit ID to use in Experiments: %s.\n" "$1" $3
    printf "\n%s Local Commit ID: %s.\n" "$1" $local_commit
    printf "\nThere is a Commit ID mismatch.\n"
    end_delimiter
    exit 1
  fi
}

commit_id_check "ESP-IDF" $ESP_IDF_LOC $ESP_IDF_COMMIT
commit_id_check "OpenThread" $OPENTHREAD_LOC $OPENTHREAD_COMMIT

commit_id_check "Network Performance FTD" $NET_PERF_FTD_LOC $DRIVER_CODE_FTD_COMMIT
commit_id_check "Delay Server" $DELAY_SERVER_LOC $DRIVER_CODE_FTD_COMMIT