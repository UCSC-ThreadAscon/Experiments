# RESOURCES UTILIZED:
# https://stackoverflow.com/questions/692000/how-do-i-write-standard-error-to-a-file-while-using-tee-with-a-pipe/692009#692009
# https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script#flags
# https://unix.stackexchange.com/questions/159367/using-sed-to-find-and-replace
# https://stackoverflow.com/a/57766728/6621292
# https://askubuntu.com/a/420983
# https://ryanstutorials.net/bash-scripting-tutorial/bash-if-statements.php#ifelif
# https://stackoverflow.com/a/18856472/6621292
# https://stackoverflow.com/a/525612/6621292

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

function to_role() {
  case $1 in
    1) echo "front-door" ;;
    2) echo "air-quality" ;;
    3) echo "window" ;;
  esac
}

while getopts t:e:p:r: arg
do
  case "${arg}" in
    t) tx_power=${OPTARG};;
    e) cipher_num=${OPTARG};;
    p) sed_port=${OPTARG};;
    r) role_num=${OPTARG};;
  esac
done

# ---- Create the Output File ----
cipher_string=$(to_cipher_string $cipher_num)
txpower_string="${tx_power}dbm"
role_string=$(to_role $role_num)

output_file_path="$HOME/Desktop/Repositories/Experiments/energy/queue/energy-sed-$role_string-$cipher_string-$txpower_string.txt"

rm -f $output_file_path
date |& tee $output_file_path

set_commit_ids_exec=$HOME/Desktop/Repositories/Experiments/energy/common/set_commit_ids.sh
sed_path=$HOME/Desktop/Repositories/energy-usage-sed-simple
# --------------------------------

# ---- Set the KConfig variables ----
sed_sdkconfig=$sed_path/sdkconfig

sdkconfig_set CONFIG_SCENARIO $role_num $sed_sdkconfig

# Change both the cipher suite and TX power settings in `sdkconfig`.
sdkconfig_set CONFIG_THREAD_ASCON_CIPHER_SUITE $cipher_num $sed_sdkconfig
sdkconfig_set CONFIG_TX_POWER $tx_power $sed_sdkconfig
# -----------------------------------

# ---- Build, Flash, & Monitor ----
cd $sed_path

echo "--------- FTD KConfig Variables ---------" |& tee -a $output_file_path
echo $(sdkconfig_get CONFIG_THREAD_ASCON_CIPHER_SUITE $sed_sdkconfig) |& tee -a $output_file_path
echo $(sdkconfig_get CONFIG_TX_POWER $sed_sdkconfig) |& tee -a $output_file_path
echo $(sdkconfig_get CONFIG_SCENARIO $sed_sdkconfig) |& tee -a $output_file_path
echo "-----------------------------------------" |& tee -a $output_file_path

source $HOME/esp/esp-idf/export.sh &>> $output_file_path

idf.py fullclean |& tee -a $output_file_path
idf.py build flash --port $sed_port |& tee -a $output_file_path

cd -
# ---------------------------------