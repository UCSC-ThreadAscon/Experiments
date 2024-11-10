for encryption in {0, 1, 4, 5}
do
  for tx_power in {0, 9, 20}
  do
    python3 ./main.py --tx-power $tx_power --encryption $encryption
  done
done