BORDER_ROUTER_PORT=/dev/cu.usbmodem1101

DELAY_SERVER_PORT=/dev/cu.usbserial-1320

br_net_perf:
	./border-router/flash.sh -b $(BORDER_ROUTER_PORT)

delay_server:
	./delay/delay_server.sh -t 20 -e 0