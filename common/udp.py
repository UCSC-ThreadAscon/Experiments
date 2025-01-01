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

async def main():
  await check_main_usb_hub_ports_off()

  parser = cmd_arg_parser()
  args = parser.parse_args()

  tx_power = args.tx_power
  cipher_num = args.encryption
  experiment_num = int(args.experiment)

  match experiment_num:
    case Experiment.THROUGHPUT_UDP.value:
      exp_leader_num = "5"        # FTD
      exp_calculator_num = "3"    # Border Router
      exp_rcp_num = "3"
    case _:
      raise Exception(f"Invalid Experiment Number: {experiment_num}.")

  await power_on("Main USB Hub")

  await build_flash_rcp(cipher_num, exp_rcp_num)

  sleep(PORT_CONNECT_WAIT_SECONDS)
  await power_off("Main USB Hub")
  return

if __name__ == "__main__":
  asyncio.run(main())