"""RESOURCES UTILIZED:
   https://www.dabeaz.com/generators/Generators.pdf
   https://shuzhanfan.github.io/2017/12/parallel-processing-python-subprocess/
   https://docs.python.org/3/tutorial/inputoutput.html#methods-of-file-objects
"""
import serial
from subprocess import run, STDOUT
from multiprocessing import Process
from time import sleep

SERVER_START_STRING = "Started CoAP server at port 5683."
EXPERIMENT_END_STRING = "Finished running 1 trials for current experiment."

BORDER_ROUTER_PORT = "/dev/cu.usbmodem2101"
FTD_PORT = "/dev/cu.usbserial-120"

def border_router_monitor():
  run(["bash", "./border_router.sh", "-t", "20", "-e", "0", "-p", BORDER_ROUTER_PORT], stderr=STDOUT)

  with serial.Serial(BORDER_ROUTER_PORT, timeout=1) as border_router:
    while True:
      line_bytes = border_router.readline()

      if line_bytes != b"":
        line = line_bytes.decode()
        print(line.strip("\n"))

        if SERVER_START_STRING in line:
          print("From `main.py`: ---- STARTING FTD ----")
          break
  return

if __name__ == "__main__":
  run(["make", "clean-queue"])

  border_router_process = Process(target=border_router_monitor)
  border_router_process.start()

  # for line in beazleyRealTimeFileRead("./queue/tp-con-BR-AES-20dbm.txt", 1):
  #   if SERVER_START_STRING in line:
  #     print("---- STARTING FTD ----")
  #     ftd_process = Popen(["bash", "./ftd.sh", "-t", "20", "-e", "0", "-p", FTD_PORT], stderr=STDOUT)
  #     break

  # if ftd_process == None:
  #   raise Exception("ERROR: Failed to start the FTD.")

  # for line in beazleyRealTimeFileRead("./queue/tp-con-FTD-AES-20dbm.txt", 1):
  #   #
  #   # TO-DO: You need to terminate the ESP-IDF terminal by typing "CTRL" + "]"
  #   #        onto the respective consoles, rather than sending a terminate signal.
  #   #
  #   if EXPERIMENT_END_STRING in line:
  #     ftd_process.terminate()
  #     br_process.terminate()
  #     break