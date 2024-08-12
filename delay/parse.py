import re
import os

NUM_TRIALS = 100

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

  if len(averages) >= NUM_TRIALS:
    return listSum / len(averages)
  else:
    raise Exception(f"Less than {NUM_TRIALS} average delay. Not enough data for valid experiment.")

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

def writeFinalAverage(averageDelays, finalAverage, delayExpLog):
  line = findFirstLine("Cipher Suite:", delayExpLog)
  words = line.split(" ")
  cipher = removeAnsi(words[5]).replace('\n', '')

  # If "No" gets parsed, it's actually supposed to be "No Encrypt".
  # Since " " is used as a delimiter, the "Encrypt" word will be missed
  # during the parsing process.
  #
  if cipher == "No":
    cipher = "No Encrypt"

  line = findFirstLine("Max TX Power is:", delayExpLog)
  words = line.split(" ")
  txPower = words[7]

  outputFile = os.path.join(os.curdir, "queue", f"delay-final-average-{cipher}-{txPower}dbm.txt")

  with open(outputFile, "w") as file:
    file.write(f"Final Average Delay under {cipher} at {txPower} dBm: {finalAverage} us.\n")

    file.write("List of Average Delays used to create the Final Average:\n")

    for trialNum in range(1, NUM_TRIALS + 1):
      index = trialNum - 1
      file.write(f"Trial {trialNum}: {averageDelays[index]} us")
      if trialNum != NUM_TRIALS:
        file.write("\n")
  return

if __name__ == "__main__":
  combinedLog = os.path.join(os.curdir, "queue", "full-log.txt")
  averages = getAverageDelays(combinedLog)
  finalAverage = getFinalAverage(averages)

  writeFinalAverage(averages, finalAverage, combinedLog)