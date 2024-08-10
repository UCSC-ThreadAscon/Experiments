import sys
import os

testFile = os.path.join(os.curdir, "delay-client-AES-20dBm.txt")

with open(testFile, 'r') as file:
  for line in file:
    """ The average Delay (in uS) for each experiment will be
        always displayed after the phrase 'The AVERAGE delay is'.

        The average Delay will always be the 7th word in the line
        that it is displayed in.
    """
    if "The AVERAGE delay is:" in line:
      print(line.split(" ")[7])