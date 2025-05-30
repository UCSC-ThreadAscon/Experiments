""" RESOURCES UTILIZED:
    https://stackoverflow.com/a/63975963/6621292
    https://pyserial.readthedocs.io/en/latest/shortintro.html
    https://docs.python.org/3/library/asyncio-dev.html
    https://docs.python.org/3/library/multiprocessing.html
"""
import serial
import asyncio

import subprocess
from subprocess import STDOUT, PIPE

from time import sleep
from multiprocessing import Process
from nrf802154_sniffer import Nrf802154Sniffer

from kasa_wrapper import *
from experiment import *
from common_automation import *

COAP_START_STRING = "Started CoAP server"
EXPERIMENT_END_STRING = "Finished running 1000 trials for the current experiment."

def calculator_monitor(tx_power, cipher_num, exp_calculator_num, experiment_num):
  async def _calculator_monitor(tx_power, cipher_num, exp_calculator_num, experiment_num):
    calculator_name = get_calculator_name(experiment_num)
    await power_on(calculator_name)

    subprocess.run(["bash", get_calculator_script(experiment_num), "-t", tx_power, "-e",
                    cipher_num, "-p", CALCULATOR_PORT, "-x", exp_calculator_num],
                    stdout=PIPE, stderr=STDOUT)

    log_filename = get_dir_path(experiment_num, None).as_posix() + \
                   f"/queue/{get_exp_filename_prefix(experiment_num)}-" + \
                   f"{get_calculator_file_abbr(experiment_num)}-" + \
                   f"{to_cipher_string(cipher_num)}-{tx_power}dbm.txt"

    with open(log_filename, "ba") as logfile:
      with serial.Serial(CALCULATOR_PORT, timeout=1) as calculator:
        print(f"{calculator_name} monitoring has started.")
        while True:
          line_bytes = calculator.readline()

          if line_bytes != b"":
            logfile.write(line_bytes)
            line = line_bytes.decode()

            if EXPERIMENT_TRIAL_FAILURE in line:
              print("An experimental trial has failed. " +
                    f"The {calculator_name} is going to restart the trial.")
            
            elif TRIAL_COMPLETION_SUBSTRING in line:
              print(line.replace('\n', ''))

            elif EXPERIMENT_END_STRING in line:
              print(f"{calculator_name} has completed the experiment.")
              break
    
    await power_off(calculator_name)
    return

  return asyncio.run(_calculator_monitor(tx_power, cipher_num, exp_calculator_num, experiment_num))

def leader_monitor(tx_power, cipher_num, exp_leader_num, exp_calculator_num, experiment_num):
  async def _leader_monitor(tx_power, cipher_num, exp_leader_num,
                            exp_calculator_num, experiment_num):
    leader_name = get_leader_name(experiment_num)

    await power_on(leader_name)
    sleep(PORT_CONNECT_WAIT_SECONDS)
    await power_on("Packet Sniffer")

    leader_script = get_leader_script(experiment_num)
    subprocess.run(["bash", leader_script, "-t", tx_power,
                   "-e", cipher_num, "-p", LEADER_PORT,
                   "-x", exp_leader_num],
                   stdout=PIPE, stderr=STDOUT)

    exp_dir_path = get_dir_path(experiment_num, None).as_posix()
    exp_filename_prefix = get_exp_filename_prefix(experiment_num)

    log_filename = exp_dir_path + \
      f"/queue/{exp_filename_prefix}-" + \
      f"{get_leader_file_abbr(experiment_num)}-" + \
      f"{to_cipher_string(cipher_num)}-{tx_power}dbm.txt"
    
    sniffer_filename = exp_dir_path + \
      f"/queue/{exp_filename_prefix}-{to_cipher_string(cipher_num)}-{tx_power}dbm.pcapng"

    sniffer = Nrf802154Sniffer()
    sniffer.start_threaded(
      fifo=sniffer_filename,
      dev=SNIFFER_PORT,
      channel=THREAD_NETWORK_CHANNEL
    )
    print("Started 802.15.4 Packet Sniffer Wireshark capture.")

    with open(log_filename, "ba") as logfile:
      with serial.Serial(LEADER_PORT, timeout=1) as leader:
        print(f"{leader_name} monitoring has started.")

        calculator_process = Process(target=calculator_monitor,
                                     args=(tx_power, cipher_num, exp_calculator_num,
                                           experiment_num))
        calculator_started = False

        while (not calculator_started) or (calculator_process.is_alive()):
          line_bytes = leader.readline()

          if line_bytes != b"":
            logfile.write(line_bytes)
            line = line_bytes.decode()

            if not calculator_started:
              if COAP_START_STRING in line:
                calculator_process.start()
                calculator_started = True

    print(f"{leader_name} monitoring has stopped.")
    await power_off(leader_name)

    sniffer.stop_thread()
    print("Stopped Packet Sniffer capture.")
    await power_off("Packet Sniffer")

    return

  return asyncio.run(_leader_monitor(tx_power, cipher_num, exp_leader_num,
                                     exp_calculator_num, experiment_num))

async def main():
  await check_main_usb_hub_ports_off()

  parser = cmd_arg_parser()
  args = parser.parse_args()

  tx_power = args.tx_power
  cipher_num = args.encryption
  experiment_num = int(args.experiment)

  match experiment_num:
    case Experiment.DELAY.value:
      exp_leader_num = "3"        # FTD (Delay Server)
      exp_calculator_num = "4"    # FTD (Delay Client)
    case Experiment.THROUGHPUT_CONFIRMABLE.value:
      exp_leader_num = "1"        # Border Router
      exp_calculator_num = "1"    # FTD
      exp_rcp_num = "1"
    case Experiment.PACKET_LOSS_CONFIRMABLE.value:
      exp_leader_num = "2"        # Border Router
      exp_calculator_num = "2"    # FTD
      exp_rcp_num = "2"
    case _:
      raise Exception(f"Invalid Experiment Number: {experiment_num}.")

  await power_on("Main USB Hub")

  if experiment_num != Experiment.DELAY.value:
    await build_flash_rcp(cipher_num, exp_rcp_num)

  sleep(PORT_CONNECT_WAIT_SECONDS)
  leader_process = Process(target=leader_monitor,
                           args=(tx_power, cipher_num, exp_leader_num, exp_calculator_num,
                                 experiment_num))
  leader_process.start()

  leader_process.join()
  post_process(experiment_num, cipher_num, tx_power)

  await power_off("Main USB Hub")
  return

if __name__ == "__main__":
  asyncio.run(main())