import serial
import asyncio

from experiment import *

async def main():
  # TO-DO: Check that Main USB ports are off.

  parser = cmd_arg_parser()
  args = parser.parse_args()

  tx_power = args.tx_power
  cipher_num = args.encryption
  return

if __name__ == "__main__":
  asyncio.run(main())