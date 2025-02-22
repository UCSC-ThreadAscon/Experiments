# RESOURCES UTILIZED:
# https://stackoverflow.com/questions/692000/how-do-i-write-standard-error-to-a-file-while-using-tee-with-a-pipe/692009#692009
# https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script#flags
# https://unix.stackexchange.com/questions/159367/using-sed-to-find-and-replace
# https://stackoverflow.com/a/57766728/6621292
# https://askubuntu.com/a/420983
# https://ryanstutorials.net/bash-scripting-tutorial/bash-if-statements.php#ifelif
# https://stackoverflow.com/a/18856472/6621292
# https://stackoverflow.com/a/525612/6621292

function sdkconfig_set() {
  to_replace=$(cat $3 | grep $1=)
  sed -i -e "s/$to_replace/$1=$2/g" $3
}

# Command line format:
#   sdkconfig_get [sdkconfig variable] [sdkconfig path]
#
# Example:
#   sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE ./sdkconfig
#
function sdkconfig_get() {
  cat $2 | grep $1=
}

function to_cipher_string() {
  case $1 in
    0) echo "AES" ;;
    1) echo "NoEncrypt" ;;
    2) echo "Ascon128a-esp32" ;;
    3) echo "Ascon128a-ref" ;;
    4) echo "LibAscon-128a" ;;
    5) echo "LibAscon-128" ;;
  esac
}

while getopts t:e:p:x: arg
do
  case "${arg}" in
    t) tx_power=${OPTARG};;
    e) cipher_num=${OPTARG};;
    p) ftd_port=${OPTARG};;
    x) experiment_num=${OPTARG};;
  esac
done

# ---- Create the Output File ----
cipher_string=$(to_cipher_string $cipher_num)
txpower_string="${tx_power}dbm"

if [ $experiment_num == 1 ]
then
  output_file_path="$HOME/Desktop/Repositories/Experiments/throughput-confirmable/queue/tp-con-FTD-$cipher_string-$txpower_string.txt"
elif [ $experiment_num == 2 ]
then
  output_file_path="$HOME/Desktop/Repositories/Experiments/packet-loss-confirmable/queue/pl-con-FTD-$cipher_string-$txpower_string.txt"
elif [ $experiment_num == 3 ]
then
  output_file_path="$HOME/Desktop/Repositories/Experiments/delay/queue/delay-server-$cipher_string-$txpower_string.txt"
elif [ $experiment_num == 4 ]
then
  output_file_path="$HOME/Desktop/Repositories/Experiments/delay/queue/delay-FTD-$cipher_string-$txpower_string.txt"
elif [ $experiment_num == 5 ]
then
  output_file_path="$HOME/Desktop/Repositories/Experiments/throughput-observe/queue/tp-observe-FTD-$cipher_string-$txpower_string.txt"
elif [ $experiment_num == 6 ]
then
  output_file_path="$HOME/Desktop/Repositories/Experiments/packet-loss-observe/queue/pl-observe-FTD-$cipher_string-$txpower_string.txt"
fi

rm -f $output_file_path
date |& tee $output_file_path

set_commit_ids_exec=$HOME/Desktop/Repositories/Experiments/common/set_commit_ids.sh

if [ $experiment_num == 3 ]
then
  $set_commit_ids_exec -s |& tee -a $output_file_path
  ftd_path="$HOME/Desktop/Repositories/delay-server"
elif [ $experiment_num == 4 ]
then
  $set_commit_ids_exec -c |& tee -a $output_file_path
  ftd_path="$HOME/Desktop/Repositories/delay-client"
else
  $set_commit_ids_exec -f |& tee -a $output_file_path
  ftd_path="$HOME/Desktop/Repositories/network-performance-ftd"
fi
# --------------------------------

# ---- Set the KConfig variables ----
ftd_sdkconfig=$ftd_path/sdkconfig

sdkconfig_set CONFIG_EXPERIMENT $experiment_num $ftd_sdkconfig

# Change both the cipher suite and TX power settings in `sdkconfig`.
sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE $cipher_num $ftd_sdkconfig
sdkconfig_set CONFIG_TX_POWER $tx_power $ftd_sdkconfig

time_sync_not_set="# CONFIG_OPENTHREAD_TIME_SYNC is not set"
time_sync_set="CONFIG_OPENTHREAD_TIME_SYNC=1"
if [ $experiment_num == 3 ] || [ $experiment_num == 4 ]
then
  sed -i -e "s/$time_sync_not_set/$time_sync_set/g" $ftd_sdkconfig
else
  sed -i -e "s/$time_sync_set/$time_sync_not_set/g" $ftd_sdkconfig
fi

# Make sure USB/Serial JTAG monitoring is ENABLED on the FTD.
usb_serial_monitor_flag=$(cat $ftd_sdkconfig | grep 'CONFIG_ESP_CONSOLE_USB_SERIAL_JTAG=')
if [[ "$usb_serial_monitor_flag" != "CONFIG_ESP_CONSOLE_USB_SERIAL_JTAG=y" ]]
then
  echo "ERROR: USB Serial/JTAG monitoring is NOT ENABLED on the FTD." |& tee -a $output_file_path
  echo "Please turn the USB Serial/JTAG monitoring flag ON." |& tee -a $output_file_path
  echo "$(cat $ftd_sdkconfig | grep 'CONFIG_ESP_CONSOLE_USB_SERIAL_JTAG=')" |& tee -a $output_file_path
  exit 1
fi
# -----------------------------------

# ---- Build, Flash, & Monitor ----
cd $ftd_path

echo "--------- FTD KConfig Variables ---------" |& tee -a $output_file_path
echo $(sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE $ftd_sdkconfig) |& tee -a $output_file_path
echo $(sdkconfig_get CONFIG_TX_POWER $ftd_sdkconfig) |& tee -a $output_file_path
echo $(sdkconfig_get CONFIG_EXPERIMENT $ftd_sdkconfig) |& tee -a $output_file_path
echo $(cat sdkconfig | grep CONFIG_OPENTHREAD_TIME_SYNC) |& tee -a $output_file_path
echo $(sdkconfig_get CONFIG_OPENTHREAD_MAC_DEFAULT_MAX_FRAME_RETRIES_DIRECT $ftd_sdkconfig) |& tee -a $output_file_path
echo "-----------------------------------------" |& tee -a $output_file_path

source $HOME/esp/esp-idf/export.sh &>> $output_file_path

idf.py fullclean |& tee -a $output_file_path
idf.py build flash --port $ftd_port |& tee -a $output_file_path

cd -
# ---------------------------------