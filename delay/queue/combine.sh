logs=($(ls | grep "delay-client"))

outputFile="full-log.txt"
rm -r -f $outputFile

for log in ${logs[@]}; do
  cat $log | tee -a $outputFile > /dev/null
done