BORDER_ROUTER_PORT=/dev/cu.usbmodem1401

NET_PERF_FILE_LOC=~/Desktop/Repositories/br_netperf/examples/basic_thread_border_router
ENERGY_FILE_LOC=~/Desktop/Repositories/br_energy/examples/basic_thread_border_router

br-netperf:
	./br-flash.sh -p $(BORDER_ROUTER_PORT) -f $(NET_PERF_FILE_LOC)

br-energy:
	./br-flash.sh -p $(BORDER_ROUTER_PORT) -f $(ENERGY_FILE_LOC)

update:
	./update.sh