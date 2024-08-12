# The commit IDs that will be used in all Delay experiments.
ESP_IDF_COMMIT=6377abb842705a5aa8feb00ef1996f236f64b5dd
OPENTHREAD_COMMIT=a011df52f209726bf9b9dc5ae123ec53bceafe7e
NET_PERF_FTD_COMMIT=f2d86f5210284c8cd54e3315bafb197513c18ab9
DELAY_SERVER_COMMIT=f2d86f5210284c8cd54e3315bafb197513c18ab9

# The location of each of the repositories.
ESP_IDF_LOC=${HOME}/esp/esp-idf

function print_delimiter() {
  printf -- "-----------------------------------"
}

function esp_idf_check() {
  print_delimiter
  printf "\nGoing to ESP-IDF Local Repository.\n"

  cd $ESP_IDF_LOC
  git restore .
  esp_idf_local=$(git rev-parse HEAD)

  if [ $esp_idf_local = $ESP_IDF_COMMIT ]
  then
    printf "\nESP-IDF is using Commit ID: %s.\n" $esp_idf_local
    print_delimiter
  else
    printf "\nESP-IDF Commit ID to use in Experiments: %s.\n" $ESP_IDF_COMMIT
    printf "\nESP-IDF Local Commit ID: %s.\n" $esp_idf_local
    printf "\nThere is a Commit ID mismatch.\n"
    print_delimiter
    exit 1
  fi
}

esp_idf_check