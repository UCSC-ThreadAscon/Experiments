"""RESOURCES UTILIZED:
   https://www.dabeaz.com/generators/Generators.pdf
   https://shuzhanfan.github.io/2017/12/parallel-processing-python-subprocess/
   https://docs.python.org/3/tutorial/inputoutput.html#methods-of-file-objects
"""

from subprocess import Popen, run, STDOUT, PIPE
from time import sleep

SERVER_START_STRING = "Started CoAP server at port 5683."
EXPERIMENT_END_STRING = "Finished running 1 trials for current experiment."

""" Slides 75-79 of https://www.dabeaz.com/generators/Generators.pdf.
"""
def beazleyRealTimeFileRead(filename, seconds=0.1):
  FILE_START = 0

  offset = 0

  while True:
    try:
      with open(filename, "r") as file:
        file.seek(offset, FILE_START)
        assert(offset == file.tell())

        for line in file:
          yield line
          offset += 1
        else:
          sleep(seconds)
    except OSError:
      #
      # This error occurs when the file does not exist yet.
      # Let's wait for a some time to allow for the subprocess
      # to create the file we want to read.
      #
      sleep(seconds)
      continue
  return

if __name__ == "__main__":
  run(["make", "clean-queue"])

  br_process = Popen(["make", "tp-con-border-router-aes-20"], stderr=STDOUT, stdin=PIPE)
  ftd_process = None

  for line in beazleyRealTimeFileRead("./queue/tp-con-BR-AES-20dbm.txt", 1):
    if SERVER_START_STRING in line:
      ftd_process = Popen(["make", "tp-con-ftd-aes-20"], stderr=STDOUT, stdin=PIPE)
      break

  if ftd_process == None:
    raise Exception("ERROR: Failed to start the FTD.")

  for line in beazleyRealTimeFileRead("./queue/tp-con-FTD-AES-20dbm.txt", 1):
    #
    # TO-DO: You need to terminate the ESP-IDF terminal by typing "CTRL" + "]"
    #        onto the respective consoles, rather than sending a terminate signal.
    #
    if EXPERIMENT_END_STRING in line:
      ftd_process.terminate()
      br_process.terminate()
      break

  # ftd_process.wait()
  # br_process.wait()