"""RESOURCES UTILIZED:
   https://www.dabeaz.com/generators/Generators.pdf
   https://shuzhanfan.github.io/2017/12/parallel-processing-python-subprocess/
   https://docs.python.org/3/tutorial/inputoutput.html#methods-of-file-objects
"""
import serial
from subprocess import run, STDOUT, PIPE
from multiprocessing import Process
from nrf802154_sniffer import Nrf802154Sniffer

# ---- TO-DO ----
# 1. Automate Wireshark
# 2. Add ability to specify different independent variables at cmd line args
#

SHOW_LOGS = False

BORDER_ROUTER_PORT = "/dev/cu.usbmodem2101"
FTD_PORT = "/dev/cu.usbmodem1201"

SNIFFER_PORT = "/dev/cu.usbmodem1401"
THREAD_NETWORK_CHANNEL = 20

SERVER_START_STRING = "Created Throughput Confirmable server at 'throughput-confirmable'."
EXPERIMENT_END_STRING = "Finished running 1 trials for current experiment."

def ftd_monitor():
  run(["bash", "./ftd.sh", "-t", "20", "-e", "0", "-p", FTD_PORT],
      stdout=PIPE, stderr=STDOUT)

  log_filename = "queue/tp-con-FTD-AES-20dbm.txt"

  with open(log_filename, "ba") as logfile:
    with serial.Serial(FTD_PORT, timeout=1) as ftd:
      print("FTD monitoring has started.")
      while True:
        line_bytes = ftd.readline()

        if line_bytes != b"":
          logfile.write(line_bytes)

          line = line_bytes.decode()
          if SHOW_LOGS:
            print(line.strip("\n"))

          if EXPERIMENT_END_STRING in line:
            print("FTD has completed the experiment.")
            break
  return

def border_router_monitor():
  run(["bash", "./border_router.sh", "-t", "20", "-e", "0", "-p", BORDER_ROUTER_PORT],
      stdout=PIPE, stderr=STDOUT)

  log_filename = "queue/tp-con-BR-AES-20dbm.txt"

  sniffer = Nrf802154Sniffer()
  sniffer.extcap_capture(fifo="queue/tp-con-AES-20dbm.pcapng", dev=SNIFFER_PORT,
                         channel=THREAD_NETWORK_CHANNEL)
  print("Started 802.15.4 Packet Sniffer Wireshark capture.")

  with open(log_filename, "ba") as logfile:
    with serial.Serial(BORDER_ROUTER_PORT, timeout=1) as border_router:
      print("Border Router monitoring has started.")

      ftd_process = Process(target=ftd_monitor)
      ftd_started = False

      while (not ftd_started) or (ftd_process.is_alive()):
        line_bytes = border_router.readline()

        if line_bytes != b"":
          logfile.write(line_bytes)

          line = line_bytes.decode()
          if SHOW_LOGS:
            print(line.strip("\n"))

          if not ftd_started:
            if SERVER_START_STRING in line:
              ftd_process.start()
              ftd_started = True

  print("Border Router monitoring has stopped.")  

  sniffer.stop_sig_handler()
  print("Stopped Packet Sniffer capture.")
  return

if __name__ == "__main__":
  run(["make", "clean-queue"])

  border_router_process = Process(target=border_router_monitor)
  border_router_process.start()