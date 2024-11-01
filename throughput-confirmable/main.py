"""RESOURCES UTILIZED
   https://shuzhanfan.github.io/2017/12/parallel-processing-python-subprocess/
"""

from subprocess import Popen, run, STDOUT, PIPE

if __name__ == "__main__":
  run(["make", "clean-queue"])

  br_process = Popen(["make", "tp-con-border-router-aes-20"], stderr=STDOUT)

  # br_process.wait()