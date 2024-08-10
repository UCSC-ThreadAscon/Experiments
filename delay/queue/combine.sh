logs=($(ls | grep "delay-client"))

outputFile="full-log.txt"
for log in ${logs[@]}; do
  cat $log | tee -a $outputFile > /dev/null
done