import subprocess
from subprocess import STDOUT, PIPE

from kasa_wrapper import *
from experiment import *

SHOW_LOGS = False

LEADER_PORT = "/dev/ttyACM0"
SNIFFER_PORT = "/dev/ttyACM1"
CALCULATOR_PORT = "/dev/ttyACM2"

THREAD_NETWORK_CHANNEL = 20

EXPERIMENT_TRIAL_FAILURE = "Going to restart the current experiment trial."
TRIAL_COMPLETION_SUBSTRING = "is now complete."