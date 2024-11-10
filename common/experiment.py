import argparse
from pathlib import Path
from enum import Enum

class Experiment(Enum):
  DELAY=0
  THROUGHPUT_CONFIRMABLE=1

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

def get_queue_path(experiment_enum):
  experiment_dir = ""

  match experiment_enum:
    case Experiment.DELAY.value:
      experiment_dir = "delay"
    case Experiment.THROUGHPUT_CONFIRMABLE.value:
      experiment_dir = "throughput-confirmable"
    case _:
      raise Exception("Invalid Enum value for Experiment.")

  return Path(Path.home(), "Desktop", "Repositories",
              "Experiments", experiment_dir, "queue")

def get_last_exp_trial(experiment_enum, cipher_num, tx_power):
  queue_path = get_queue_path(experiment_enum)
  exp_dirname_pattern = f"{to_cipher_string(cipher_num)}-{tx_power}dbm-trial-*"

  experiment_dirs = list(queue_path.glob(exp_dirname_pattern))
  num_trials = len(experiment_dirs)
  return num_trials

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