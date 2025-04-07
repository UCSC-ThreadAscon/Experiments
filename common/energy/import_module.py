import sys

DIRECTORY = "/Users/simeon/Desktop/Repositories/Experiments/common"

""" All of the code for this function comes from:
    https://stackoverflow.com/a/4383597/6621292
"""
def import_module(module_name):
  sys.path.insert(1, DIRECTORY + "/" + module_name)
  return