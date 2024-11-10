""" RESOURCES UTILIZED:
    https://stackoverflow.com/a/63975963/6621292
    https://pyserial.readthedocs.io/en/latest/shortintro.html
    https://docs.python.org/3/library/asyncio-dev.html
    https://docs.python.org/3/library/multiprocessing.html
"""
import serial
import argparse
import subprocess
from subprocess import STDOUT, PIPE
from multiprocessing import Process
from nrf802154_sniffer import Nrf802154Sniffer

import add_to_path
add_to_path.add_common_to_path()

import asyncio
from kasa_wrapper import power_on, power_off, power_off_all_devices # type: ignore
from kasa_wrapper import check_main_usb_hub_ports_off # type: ignore

SHOW_LOGS = True

RCP_PORT = "/dev/ttyACM0"
BORDER_ROUTER_PORT = "/dev/ttyACM0"

SNIFFER_PORT = "/dev/ttyACM1"
FTD_PORT = "/dev/ttyACM2"

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
    case "0":
      return "AES"
    case "1":
      return "NoEncrypt"
    case "2":
      return "Ascon128a-esp32"
    case "3":
      return "Ascon128a-ref"
    case "4":
      return "LibAscon-128a"
    case "5":
      return "LibAscon-128"
    case _:
      raise Exception("Number does not correspond to an Encryption Algorithm.")

def print_line(line):
  if SHOW_LOGS:
    print(line.strip("\n"))
  return

async def build_flash_rcp(cipher_num):
  await power_off("Border Router")
  await power_on("Radio Co-Processor")

  subprocess.run(["bash", "./rcp.sh", "-e", cipher_num, "-p", RCP_PORT],
      stdout=PIPE, stderr=STDOUT)

  await power_off("Radio Co-Processor")
  return

def ftd_monitor(tx_power, cipher_num):
  async def _ftd_monitor(tx_power, cipher_num):
    await power_on("Full Thread Device")

    subprocess.run(["bash", "./ftd.sh", "-t", tx_power, "-e", cipher_num, "-p", FTD_PORT],
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
    
    await power_off("Full Thread Device")
    return

  return asyncio.run(_ftd_monitor(tx_power, cipher_num))

def border_router_monitor(tx_power, cipher_num):
  async def _border_router_monitor(tx_power, cipher_num):
    await power_on("Border Router")

    subprocess.run(["bash", "./border_router.sh", "-t", tx_power,
                   "-e", cipher_num, "-p", BORDER_ROUTER_PORT],
                   stdout=PIPE, stderr=STDOUT)

    log_filename = \
      f"queue/tp-con-BR-{to_cipher_string(cipher_num)}-{tx_power}dbm.txt"
    
    sniffer_filename = \
      f"queue/tp-con-{to_cipher_string(cipher_num)}-{tx_power}dbm.pcapng"

    await power_on("Packet Sniffer")
    sniffer = Nrf802154Sniffer()
    sniffer.extcap_capture(
      fifo=sniffer_filename,
      dev=SNIFFER_PORT,
      channel=THREAD_NETWORK_CHANNEL
    )
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
    await power_off("Border Router")

    sniffer.stop_sig_handler()
    print("Stopped Packet Sniffer capture.")
    await power_off("Packet Sniffer")

    return

  return asyncio.run(_border_router_monitor(tx_power, cipher_num))

async def main():
  await power_off_all_devices()
  subprocess.run(["make", "clean-queue"])

  await check_main_usb_hub_ports_off()

  parser = cmd_arg_parser()
  args = parser.parse_args()

  tx_power = args.tx_power
  cipher_num = args.encryption

  await power_on("Main USB Hub")
  await build_flash_rcp(cipher_num)

  border_router_process = Process(target=border_router_monitor,
                                  args=(tx_power, cipher_num))
  border_router_process.start()
  return

if __name__ == "__main__":
  asyncio.run(main())