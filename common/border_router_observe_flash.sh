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
    p) border_router_port=${OPTARG};;
    x) experiment_num=${OPTARG};;
  esac
done

border_router_path=$HOME/Desktop/Repositories/br_netperf/examples/basic_thread_border_router

cipher_string=$(to_cipher_string $cipher_num)
txpower_string="${tx_power}dbm"

if [ $experiment_num == 3 ]
then
  output_file_path="$HOME/Desktop/Repositories/Experiments/throughput-observe/queue/tp-observe-BR-$cipher_string-$txpower_string.txt"
elif [ $experiment_num == 4 ]
then
  output_file_path="$HOME/Desktop/Repositories/Experiments/packet-loss-observe/queue/pl-observe-BR-$cipher_string-$txpower_string.txt"
fi

cd $border_router_path
source $HOME/esp/esp-idf/export.sh &>> $output_file_path
idf.py flash --port $border_router_port |& tee -a $output_file_path
cd -