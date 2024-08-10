import re
import os
"""TODO:
    1. In the case you have multiple files with average delays,
       write a Bash script that combines the multiple files into
       a single, large file.

       While you're at it, use the Bash script to print the independent
       variables.

    2. When calculating the average delay, only consider the first
       100 average delays in the array.

    3. Write the average you calculated into a new file.
       * Parse the file with the average delays itself to get the independent variables.

    Use consistent and systematic naming conventions so you know which files
    to look for without having to specify them as input.
"""

def getAverageDelays(filepath):
  averages = []
  with open(filepath, 'r') as file:
    for line in file:
      """ The average Delay (in uS) for each experiment will be
          always displayed after the phrase 'The AVERAGE delay is'.

          The average Delay will always be the 7th word (assuming 0 index)
          in the line that it is displayed in.
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

def findFirstLine(expression, filepath):
  with open(filepath, 'r') as file:
    for line in file:
      if expression in line:
        return line
  raise Exception(f"Can't find expression '{expression}' in '{filepath}'.")

"""The lines of code and regular expression I used to remove ANSI escape
   sequences comes from:
   https://stackoverflow.com/a/14693789/6621292
"""
def removeAnsi(line):
  ansiEscapes = re.compile(
    br'(?:\x1B[@-Z\\-_]|[\x80-\x9A\x9C-\x9F]|(?:\x1B\[|\x9B)[0-?]*[ -/]*[@-~])'
  )
  result = ansiEscapes.sub(b'', bytes(line, "utf-8"))
  return str(result, encoding="utf-8")

def writeFinalAverage(averageDelays, finalAverge, delayExpLog):
  line = findFirstLine("Cipher Suite:", delayExpLog)
  words = line.split(" ")
  cipher = removeAnsi(words[5]).replace('\n', '')
  print(cipher)

  line = findFirstLine("Max TX Power is:", delayExpLog)
  words = line.split(" ")
  txPower = words[7]

  outputFile = f"delay-final-average-{cipher}-{txPower}dbm.txt"
  with open(outputFile, "w") as file:
    file.write(f"Average Delay under {cipher} at {txPower} dBm: {finalAverage} us.")

  return

if __name__ == "__main__":
  testFile = os.path.join(os.curdir, "delay-client-AES-20dBm.txt")
  averages = getAverageDelays(testFile)
  finalAverage = getFinalAverage(averages)

  # print(averages)
  # print(finalAverage)
  writeFinalAverage(averages, finalAverage, testFile)