from subprocess import Popen, run, PIPE

if __name__ == "__main__":
  # subprocess.run(["make", "clean-queue"])

  process = Popen(["bash", "./border_router.sh", "-t" ,"20", "-e", "0", "-p", "/dev/cu.usbmodem2101"],
                   stdout=PIPE, stderr=PIPE)
  process.wait()