import argparse
from pathlib import Path
from enum import Enum
from synology_api_wrapper import upload_folder

RCP_SCRIPT = "/home/simeon/Desktop/Repositories/Experiments/common/rcp.sh"
BORDER_ROUTER_SCRIPT = \
  "/home/simeon/Desktop/Repositories/Experiments/common/border_router.sh"
FTD_SCRIPT = "/home/simeon/Desktop/Repositories/Experiments/common/ftd.sh"

class Experiment(Enum):
  DELAY=0
  THROUGHPUT_CONFIRMABLE=1
  PACKET_LOSS_CONFIRMABLE=2
  THROUGHPUT_UDP=3

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

def get_exp_filename_prefix(experiment_enum):
  match experiment_enum:
    case Experiment.DELAY.value:
      return "delay"
    case Experiment.THROUGHPUT_CONFIRMABLE.value:
      return "tp-con"
    case Experiment.PACKET_LOSS_CONFIRMABLE.value:
      return "pl-con"
    case Experiment.THROUGHPUT_UDP.value:
      return "tp-udp"
    case _:
      raise Exception("Invalid Enum value for Experiment: {experiment_enum}.")

def get_dir_path(experiment_enum, subdir_name):
  experiment_dir = ""

  match experiment_enum:
    case Experiment.DELAY.value:
      experiment_dir = "delay"
    case Experiment.THROUGHPUT_CONFIRMABLE.value:
      experiment_dir = "throughput-confirmable"
    case Experiment.PACKET_LOSS_CONFIRMABLE.value:
      experiment_dir = "packet-loss-confirmable"
    case Experiment.THROUGHPUT_UDP.value:
      experiment_dir = "throughput-udp"
    case _:
      raise Exception("Invalid Enum value for Experiment: {experiment_enum}.")

  if subdir_name == None:
    return Path(Path.home(), "Desktop", "Repositories", "Experiments", experiment_dir)
  else:
    return Path(Path.home(), "Desktop", "Repositories", "Experiments",experiment_dir,
                subdir_name)

def get_nas_exp_dir_string(experiment_enum):
  dirname = None
  match experiment_enum:
    case Experiment.DELAY.value:
      dirname = "Delay"
    case Experiment.THROUGHPUT_CONFIRMABLE.value:
      dirname = "Throughput-Confirmable"
    case Experiment.PACKET_LOSS_CONFIRMABLE.value:
      dirname = "Packet-Loss-Confirmable"
    case Experiment.THROUGHPUT_UDP.value:
      dirname = "Throughput-UDP"
    case _:
      raise Exception(f"{experiment_enum} is not a valid Experiment Enum.")
  return "/Thesis-Experiments-Data/" + dirname

def get_last_exp_trial(experiment_enum, cipher_num, tx_power):
  data_dir = get_dir_path(experiment_enum, "data")
  exp_dirname_pattern = f"{to_cipher_string(cipher_num)}-{tx_power}dbm-trial-*"

  experiment_dirs = list(data_dir.glob(exp_dirname_pattern))
  num_trials = len(experiment_dirs)
  return num_trials

def upload_experiment_data(experiment_enum, queue_path, dirname):
  nas_path_str = get_nas_exp_dir_string(experiment_enum) + f"/{dirname}"
  upload_folder(queue_path, nas_path_str)

  print("Experiment data has been uploaded to the Synology NAS.")
  return

""" I learned that is it possible to use `Path.rename()` to move
    files and directories from:
    https://stackoverflow.com/a/52774612/6621292
"""
def post_process(experiment_enum, cipher_num, tx_power, dirname_suffix):
  last_trial = get_last_exp_trial(experiment_enum, cipher_num, tx_power)
  trial_num = last_trial + 1

  exp_dir_name = f"{to_cipher_string(cipher_num)}-{tx_power}dbm-trial-{trial_num}"
  if dirname_suffix != None:
    exp_dir_name += dirname_suffix

  data_dir = Path(get_dir_path(experiment_enum, "data").as_posix(), exp_dir_name)
  queue_dir = get_dir_path(experiment_enum, "queue")

  # Upload the experiment data to the Synology Server.
  upload_experiment_data(experiment_enum, queue_dir, exp_dir_name)

  # Move the experiment data to the local `data` folder.
  data_dir.mkdir()
  for element in queue_dir.iterdir():
    element.rename(Path(data_dir.as_posix(), element.name))

  print(f"Moved the experiment data from the queue directory and into {data_dir.name}.")
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

  helper_text = \
    """The network performance experiment to run.
        
       Set the flag to '0' to run the Delay experiment.
       Set the flag to '1' to run the Throughput Confirmable experiment.
       Set the flag to '2' to run the Packet Loss Confirmable experiment.
    """
  parser.add_argument("--experiment", help=helper_text, required=True)
  return parser

def get_leader_name(experiment_num):
  match (experiment_num):
    case Experiment.DELAY.value:
      return "Delay Server"
    case Experiment.THROUGHPUT_UDP.value:
      return "Full Thread Device"
    case _:
      return "Border Router"

def get_leader_script(experiment_num):
  if (experiment_num == Experiment.DELAY.value) or \
     (experiment_num == Experiment.THROUGHPUT_UDP.value):
    return FTD_SCRIPT
  else:
    return BORDER_ROUTER_SCRIPT

def get_leader_file_abbr(experiment_num):
  match (experiment_num):
    case Experiment.DELAY.value:
      return "server"
    case Experiment.THROUGHPUT_UDP.value:
      return "FTD"
    case _:
      return "BR"

def get_calculator_name(experiment_num):
  match (experiment_num):
    case Experiment.THROUGHPUT_UDP.value:
      return "Border Router"
    case _:
      return "Full Thread Device"

def get_calculator_script(experiment_num):
  match (experiment_num):
    case Experiment.THROUGHPUT_UDP.value:
      return BORDER_ROUTER_SCRIPT
    case _:
      return FTD_SCRIPT

def get_calculator_file_abbr(experiment_num):
  match (experiment_num):
    case Experiment.THROUGHPUT_UDP.value:
      return "BR"
    case _:
      return "FTD"