# Get the TX Power and Encryption Algorithm to use from the command line arguments.
#
# The Bash script code that uses `optarg` to get the command line arguments
# comes from:
# https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script#flags
#
while getopts t:e:s arg
do
  case "${arg}" in
    t) TX_POWER=${OPTARG};;
    e) ENCRYPTION_ALGORITHM=${OPTARG};;
    s) DELAY_SERVER_PORT=${OPTARG};;
  esac
done