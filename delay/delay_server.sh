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



. $HOME/esp/esp-idf/export.sh > /dev/null