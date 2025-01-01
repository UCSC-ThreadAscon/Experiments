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

while getopts t:e:p:x: arg
do
  case "${arg}" in
    t) tx_power=${OPTARG};;
    e) cipher_num=${OPTARG};;
    p) ftd_port=${OPTARG};;
    x) experiment_num=${OPTARG};;
  esac
done

cipher_string=$(to_cipher_string $cipher_num)
txpower_string="${tx_power}dbm"

if [ $experiment_num == 5 ]
then
  output_file_path="$HOME/Desktop/Repositories/Experiments/throughput-udp/queue/tp-udp-FTD-$cipher_string-$txpower_string.txt"
fi

source $HOME/esp/esp-idf/export.sh &>> $output_file_path
idf.py flash --port $ftd_port |& tee -a $output_file_path