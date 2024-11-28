# RESOURCES UTILIZED:
# https://stackoverflow.com/questions/692000/how-do-i-write-standard-error-to-a-file-while-using-tee-with-a-pipe/692009#692009
# https://unix.stackexchange.com/questions/159367/using-sed-to-find-and-replace
# https://stackoverflow.com/a/57766728/6621292
# https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script#flags

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

while getopts t:e:p: arg
do
  case "${arg}" in
    e) cipher_num=${OPTARG};;
    p) rcp_port=${OPTARG};;
  esac
done

# ---- Create the Output File ----
cipher_string=$(to_cipher_string $cipher_num)
txpower_string="${tx_power}dbm"

output_file_path="$HOME/Desktop/Repositories/Experiments/throughput-confirmable/queue/tp-con-RCP-$cipher_string.txt"
rm -f $output_file_path
date |& tee $output_file_path

set_commit_ids_exec=$HOME/Desktop/Repositories/Experiments/throughput-confirmable/set_commit_ids.sh
$set_commit_ids_exec |& tee -a $output_file_path
# --------------------------------

source $HOME/esp/esp-idf/export.sh &>> $output_file_path

# ---- Build the RCP ----
rcp_path="$IDF_PATH/examples/openthread/ot_rcp"
rcp_sdkconfig=$rcp_path/sdkconfig

sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE $cipher_num $rcp_sdkconfig

rcp_cipher_suite_kconfig=$(sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE $rcp_sdkconfig)
rcp_cipher_num=$(echo $rcp_cipher_suite_kconfig | tail -c 2)
rcp_cipher_string=$(to_cipher_string $rcp_cipher_num)

echo "-------RCP KConfig Variables-----------" |& tee -a $output_file_path
echo $(sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE $rcp_sdkconfig) |& tee -a $output_file_path
echo "The RCP will run OpenThread using the following encryption algorithm: $rcp_cipher_string." |& tee -a $output_file_path
echo "---------------------------------------" |& tee -a $output_file_path

cd $rcp_path
idf.py fullclean
idf.py build flash --port $rcp_port |& tee -a $output_file_path
cd -
# -----------------------