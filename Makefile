BORDER_ROUTER_PORT=/dev/cu.usbmodem1101
br_net_perf:
	./border-router/flash.sh -b $(BORDER_ROUTER_PORT)