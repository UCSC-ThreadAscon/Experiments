""" The source code in this file imports all the Python modules
    defined in the "common" directory in this repository, even when
    the caller is running in a Python script that is defined outside
    of "/common".

    The code to import Python modules in different directories
    comes from:
    https://pieriantraining.com/importing-a-module-from-a-different-directory-in-python/
"""
import sys
from pathlib import Path

COMMON_DIR_PATH = Path(Path.home(), "Desktop", "Repositories", "Experiments", "common")

def import_common():
  sys.path.append(str(COMMON_DIR_PATH))
  return