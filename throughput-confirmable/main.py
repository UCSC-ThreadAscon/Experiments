"""RESOURCES UTILIZED:
   https://www.dabeaz.com/generators/Generators.pdf
   https://shuzhanfan.github.io/2017/12/parallel-processing-python-subprocess/
   https://docs.python.org/3/tutorial/inputoutput.html#methods-of-file-objects
"""

from subprocess import Popen, run, STDOUT, PIPE
from time import sleep

FILE_START = 0

""" Slides 77-79 of https://www.dabeaz.com/generators/Generators.pdf.
"""
def beazleyRealTimeFileRead(filename):
  with open(filename, "r") as file:
    offset = FILE_START
    file.seek(offset, FILE_START)

    while True:
      for line in file:
        yield line
        offset += 1
      else:
        sleep(0.5)
  return

if __name__ == "__main__":
  run(["make", "clean-queue"])

  br_process = Popen(["bash", "./border_router.sh", "-t", "20", "-e", "0", "-p", "/dev/cu.usbmodem2101"], stderr=STDOUT)

  for line in beazleyRealTimeFileRead("./queue/tp-con-BR-AES-20dbm.txt"):
    print(f"The line is: {line}")

  br_process.wait()