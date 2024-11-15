from synology_api import filestation
from dotenv import load_dotenv
from os import getenv
import argparse

load_dotenv()

SYNOLOGY_IP = getenv("SYNOLOGY_IP")
SYNOLOGY_PORT = getenv("SYNOLOGY_PORT")
SYNOLOGY_USERNAME = getenv("SYNOLOGY_USERNAME")
SYNOLOGY_PASSWORD = getenv("SYNOLOGY_PASSWORD")

parser = argparse.ArgumentParser()
parser.add_argument("--otp",
                    help="The one time password given by the Synology Secure SignIn app.",
                    required=True)

fs = filestation.FileStation(SYNOLOGY_IP, SYNOLOGY_PORT, SYNOLOGY_USERNAME,
                             SYNOLOGY_PASSWORD, secure=True, cert_verify=True,
                             debug=True, dsm_version=7, otp_code=parser.otp)

print(fs.get_info())