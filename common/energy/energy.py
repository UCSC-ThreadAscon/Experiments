import serial
import asyncio

from experiment import *

async def main():
  # await check_main_usb_hub_ports_off()

  parser = cmd_arg_parser()
  args = parser.parse_args()

  tx_power = args.tx_power
  cipher_num = args.encryption

  # await power_on("Main USB Hub")
  # await build_flash_rcp(cipher_num, exp_rcp_num)

  sleep(PORT_CONNECT_WAIT_SECONDS)
  # TODO: Start up the Border Router process.

  return

if __name__ == "__main__":
  asyncio.run(main())