import sys
import os

AVERAGE_DELAY_EXP="The AVERAGE delay is:"
SPACE_DELIMITER=" "

testFile = os.path.join(os.curdir, "delay-client-AES-20dBm.txt")

with open(testFile, 'r') as file:
  for line in file:
    if AVERAGE_DELAY_EXP in line:
      print(line.split(SPACE_DELIMITER)[7])