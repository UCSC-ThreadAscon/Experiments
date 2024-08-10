logs=($(ls | grep "delay-client"))

# Grab the independent variables from the first file.
cipher=$(cat ${logs[1]} | grep "Cipher Suite:" | awk '{print $6}' | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -d '\000')
tx_power=$(cat ${logs[1]} | grep "Max TX Power is:" -m 1 | awk '{print $8}')

touch "delay-client-${cipher}-${tx_power}dbm-FULL-LOG.txt"

for log in ${logs[@]}; do
  cat $log | tee -a combined.txt > /dev/null
done