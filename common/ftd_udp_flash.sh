while getopts p: arg
do
  case "${arg}" in
    t) tx_power=${OPTARG};;
    e) cipher_num=${OPTARG};;
    p) ftd_port=${OPTARG};;
  esac
done

cipher_string=$(to_cipher_string $cipher_num)
txpower_string="${tx_power}dbm"
output_file_path="$HOME/Desktop/Repositories/Experiments/throughput-udp/queue/tp-udp-FTD-$cipher_string-$txpower_string.txt"

idf.py flash --port $ftd_port |& tee -a $output_file_path