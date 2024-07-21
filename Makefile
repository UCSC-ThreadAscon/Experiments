BORDER_ROUTER_PORT=/dev/cu.usbmodem21401

br_net_perf:
	./border-router/flash.sh -b $(BORDER_ROUTER_PORT)