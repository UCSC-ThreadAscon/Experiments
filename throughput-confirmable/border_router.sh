# Command Line Format:
#
#   ./border_router.sh [USB Modem port number of border router]
#
# Command line format:
#   sdkconfig_set [sdkconfig variable] [value] [sdkconfig path]
#
# Example:
#   sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE 0 ./sdkconfig
#

# https://unix.stackexchange.com/questions/159367/using-sed-to-find-and-replace
# https://stackoverflow.com/a/57766728/6621292
#
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

# https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script#flags
while getopts t:e:p: arg
do
  case "${arg}" in
    t) tx_power=${OPTARG};;
    e) cipher_num=${OPTARG};;
    p) border_router_port=${OPTARG};;
  esac
done

# ---- Create the Output File ----
cipher_string=$(to_cipher_string $cipher_num)
txpower_string="${tx_power}dbm"

output_file_path="$HOME/Desktop/Repositories/Experiments/throughput-confirmable/queue/tp-con-BR-$cipher_string-$txpower_string.txt"
rm -f $output_file_path
date | tee $output_file_path

set_commit_ids_exec=$HOME/Desktop/Repositories/Experiments/throughput-confirmable/set_commit_ids.sh
$set_commit_ids_exec -s | tee -a $output_file_path
# --------------------------------

. $HOME/esp/esp-idf/export.sh

# ---- Build the RCP ----
echo "--------------------------------------------------------------------------------" | tee -a $output_file_path
echo "Please connect the USB-C cable to the ESP32-H2 SoC of the border router." | tee -a $output_file_path
echo "After doing so, press ENTER to continue." | tee -a $output_file_path
echo "--------------------------------------------------------------------------------" | tee -a $output_file_path
read
# kasa --alias "CoAP Server" on | tee -a $output_file_path

rcp_path="$IDF_PATH/examples/openthread/ot_rcp"
rcp_sdkconfig=$rcp_path/sdkconfig

sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE $cipher_num $rcp_sdkconfig

rcp_cipher_suite_kconfig=$(sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE $rcp_sdkconfig)
rcp_cipher_num=$(echo $rcp_cipher_suite_kconfig | tail -c 2)
rcp_cipher_string=$(to_cipher_string $rcp_cipher_num)

echo "-------RCP KConfig Variables-----------" | tee -a $output_file_path
echo $(sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE $rcp_sdkconfig) | tee -a $output_file_path
echo "The RCP will run OpenThread using the following encryption algorithm: $rcp_cipher_string." | tee -a $output_file_path
echo "---------------------------------------" | tee -a $output_file_path

cd $rcp_path
idf.py fullclean
idf.py build flash --port $border_router_port | tee -a $output_file_path

# kasa --alias "CoAP Server" off | tee -a $output_file_path
cd -
# -----------------------

# ---- Build & Flash the Border Router ----
echo "--------------------------------------------------------------------------------" | tee -a $output_file_path
echo "Please connect the USB-C cable to the ESP32-S3 SoC of the border router." | tee -a $output_file_path
echo "After doing so, press ENTER to continue." | tee -a $output_file_path
echo "--------------------------------------------------------------------------------" | tee -a $output_file_path
read

border_router_path=$HOME/Desktop/Repositories/br_netperf/examples/basic_thread_border_router
border_router_sdkconfig=$border_router_path/sdkconfig
tp_con_experiment_flag=1

# Make sure RCP Auto Update is NOT ENABLED on the Thread Border Router.
rcp_auto_update_string=$(cat $border_router_sdkconfig | grep CONFIG_AUTO_UPDATE_RCP)
echo $rcp_auto_update_string
if [[ "$rcp_auto_update_string" == "# CONFIG_AUTO_UPDATE_RCP is not set" ]]
then
  echo "ERROR: RCP Auto Update is ENABLED on the Border Router." | tee -a $output_file_path
  echo "Please turn the RCP Auto Update Feature off." | tee -a $output_file_path
  echo "$(cat $border_router_path/sdkconfig | grep CONFIG_AUTO_UPDATE_RCP)" | tee -a $output_file_path
  exit 1
fi

sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE $cipher_num $border_router_sdkconfig
sdkconfig_set CONFIG_TX_POWER $tx_power $border_router_sdkconfig
sdkconfig_set CONFIG_EXPERIMENT $tp_con_experiment_flag $border_router_sdkconfig

echo "-------Border Router KConfig Variables-----------" | tee -a $output_file_path
echo $(sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE $border_router_sdkconfig) | tee -a $output_file_path
echo $(sdkconfig_get CONFIG_TX_POWER $border_router_sdkconfig) | tee -a $output_file_path
echo $(sdkconfig_get CONFIG_EXPERIMENT $border_router_sdkconfig) | tee -a $output_file_path
echo $(sdkconfig_get CONFIG_AUTO_UPDATE_RCP $border_router_sdkconfig) | tee -a $output_file_path
echo $(sdkconfig_get CONFIG_RCP_SRC_DIR $border_router_sdkconfig) | tee -a $output_file_path
echo "-------------------------------------------------" | tee -a $output_file_path

cd $border_router_path
idf.py fullclean
idf.py build flash monitor --port $border_router_port | tee -a $output_file_path

cd -
# -----------------------------------------