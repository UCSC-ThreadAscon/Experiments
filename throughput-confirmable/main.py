from subprocess import Popen, run, STDOUT

if __name__ == "__main__":
  # subprocess.run(["make", "clean-queue"])

  process = Popen(["bash", "./border_router.sh", "-t" ,"20", "-e", "0", "-p", "/dev/cu.usbmodem2101"],
                  stderr=STDOUT)
  process.wait()