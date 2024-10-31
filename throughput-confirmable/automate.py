import subprocess
from multiprocessing import Process

def wrapper(args):
  subprocess.run(args)
  return

if __name__ == "__main__":
  subprocess.run(["make", "clean-queue"])

  Process(target=wrapper, args=[["make", "tp-con-border-router-aes-20"]]).start()
  Process(target=wrapper, args=[["make", "tp-con-ftd-aes-20"]]).start()