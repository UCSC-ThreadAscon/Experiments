logs=($(ls | grep "delay-client"))

# Grab the independent variables from the first file.
function sanitize() {
  cat $1 | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -d '\000'
}

cipher=$(sanitize ${logs[0]} | grep "Cipher Suite:" | awk '{print $6}')
tx_power=$(sanitize ${logs[0]} | grep "Max TX Power is:" -m 1 | awk '{print $8}')

outputFile="delay-client-${cipher}-${tx_power}dbm-FULL-LOG.txt"

for log in ${logs[@]}; do
  cat $log | tee -a $outputFile > /dev/null
done