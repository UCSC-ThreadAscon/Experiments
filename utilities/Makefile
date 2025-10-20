BORDER_ROUTER_PORT=/dev/cu.usbmodem1401

NET_PERF_FILE_LOC=~/Desktop/Repositories/br_netperf/examples/basic_thread_border_router
ENERGY_FILE_LOC=~/Desktop/Repositories/br_energy/examples/basic_thread_border_router

# When executing Bash scripts on Ubuntu, I need to use "bash [script name]",
# rather than "./[script name]" on Ubuntu. Otherwise, the script will give a
# syntax error regarding "(".
#	https://stackoverflow.com/a/62929158/6621292

br-netperf:
	bash ./br-flash.sh -p $(BORDER_ROUTER_PORT) -f $(NET_PERF_FILE_LOC)

br-energy:
	bash ./br-flash.sh -p $(BORDER_ROUTER_PORT) -f $(ENERGY_FILE_LOC)

update-commits: update
	bash ./update-commits.sh

update:
	bash ./update.sh

install:
	bash ./install.sh

wsl:
	.\attach-wsl.ps1