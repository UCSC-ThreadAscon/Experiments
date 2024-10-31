import subprocess

subprocess.run(["make", "clean-queue"])

subprocess.run(["make", "tp-con-border-router-aes-20"])
# subprocess.Popen(["make", "tp-con-ftd-aes-20"])