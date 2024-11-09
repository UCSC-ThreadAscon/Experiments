""" The source code in this file adds to the environment path of the calling Python script
    all modules defined in the "common" directory of this repository.

    The code to import Python modules in different directories
    comes from:
    https://pieriantraining.com/importing-a-module-from-a-different-directory-in-python/
"""
import sys
from pathlib import Path

COMMON_DIR_PATH = Path(Path.home(), "Desktop", "Repositories", "Experiments", "common")

def add_common_to_path():
  sys.path.append(str(COMMON_DIR_PATH))
  return