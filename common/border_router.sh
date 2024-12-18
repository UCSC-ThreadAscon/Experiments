# RESOURCES UTILIZED:
# https://stackoverflow.com/questions/692000/how-do-i-write-standard-error-to-a-file-while-using-tee-with-a-pipe/692009#692009
# https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script#flags
# https://unix.stackexchange.com/questions/159367/using-sed-to-find-and-replace
# https://stackoverflow.com/a/57766728/6621292
# https://askubuntu.com/a/420983

# Command line format:
#   sdkconfig_set [sdkconfig variable] [value] [sdkconfig path]
#
# Example:
#   sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE 0 ./sdkconfig
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

function get_exp_prefix() {
  case $1 in 
  1) echo "tp-con" ;;
  3) echo "tp-udp" ;;
}

while getopts t:e:p:x: arg
do
  case "${arg}" in
    t) tx_power=${OPTARG};;
    e) cipher_num=${OPTARG};;
    p) border_router_port=${OPTARG};;
    x) experiment_num=${OPTARG};;
  esac
done

# ---- Create the Output File ----
cipher_string=$(to_cipher_string $cipher_num)
txpower_string="${tx_power}dbm"

output_file_path="$HOME/Desktop/Repositories/Experiments/throughput-confirmable/queue/$get_exp_prefix-BR-$cipher_string-$txpower_string.txt"
rm -f $output_file_path
date |& tee $output_file_path

set_commit_ids_exec=$HOME/Desktop/Repositories/Experiments/common/set_commit_ids.sh
$set_commit_ids_exec -b |& tee -a $output_file_path
# --------------------------------

source $HOME/esp/esp-idf/export.sh &>> $output_file_path

# ---- Build & Flash the Border Router ----
border_router_path=$HOME/Desktop/Repositories/br_netperf/examples/basic_thread_border_router
border_router_sdkconfig=$border_router_path/sdkconfig

# Make sure RCP Auto Update is ENABLED on the Thread Border Router.
rcp_auto_update_flag=$(cat $border_router_sdkconfig | grep CONFIG_AUTO_UPDATE_RCP)
if [[ "$rcp_auto_update_flag" != "CONFIG_AUTO_UPDATE_RCP=y" ]]
then
  echo "ERROR: RCP Auto Update is NOT ENABLED on the Border Router." |& tee -a $output_file_path
  echo "Please turn the RCP Auto Update Feature ON." |& tee -a $output_file_path
  echo "$(cat $border_router_path/sdkconfig | grep CONFIG_AUTO_UPDATE_RCP)" |& tee -a $output_file_path
  exit 1
fi

sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE $cipher_num $border_router_sdkconfig
sdkconfig_set CONFIG_TX_POWER $tx_power $border_router_sdkconfig
sdkconfig_set CONFIG_EXPERIMENT $experiment_num $border_router_sdkconfig

echo "-------Border Router KConfig Variables-----------" |& tee -a $output_file_path
echo $(sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE $border_router_sdkconfig) |& tee -a $output_file_path
echo $(sdkconfig_get CONFIG_TX_POWER $border_router_sdkconfig) |& tee -a $output_file_path
echo $(sdkconfig_get CONFIG_EXPERIMENT $border_router_sdkconfig) |& tee -a $output_file_path
echo $(cat $border_router_sdkconfig | grep CONFIG_AUTO_UPDATE_RCP) |& tee -a $output_file_path
echo $(sdkconfig_get CONFIG_RCP_SRC_DIR $border_router_sdkconfig) |& tee -a $output_file_path
echo "-------------------------------------------------" |& tee -a $output_file_path

cd $border_router_path
idf.py fullclean |& tee -a $output_file_path
idf.py build flash --port $border_router_port |& tee -a $output_file_path

cd -
# -----------------------------------------