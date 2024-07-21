delay_server_path="$HOME/Desktop/Repositories/network-performance-ftd"

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

# Command line format:
#   sdkconfig_set [sdkconfig variable] [value] [sdkconfig path]
#
# Example:
#   sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE 0 ./sdkconfig
#
function sdkconfig_set() {
  to_replace=$(cat sdkconfig | grep $1)
  sed -i "" "s/$to_replace/$1=$2/g" $3
}

. $HOME/esp/esp-idf/export.sh > /dev/null