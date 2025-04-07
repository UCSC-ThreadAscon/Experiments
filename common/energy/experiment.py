import argparse
import subprocess

from import_module import *
import_module("kasa_wrapper.py")

async def build_flash_rcp(cipher_num, exp_rcp_num):
  await power_off("Border Router")
  await power_on("Radio Co-Processor")

  subprocess.run(["bash", RCP_SCRIPT, "-e", cipher_num, "-p", RCP_PORT,
                  "-x", exp_rcp_num],
                 stdout=PIPE, stderr=STDOUT)

  await power_off("Radio Co-Processor")
  return

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