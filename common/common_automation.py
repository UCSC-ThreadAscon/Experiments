import subprocess
from subprocess import STDOUT, PIPE

from kasa_wrapper import *
from experiment import *

SHOW_LOGS = False

RCP_PORT = "/dev/ttyACM0"
LEADER_PORT = "/dev/ttyACM0"

SNIFFER_PORT = "/dev/ttyACM1"
CALCULATOR_PORT = "/dev/ttyACM2"

THREAD_NETWORK_CHANNEL = 20

EXPERIMENT_TRIAL_FAILURE = "Going to restart the current experiment trial."
TRIAL_COMPLETION_SUBSTRING = "is now complete."

async def build_flash_rcp(cipher_num, exp_rcp_num):
  await power_off("Border Router")
  await power_on("Radio Co-Processor")

  subprocess.run(["bash", RCP_SCRIPT, "-e", cipher_num, "-p", RCP_PORT,
                  "-x", exp_rcp_num],
                 stdout=PIPE, stderr=STDOUT)

  await power_off("Radio Co-Processor")
  return