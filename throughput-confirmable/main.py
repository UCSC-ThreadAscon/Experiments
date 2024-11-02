"""RESOURCES UTILIZED:
   https://www.dabeaz.com/generators/Generators.pdf
   https://shuzhanfan.github.io/2017/12/parallel-processing-python-subprocess/
   https://docs.python.org/3/tutorial/inputoutput.html#methods-of-file-objects
"""
import serial
from subprocess import run, STDOUT
from multiprocessing import Process
from time import sleep

SERVER_START_STRING = "Created Throughput Confirmable server at 'throughput-confirmable'."
EXPERIMENT_END_STRING = "Finished running 1 trials for current experiment."

BORDER_ROUTER_PORT = "/dev/cu.usbmodem2101"
FTD_PORT = "/dev/cu.usbmodem1201"

def ftd_monitor():
  run(["bash", "./ftd.sh", "-t", "20", "-e", "0", "-p", FTD_PORT], stderr=STDOUT)

  with serial.Serial(FTD_PORT, timeout=1) as ftd:
    while True:
      line_bytes = ftd.readline()

      if line_bytes != b"":
        line = line_bytes.decode()
        print(line.strip("\n"))

        if EXPERIMENT_END_STRING in line:
          print("Done with the experiment!")
          break
  return

def border_router_monitor():
  run(["bash", "./border_router.sh", "-t", "20", "-e", "0", "-p", BORDER_ROUTER_PORT], stderr=STDOUT)

  with serial.Serial(BORDER_ROUTER_PORT, timeout=1) as border_router:
    ftd_process = Process(target=ftd_monitor)
    ftd_started = False

    while True:
      line_bytes = border_router.readline()

      if line_bytes != b"":
        line = line_bytes.decode()
        print(line.strip("\n"))

        if not ftd_started:
          if SERVER_START_STRING in line:
            ftd_process.start()
            ftd_started = True
        else:
          if not ftd_process.is_alive():
            # The FTD has completed the experiment.
            break
  return

if __name__ == "__main__":
  run(["make", "clean-queue"])

  border_router_process = Process(target=border_router_monitor)
  border_router_process.start()