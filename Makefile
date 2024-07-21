BORDER_ROUTER_PORT=/dev/cu.usbmodem1101

DELAY_SERVER_PORT=/dev/cu.usbserial-1320

br_net_perf:
	./border-router/flash.sh -b $(BORDER_ROUTER_PORT)

delay_server_aes_20:
	./delay/delay_server.sh -t 20 -e 0
delay_server_aes_9:
	./delay/delay_server.sh -t 9 -e 0
delay_server_aes_0:
	./delay/delay_server.sh -t 0 -e 0