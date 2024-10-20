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
    p) ftd_port=${OPTARG};;
  esac
done

# ---- Create the Output File ----
cipher_string=$(to_cipher_string $cipher_num)
txpower_string="${tx_power}dbm"

output_file_path="$HOME/Desktop/Repositories/Experiments/throughput-confirmable/queue/tp-con-FTD-$cipher_string-$txpower_string.txt"
rm -f $output_file_path
date | tee $output_file_path

set_commit_ids_exec=$HOME/Desktop/Repositories/Experiments/throughput-confirmable/set_commit_ids.sh
$set_commit_ids_exec -c | tee -a $output_file_path
# --------------------------------

. $HOME/esp/esp-idf/export.sh

# ---- Set the KConfig variables ----
ftd_path="$HOME/Desktop/Repositories/network-performance-ftd"
ftd_sdkconfig=$ftd_path/sdkconfig

# `CONFIG_EXPERIMENT=1` sets the FTD to run the throughput confirmable experiment.
tp_con_client_flag=1
sdkconfig_set CONFIG_EXPERIMENT $tp_con_client_flag $ftd_sdkconfig

# Change both the cipher suite and TX power settings in `sdkconfig`.
sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE $cipher_num $ftd_sdkconfig
sdkconfig_set CONFIG_TX_POWER $tx_power $ftd_sdkconfig
# -----------------------------------

# ---- Build, Flash, & Monitor ----
cd $ftd_path

echo "--------- FTD KConfig Variables ---------"
echo $(sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE $ftd_sdkconfig) | tee -a $output_file_path
echo $(sdkconfig_get CONFIG_TX_POWER $ftd_sdkconfig) | tee -a $output_file_path
echo $(sdkconfig_get CONFIG_EXPERIMENT $ftd_sdkconfig) | tee -a $output_file_path
echo "-----------------------------------------"

idf.py fullclean
idf.py build flash monitor --port $ftd_port | tee -a $output_file_path

cd -
# ---------------------------------