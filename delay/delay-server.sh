# Get the TX Power and Encryption Algorithm to use from the command line arguments.
#
# The Bash script code that uses `optarg` to get the command line arguments
# comes from:
# https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script#flags
#
while getopts t:e:p: arg
do
  case "${arg}" in
    t) tx_power=${OPTARG};;
    e) cipher_num=${OPTARG};;
    p) delay_server_port=${OPTARG};;
  esac
done

# Command line format:
#   sdkconfig_set [sdkconfig variable] [value] [sdkconfig path]
#
# Example:
#   sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE 0 ./sdkconfig
#
# https://unix.stackexchange.com/questions/159367/using-sed-to-find-and-replace'
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

cipher_string=$(to_cipher_string $cipher_num)
txpower_string="${tx_power}dbm"

output_file_path="$HOME/Desktop/Repositories/Experiments/delay/queue/delay-server-$cipher_string-$txpower_string.txt"
rm -f $output_file_path

date | tee $output_file_path

# The `set_commit_ids.sh` script needs to run first BEFORE making any edits to the SDKCONFIGS,
# as the script does a `git restore` on ESP-IDF, OpenThread, and the Delay client and server source code.
#
set_commit_ids_exec=$HOME/Desktop/Repositories/Experiments/delay/set_commit_ids.sh
$set_commit_ids_exec -s | tee -a $output_file_path

delay_server_path="$HOME/Desktop/Repositories/delay-server"
delay_server_sdkconfig=$delay_server_path/sdkconfig

# The value of `CONFIG_EXPERIMENT=3` will set the device to run as
# the Delay server.
#
delay_server_flag=3
sdkconfig_set CONFIG_EXPERIMENT $delay_server_flag $delay_server_sdkconfig

# Make sure Time Synchronization is on.
time_sync_off="# CONFIG_OPENTHREAD_TIME_SYNC is not set"
time_sync_on="CONFIG_OPENTHREAD_TIME_SYNC=y"

# https://stackoverflow.com/a/57766728/6621292
sed -i -e "s/$time_sync_off/$time_sync_on/g" $delay_server_sdkconfig

# Change both the cipher suite and TX power settings in `sdkconfig`.
#
sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE $cipher_num $delay_server_sdkconfig
sdkconfig_set CONFIG_TX_POWER $tx_power $delay_server_sdkconfig

. $HOME/esp/esp-idf/export.sh
cd $delay_server_path

echo $(sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE $delay_server_sdkconfig) | tee -a $output_file_path
echo $(sdkconfig_get CONFIG_TX_POWER $delay_server_sdkconfig) | tee -a $output_file_path
echo $(sdkconfig_get CONFIG_EXPERIMENT $delay_server_sdkconfig) | tee -a $output_file_path
echo $(sdkconfig_get CONFIG_OPENTHREAD_TIME_SYNC $delay_server_sdkconfig) | tee -a $output_file_path

idf.py fullclean
idf.py build flash monitor --port $delay_server_port | tee -a $output_file_path

cd -