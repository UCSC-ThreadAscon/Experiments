# RESOURCES UTILIZED:
# - https://ryanstutorials.net/bash-scripting-tutorial/bash-loops.php#for
#
for encryption in {0,1,4,5}
do
  for tx_power in {20,9,0}
  do
    python3 ./main.py --tx-power $tx_power --encryption $encryption
  done
done