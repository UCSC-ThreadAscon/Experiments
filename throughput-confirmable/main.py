"""RESOURCES UTILIZED:
   https://www.dabeaz.com/generators/Generators.pdf
   https://shuzhanfan.github.io/2017/12/parallel-processing-python-subprocess/
   https://docs.python.org/3/tutorial/inputoutput.html#methods-of-file-objects
"""

from subprocess import Popen, run, STDOUT, PIPE
from time import sleep

SERVER_START_STRING = "Started CoAP server at port 5683."

""" Slides 75-79 of https://www.dabeaz.com/generators/Generators.pdf.
"""
def beazleyRealTimeFileRead(filename):
  FILE_START = 0
  SLEEP_TIME_SECONDS = 1

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
          sleep(SLEEP_TIME_SECONDS)
    except OSError:
      #
      # This error occurs when the file does not exist yet.
      # Let's wait for a some time to allow for the subprocess
      # to create the file we want to read.
      #
      sleep(SLEEP_TIME_SECONDS)
      continue
  return

if __name__ == "__main__":
  run(["make", "clean-queue"])

  br_process = Popen(["make", "tp-con-border-router-aes-20"], stderr=STDOUT)
  ftd_process = None

  for line in beazleyRealTimeFileRead("./queue/tp-con-BR-AES-20dbm.txt"):
    if SERVER_START_STRING in line:
      ftd_process = Popen(["make", "tp-con-ftd-aes-20"], stderr=STDOUT)
      break

  if ftd_process == None:
    raise Exception("ERROR: Failed to start the FTD.")

  ftd_process.wait()
  br_process.wait()