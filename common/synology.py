from synology_api import filestation
from dotenv import load_dotenv
from os import getenv

load_dotenv()

SYNOLOGY_IP = getenv("SYNOLOGY_IP")
SYNOLOGY_PORT = getenv("SYNOLOGY_PORT")
SYNOLOGY_USERNAME = getenv("SYNOLOGY_USERNAME")
SYNOLOGY_PASSWORD = getenv("SYNOLOGY_PASSWORD")