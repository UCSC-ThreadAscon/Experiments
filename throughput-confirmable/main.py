from subprocess import Popen, run, STDOUT

if __name__ == "__main__":
  run(["make", "clean-queue"])

  process = Popen(["make", "tp-con-border-router-aes-20"], stderr=STDOUT)
  process.wait()