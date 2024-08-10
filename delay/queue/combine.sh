logs=($(ls | grep "delay-client"))

touch combined.txt

for log in ${logs[@]}; do
  cat $log | tee -a combined.txt > /dev/null
done