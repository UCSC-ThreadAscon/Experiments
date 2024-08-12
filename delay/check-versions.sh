# The commit IDs that will be used in all Delay experiments.
ESP_IDF_COMMIT=6377abb842705a5aa8feb00ef1996f236f64b5dd
OPENTHREAD_COMMIT=a011df52f209726bf9b9dc5ae123ec53bceafe7e
NET_PERF_FTD_COMMIT=f2d86f5210284c8cd54e3315bafb197513c18ab9

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

function esp_idf_check() {
  start_delimiter
  printf "\nGoing to ESP-IDF Local Repository.\n"

  cd $ESP_IDF_LOC
  git restore .
  esp_idf_local=$(git rev-parse HEAD)

  if [ $esp_idf_local = $ESP_IDF_COMMIT ]
  then
    printf "\nESP-IDF is using Commit ID: %s.\n" $esp_idf_local
    show_last_commit
    end_delimiter
  else
    printf "\nESP-IDF Commit ID to use in Experiments: %s.\n" $ESP_IDF_COMMIT
    printf "\nESP-IDF Local Commit ID: %s.\n" $esp_idf_local
    printf "\nThere is a Commit ID mismatch.\n"
    end_delimiter
    exit 1
  fi
}

function openthread_check() {
  start_delimiter
  printf "\nGoing to OpenThread Local Repository.\n"

  cd $OPENTHREAD_LOC
  git restore .
  openthread_local=$(git rev-parse HEAD)

  if [ $openthread_local = $OPENTHREAD_COMMIT ]
  then
    printf "\nOpenThread is using Commit ID: %s.\n" $openthread_local
    show_last_commit
    end_delimiter
  else
    printf "\nOpenThread Commit ID to use in Experiments: %s.\n" $OPENTHREAD_COMMIT
    printf "\nOpenThread Local Commit ID: %s.\n" $openthread_local
    printf "\nThere is a Commit ID mismatch.\n"
    end_delimiter
    printf "\n"
    exit 1
  fi
}

esp_idf_check
openthread_check