from synology_api import filestation
from dotenv import load_dotenv
import os

load_dotenv()

SYNOLOGY_IP = os.getenv("SYNOLOGY_IP")
SYNOLOGY_PORT = os.getenv("SYNOLOGY_PORT")
SYNOLOGY_USERNAME = os.getenv("SYNOLOGY_USERNAME")
SYNOLOGY_PASSWORD = os.getenv("SYNOLOGY_PASSWORD")

""" RESCOURCES UTILIZED
    https://www.python-engineer.com/posts/check-if-file-exists
    https://stackoverflow.com/a/48191073
"""
def upload_folder(local_path, nas_path_str):
  fs = filestation.FileStation(SYNOLOGY_IP, SYNOLOGY_PORT, SYNOLOGY_USERNAME,
                               SYNOLOGY_PASSWORD, secure=True, cert_verify=False,
                               debug=True, dsm_version=7)

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