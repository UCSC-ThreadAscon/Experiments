# RESOURCES UTILIZED:
# https://stackoverflow.com/questions/692000/how-do-i-write-standard-error-to-a-file-while-using-tee-with-a-pipe/692009#692009
# https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script#flags
# https://unix.stackexchange.com/questions/159367/using-sed-to-find-and-replace
# https://stackoverflow.com/a/57766728/6621292

while getopts t:e:p: arg
do
  case "${arg}" in
    t) tx_power=${OPTARG};;
    e) cipher_num=${OPTARG};;
    p) delay_client_port=${OPTARG};;
  esac
done

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

cipher_string=$(to_cipher_string $cipher_num)
txpower_string="${tx_power}dbm"

output_file_path="$HOME/Desktop/Repositories/Experiments/delay/queue/delay-client-$cipher_string-$txpower_string.txt"
rm -f $output_file_path

date |& tee $output_file_path

# The `set_commit_ids.sh` script needs to run first BEFORE making any edits to the SDKCONFIGS,
# as the script does a `git restore` on ESP-IDF, OpenThread, and the Delay client and server source code.
#
set_commit_ids_exec=$HOME/Desktop/Repositories/Experiments/common/set_commit_ids.sh
$set_commit_ids_exec -f |& tee -a $output_file_path

delay_client_path="$HOME/Desktop/Repositories/network-performance-ftd"
delay_client_sdkconfig=$delay_client_path/sdkconfig

# The value of `CONFIG_EXPERIMENT=4` will set the device to run as
# the Delay server.
#
delay_client_flag=4
sdkconfig_set CONFIG_EXPERIMENT $delay_client_flag $delay_client_sdkconfig

# Make sure Time Synchronization is on.
time_sync_off="# CONFIG_OPENTHREAD_TIME_SYNC is not set"
time_sync_on="CONFIG_OPENTHREAD_TIME_SYNC=y"

sed -i "" "s/$time_sync_off/$time_sync_on/g" $delay_client_sdkconfig

# Change both the cipher suite and TX power settings in `sdkconfig`.
#
sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE $cipher_num $delay_client_sdkconfig
sdkconfig_set CONFIG_TX_POWER $tx_power $delay_client_sdkconfig

. $HOME/esp/esp-idf/export.sh
cd $delay_client_path

echo $(sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE $delay_client_sdkconfig) |& tee -a $output_file_path
echo $(sdkconfig_get CONFIG_TX_POWER $delay_client_sdkconfig) |& tee -a $output_file_path
echo $(sdkconfig_get CONFIG_EXPERIMENT $delay_client_sdkconfig) |& tee -a $output_file_path
echo $(sdkconfig_get CONFIG_OPENTHREAD_TIME_SYNC $delay_client_sdkconfig) |& tee -a $output_file_path

idf.py fullclean
idf.py build flash monitor --port $delay_client_port |& tee -a $output_file_path

cd -