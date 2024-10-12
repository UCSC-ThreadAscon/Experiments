# Command Line Format:
#
#   ./border_router.sh [USB Modem port number of border router]
#
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

# https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script#flags
while getopts t:e:p: arg
do
  case "${arg}" in
    t) tx_power=${OPTARG};;
    e) cipher_num=${OPTARG};;
    p) border_router_port=${OPTARG};;
  esac
done

. $HOME/esp/esp-idf/export.sh

# ---- Build the RCP ----
rcp_path="$IDF_PATH/examples/openthread/ot_rcp"
rcp_sdkconfig=$rcp_path/sdkconfig

sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE $cipher_num $rcp_sdkconfig

echo "-------RCP Changed KConfig Variables-----------"
echo $(sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE $rcp_sdkconfig)
echo "-----------------------------------------------"

cd $rcp_path
idf.py fullclean
idf.py build
# -----------------------

# ---- Build & Flash the Border Router ----
border_router_path=$HOME/Desktop/Repositories/br_netperf/examples/basic_thread_border_router
border_router_sdkconfig=$border_router_path/sdkconfig
tp_con_experiment_flag=1

sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE $cipher_num $border_router_sdkconfig
sdkconfig_set CONFIG_TX_POWER $tx_power $border_router_sdkconfig
sdkconfig_set CONFIG_EXPERIMENT $tp_con_experiment_flag $border_router_sdkconfig

echo "-------Border Router Changed KConfig Variables-----------"
echo $(sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE $border_router_sdkconfig)
echo $(sdkconfig_get CONFIG_TX_POWER $border_router_sdkconfig)
echo $(sdkconfig_get CONFIG_EXPERIMENT $border_router_sdkconfig)
echo "---------------------------------------------------------"

cd $border_router_path
idf.py fullclean
idf.py build flash monitor --port $border_router_port
# -----------------------------------------