"""RESOURCES UTILIZED:
   https://www.dabeaz.com/generators/Generators.pdf
   https://shuzhanfan.github.io/2017/12/parallel-processing-python-subprocess/
"""

from subprocess import Popen, run, STDOUT, PIPE
from time import sleep


""" Slides 77-79 of https://www.dabeaz.com/generators/Generators.pdf.
"""
def beazleyRealTimeFileRead(filename):
  return

if __name__ == "__main__":
  run(["make", "clean-queue"])

  br_process = Popen(["bash", "./border_router.sh", "-t", "20", "-e", "0", "-p", "/dev/cu.usbmodem2101"], stderr=STDOUT)

  while True:
    print("Hello")
    sleep(5)

  br_process.wait()