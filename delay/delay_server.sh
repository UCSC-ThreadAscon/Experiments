# Command line format:
#   sdkconfig_set [sdkconfig variable] [value] [sdkconfig path]
#
# Example:
#   sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE 0 ./sdkconfig
#
function sdkconfig_set() {
  to_replace=$(cat $3 | grep $1=)
  sed -i "" "s/$to_replace/$1=$2/g" $3
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

# Get the TX Power and Encryption Algorithm to use from the command line arguments.
#
# The Bash script code that uses `optarg` to get the command line arguments
# comes from:
# https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script#flags
#
while getopts t:e: arg
do
  case "${arg}" in
    t) tx_power=${OPTARG};;
    e) cipher_num=${OPTARG};;
  esac
done

delay_server_path="$HOME/Desktop/Repositories/network-performance-ftd"
delay_server_sdkconfig=$delay_server_path/sdkconfig

# The value of `CONFIG_EXPERIMENT=3` will set the device to run as
# the Delay server.
#
delay_server_flag=3
sdkconfig_set CONFIG_EXPERIMENT $delay_server_flag $delay_server_sdkconfig

# Change both the cipher suite and TX power settings in `sdkconfig`.
#
sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE $cipher_num $delay_server_sdkconfig
sdkconfig_set CONFIG_TX_POWER $tx_power $delay_server_sdkconfig

echo $(sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE $delay_server_sdkconfig)
echo $(sdkconfig_get CONFIG_TX_POWER $delay_server_sdkconfig)
echo $(sdkconfig_get CONFIG_EXPERIMENT $delay_server_sdkconfig)

. $HOME/esp/esp-idf/export.sh > /dev/null