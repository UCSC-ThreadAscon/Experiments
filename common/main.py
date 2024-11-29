""" RESOURCES UTILIZED:
    https://stackoverflow.com/a/63975963/6621292
    https://pyserial.readthedocs.io/en/latest/shortintro.html
    https://docs.python.org/3/library/asyncio-dev.html
    https://docs.python.org/3/library/multiprocessing.html
"""
import serial
import asyncio
import subprocess
from time import sleep
from subprocess import STDOUT, PIPE
from multiprocessing import Process
from nrf802154_sniffer import Nrf802154Sniffer

from kasa_wrapper import *
from experiment import *

SHOW_LOGS = False

RCP_PORT = "/dev/ttyACM0"
SERVER_PORT = "/dev/ttyACM0"

SNIFFER_PORT = "/dev/ttyACM1"
FTD_PORT = "/dev/ttyACM2"

THREAD_NETWORK_CHANNEL = 20

SERVER_START_STRING = "Created Throughput Confirmable server at 'throughput-confirmable'."
EXPERIMENT_END_STRING = "Finished running 1 trials for the current experiment."
EXPERIMENT_TRIAL_FAILURE = "Going to restart the current experimental trial."
TRIAL_COMPLETION_SUBSTRING = "is now complete."

def print_line(line):
  if SHOW_LOGS:
    print(line.strip("\n"))
  return

async def build_flash_rcp(cipher_num):
  await power_off("Border Router")
  await power_on("Radio Co-Processor")

  subprocess.run(["bash", RCP_SCRIPT, "-e", cipher_num, "-p", RCP_PORT],
                 stdout=PIPE, stderr=STDOUT)

  await power_off("Radio Co-Processor")
  return

def ftd_monitor(tx_power, cipher_num, exp_client_num, experiment_num):
  async def _ftd_monitor(tx_power, cipher_num, exp_client_num, experiment_num):
    await power_on("Full Thread Device")

    subprocess.run(["bash", FTD_SCRIPT, "-t", tx_power, "-e",
                    cipher_num, "-p", FTD_PORT, "-x", exp_client_num],
                    stdout=PIPE, stderr=STDOUT)

    log_filename = get_dir_path(experiment_num, None).as_posix() + \
                   f"/queue/{get_exp_filename(experiment_num)}-" + \
                   f"FTD-{to_cipher_string(cipher_num)}-{tx_power}dbm.txt"

    with open(log_filename, "ba") as logfile:
      with serial.Serial(FTD_PORT, timeout=1) as ftd:
        print("FTD monitoring has started.")
        while True:
          line_bytes = ftd.readline()

          if line_bytes != b"":
            logfile.write(line_bytes)

            line = line_bytes.decode()
            print_line(line)

            if EXPERIMENT_TRIAL_FAILURE in line:
              print("An experimental trial has failed. " +
                    "The FTD is going to restart the trial.")
            
            elif TRIAL_COMPLETION_SUBSTRING in line:
              print(line)

            elif EXPERIMENT_END_STRING in line:
              print("FTD has completed the experiment.")
              break
    
    await power_off("Full Thread Device")
    return

  return asyncio.run(_ftd_monitor(tx_power, cipher_num, exp_client_num, experiment_num))

def get_server_name(exp_server_num):
  return "Delay Server" if exp_server_num == "3" else "Border Router"

def get_server_script(exp_server_num):
  return FTD_SCRIPT if exp_server_num == "3" else BORDER_ROUTER_SCRIPT

def get_server_file_abbr(exp_server_num):
  return "delay-server" if exp_server_num == "3" else "BR"

def server_monitor(tx_power, cipher_num, exp_server_num, exp_client_num, experiment_num):
  async def _server_monitor(tx_power, cipher_num, exp_server_num,
                            exp_client_num, experiment_num):
    server_name = get_server_name(exp_server_num)
    await power_on(server_name)

    server_script = get_server_script(exp_server_num)
    subprocess.run(["bash", server_script, "-t", tx_power,
                   "-e", cipher_num, "-p", SERVER_PORT,
                   "-x", exp_server_num],
                   stdout=PIPE, stderr=STDOUT)

    exp_dir_path = get_dir_path(experiment_num, None).as_posix()

    log_filename = exp_dir_path + \
      f"/queue/{get_exp_filename(experiment_num)}-" + \
      f"{get_server_file_abbr(exp_server_num)}-" + \
      f"{to_cipher_string(cipher_num)}-{tx_power}dbm.txt"
    
    sniffer_filename = exp_dir_path + \
      f"/queue/tp-con-{to_cipher_string(cipher_num)}-{tx_power}dbm.pcapng"

    await power_on("Packet Sniffer")
    sniffer = Nrf802154Sniffer()
    sniffer.extcap_capture(
      fifo=sniffer_filename,
      dev=SNIFFER_PORT,
      channel=THREAD_NETWORK_CHANNEL
    )
    print("Started 802.15.4 Packet Sniffer Wireshark capture.")

    with open(log_filename, "ba") as logfile:
      with serial.Serial(SERVER_PORT, timeout=1) as server:
        print(f"{server_name} monitoring has started.")

        ftd_process = Process(target=ftd_monitor, args=(tx_power, cipher_num,
                                                        exp_client_num, experiment_num))
        ftd_started = False

        while (not ftd_started) or (ftd_process.is_alive()):
          line_bytes = server.readline()

          if line_bytes != b"":
            logfile.write(line_bytes)

            line = line_bytes.decode()
            print_line(line)

            if not ftd_started:
              if SERVER_START_STRING in line:
                ftd_process.start()
                ftd_started = True

    print(f"{server_name} monitoring has stopped.")
    await power_off(server_name)

    sniffer.stop_sig_handler()
    print("Stopped Packet Sniffer capture.")
    await power_off("Packet Sniffer")

    return

  return asyncio.run(_server_monitor(tx_power, cipher_num, exp_server_num,
                                     exp_client_num, experiment_num))

async def main():
  await check_main_usb_hub_ports_off()

  parser = cmd_arg_parser()
  args = parser.parse_args()

  tx_power = args.tx_power
  cipher_num = args.encryption
  experiment_num = int(args.experiment)

  match experiment_num:
    case Experiment.DELAY.value:
      exp_server_num = "3"
      exp_client_num = "4"
    case Experiment.THROUGHPUT_CONFIRMABLE.value:
      exp_server_num = "1"
      exp_client_num = "1"
    case _:
      raise Exception(f"Invalid Experiment Number: {experiment_num}.")

  await power_on("Main USB Hub")

  if experiment_num != Experiment.DELAY.value:
    await build_flash_rcp(cipher_num)

  sleep(PORT_CONNECT_WAIT_SECONDS)
  server_process = Process(target=server_monitor,
                           args=(tx_power, cipher_num, exp_server_num, exp_client_num,
                                 experiment_num))
  server_process.start()

  server_process.join()
  post_process(experiment_num, cipher_num, tx_power)

  await power_off("Main USB Hub")
  return

if __name__ == "__main__":
  asyncio.run(main())