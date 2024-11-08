import serial
import argparse
from subprocess import run, STDOUT, PIPE
from multiprocessing import Process
from nrf802154_sniffer import Nrf802154Sniffer

SHOW_LOGS = False

BORDER_ROUTER_PORT = "/dev/cu.usbmodem2101"
FTD_PORT = "/dev/cu.usbmodem1201"

SNIFFER_PORT = "/dev/cu.usbmodem1301"
THREAD_NETWORK_CHANNEL = 20

SERVER_START_STRING = "Created Throughput Confirmable server at 'throughput-confirmable'."
EXPERIMENT_END_STRING = "Finished running 1 trials for current experiment."

def cmd_arg_parser():
  parser = argparse.ArgumentParser()

  helper_text = \
    """The transmission (TX) power that all devices will use in the experiment.
       The TX power must be number between -24 dBm or 20 dBm (both numbers inclusive).
    """
  parser.add_argument("--tx-power", help=helper_text, required=True)

  helper_text = \
    """The encryption algorithm to use in the experiment. Set the argument
       to one of the following integers to use the corresponding encryption algorithms:

        Option "0" will use AES encryption.

        Option "1" will use no encryption (plaintext).

        Option "2" wil use the ESP32 optimized version of ASCON-128a.

        Option "3" will use the reference implementation of ASCON-128a.

        Option "4" will use the ASCON-128a implemenation from LibAscon,
        which uses variable tag length.

        Option "5" will use the ASCON-128 implementation of LibAscon,
        which uses variable tag length.
    """
  parser.add_argument("--encryption", help=helper_text, required=True)
  return parser

def to_cipher_string(cipher_num):
  match cipher_num:
    case 0:
      return "AES"
    case 1:
      return "NoEncrypt"
    case 2:
      return "Ascon128a-esp32"
    case 3:
      return "Ascon128a-ref"
    case 4:
      return "LibAscon-128a"
    case 5:
      return "LibAscon-128"
    case _:
      raise Exception("Number does not correspond to an Encryption Algorithm.")

def print_line(line):
  if SHOW_LOGS:
    print(line.strip("\n"))
  return

def ftd_monitor(tx_power, cipher_num):
  run(["bash", "./ftd.sh", "-t", tx_power, "-e", cipher_num, "-p", FTD_PORT],
      stdout=PIPE, stderr=STDOUT)

  log_filename = f"queue/tp-con-FTD-{to_cipher_string(cipher_num)}-{tx_power}dbm.txt"

  with open(log_filename, "ba") as logfile:
    with serial.Serial(FTD_PORT, timeout=1) as ftd:
      print("FTD monitoring has started.")
      while True:
        line_bytes = ftd.readline()

        if line_bytes != b"":
          logfile.write(line_bytes)

          line = line_bytes.decode()
          print_line(line)

          if EXPERIMENT_END_STRING in line:
            print("FTD has completed the experiment.")
            break
  return

def border_router_monitor(tx_power, cipher_num):
  run(["bash", "./border_router.sh", "-t", tx_power,
       "-e", cipher_num, "-p", BORDER_ROUTER_PORT],
      stdout=PIPE, stderr=STDOUT)

  log_filename = \
    f"queue/tp-con-BR-{to_cipher_string(cipher_num)}-{tx_power}dbm.txt"

  sniffer = Nrf802154Sniffer()
  sniffer.extcap_capture(fifo="queue/tp-con-AES-20dbm.pcapng", dev=SNIFFER_PORT,
                         channel=THREAD_NETWORK_CHANNEL)
  print("Started 802.15.4 Packet Sniffer Wireshark capture.")

  with open(log_filename, "ba") as logfile:
    with serial.Serial(BORDER_ROUTER_PORT, timeout=1) as border_router:
      print("Border Router monitoring has started.")

      ftd_process = Process(target=ftd_monitor, args=(tx_power, cipher_num))
      ftd_started = False

      while (not ftd_started) or (ftd_process.is_alive()):
        line_bytes = border_router.readline()

        if line_bytes != b"":
          logfile.write(line_bytes)

          line = line_bytes.decode()
          print_line(line)

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

  parser = cmd_arg_parser()
  args = parser.parse_args()

  tx_power = int(args.tx_power)
  cipher_num = int(args.encryption)

  border_router_process = Process(target=border_router_monitor,
                                  args=(tx_power, cipher_num))
  border_router_process.start()