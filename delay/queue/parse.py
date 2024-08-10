import sys
import os
"""TODO:
    1. Check for overflow when you calculate averages.

    2. In the case you have multiple files with average delays,
       write a Bash script that combines the multiple files into
       a single, large file.

       While you're at it, use the Bash script to check the independent
       variables, and to make sure the indepedent variables are consistent
       across files.

    3. When calculating the average delay, only consider the first
       100 average delays in the array.

    4. Write the average you calculated into a new file.

    Use consistent and systematic naming conventions so you know which files
    to look for without having to specify them as input.
"""

def getAverageDelays(filepath):
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

def getFinalAverage(averages):
  listSum = 0
  for average in averages:
    listSum += average
  return listSum / len(averages)

if __name__ == "__main__":
  testFile = os.path.join(os.curdir, "delay-client-AES-20dBm.txt")
  averages = getAverageDelays(testFile)
  finalAverage = getFinalAverage(averages)

  print(averages)
  print(finalAverage)