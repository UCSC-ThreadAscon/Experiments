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

def get_dir_path(experiment_enum, subdir_name):
  experiment_dir = ""

  match experiment_enum:
    case Experiment.DELAY.value:
      experiment_dir = "delay"
    case Experiment.THROUGHPUT_CONFIRMABLE.value:
      experiment_dir = "throughput-confirmable"
    case _:
      raise Exception("Invalid Enum value for Experiment.")

  return Path(Path.home(), "Desktop", "Repositories",
              "Experiments", experiment_dir, subdir_name)

def get_last_exp_trial(experiment_enum, cipher_num, tx_power):
  data_dir = get_dir_path(experiment_enum, "data")
  exp_dirname_pattern = f"{to_cipher_string(cipher_num)}-{tx_power}dbm-trial-*"

  experiment_dirs = list(data_dir.glob(exp_dirname_pattern))
  num_trials = len(experiment_dirs)
  return num_trials

""" I learned that is it possible to use `Path.rename()` to move
    files and directories from:
    https://stackoverflow.com/a/52774612/6621292
"""
def post_process(experiment_enum, cipher_num, tx_power):
  last_trial = get_last_exp_trial(experiment_enum, cipher_num, tx_power)
  trial_num = last_trial + 1

  exp_dir_name = f"{to_cipher_string(cipher_num)}-{tx_power}dbm-trial-{trial_num}"

  data_dir = Path(get_dir_path(experiment_enum, "data").as_posix(), exp_dir_name)
  queue_dir = get_dir_path(experiment_enum, "queue")

  data_dir.mkdir()
  for element in queue_dir.iterdir():
    element.rename(Path(data_dir.as_posix(), element.name))

  print(f"Moved all experiment data from the queue directory and into {data_dir.name}.")
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