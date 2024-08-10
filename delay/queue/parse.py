import sys
import os

testFile = os.path.join(os.curdir, "delay-client-AES-20dBm.txt")

with open(testFile, 'r') as file:
  for line in file:
    print(line)