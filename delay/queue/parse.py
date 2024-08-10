import sys
import os

def getAverage(filepath):
  averages = []

  with open(testFile, 'r') as file:
    for line in file:
      """ The average Delay (in uS) for each experiment will be
          always displayed after the phrase 'The AVERAGE delay is'.

          The average Delay will always be the 7th word in the line
          that it is displayed in.
      """
      if "The AVERAGE delay is:" in line:
        words = line.split(" ")
        average = int(words[7])
        averages.append(average)

  return averages

if __name__ == "__main__":
  testFile = os.path.join(os.curdir, "delay-client-AES-20dBm.txt")
  print(getAverage(testFile))