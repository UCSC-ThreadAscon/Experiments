from synology_api import filestation
from dotenv import load_dotenv
from pathlib import Path
import argparse
import os

from experiment import get_dir_path, Experiment

load_dotenv()

SYNOLOGY_IP = os.getenv("SYNOLOGY_IP")
SYNOLOGY_PORT = os.getenv("SYNOLOGY_PORT")
SYNOLOGY_USERNAME = os.getenv("SYNOLOGY_USERNAME")
SYNOLOGY_PASSWORD = os.getenv("SYNOLOGY_PASSWORD")

parser = argparse.ArgumentParser()

parser.add_argument("--otp",
                    help="The one time password given by the Synology Secure SignIn app.",
                    required=True)

def get_nas_exp_dir_string(experiment_enum):
  dirname = None
  match experiment_enum:
    case Experiment.DELAY.value:
      dirname = "Delay-Experiments"
    case Experiment.THROUGHPUT_CONFIRMABLE.value:
      dirname = "Throughput-Confirmable-Experiments"
    case _:
      raise Exception(f"{experiment_enum} is not a valid Experiment Enum.")
  return "/home/Master's Thesis/" + dirname + "/Results"

""" RESCOURCES UTILIZED
    https://www.python-engineer.com/posts/check-if-file-exists
    https://stackoverflow.com/a/48191073
"""
def upload_folder(fs, local_path, nas_path_str):
  for element in local_path.iterdir():

    if element.is_dir():
      fs.create_folder(folder_path=nas_path_str, name=element.name)
      upload_folder(fs, local_path / element.name, nas_path_str + f"/{element.name}")

    elif element.is_file():
      file_path = local_path / element
      fs.upload_file(dest_path=nas_path_str,
                     file_path=file_path.as_posix(),
                     overwrite=False,
                     progress_bar=True)

  return


if __name__ == "__main__":
  args = parser.parse_args()
  fs = filestation.FileStation(SYNOLOGY_IP, SYNOLOGY_PORT, SYNOLOGY_USERNAME,
                              SYNOLOGY_PASSWORD, secure=True, cert_verify=False,
                              debug=True, dsm_version=7,
                              otp_code=args.otp)

  for exp_enum in Experiment.__iter__():
    local_data_dir = get_dir_path(exp_enum.value, "data")
    nas_data_dir_string = get_nas_exp_dir_string(exp_enum.value)

    upload_folder(fs, local_data_dir, nas_data_dir_string)