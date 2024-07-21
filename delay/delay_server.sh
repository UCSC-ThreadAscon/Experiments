# Command line format:
#   sdkconfig_set [sdkconfig variable] [value] [sdkconfig path]
#
# Example:
#   sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE 0 ./sdkconfig
#
function sdkconfig_set() {
  to_replace=$(cat $3 | grep $1)
  sed -i "" "s/$to_replace/$1=$2/g" $3
}

# Command line format:
#   sdkconfig_get [sdkconfig variable] [sdkconfig path]
#
# Example:
#   sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE ./sdkconfig
#
function sdkconfig_get() {
  cat $2 | grep $1
}

# Get the TX Power and Encryption Algorithm to use from the command line arguments.
#
# The Bash script code that uses `optarg` to get the command line arguments
# comes from:
# https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script#flags
#
while getopts t:e arg
do
  case "${arg}" in
    t) TX_POWER=${OPTARG};;
    e) CIPHER_NUM=${OPTARG};;
  esac
done

delay_server_path="$HOME/Desktop/Repositories/network-performance-ftd"

sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE CIPHER_NUM $delay_server_path/sdkconfig
sdkconfig_set CONFIG_TX_POWER TX_POWER $delay_server_path/sdkconfig

echo $(sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE $delay_server_path/sdkconfig)
echo $(sdkconfig_get CONFIG_TX_POWER $delay_server_path/sdkconfig)

. $HOME/esp/esp-idf/export.sh > /dev/null