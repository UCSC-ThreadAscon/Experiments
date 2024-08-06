DELAY_SERVER_PORT=/dev/cu.usbserial-1230
DELAY_CLIENT_PORT=/dev/cu.usbserial-1240

delay-server-aes-20:
	./delay-server.sh -t 20 -e 0 -p $(DELAY_SERVER_PORT)
delay-server-aes-9:
	./delay-server.sh -t 9 -e 0 -p $(DELAY_SERVER_PORT)
delay-server-aes-0:
	./delay-server.sh -t 0 -e 0 -p $(DELAY_SERVER_PORT)

delay-server-ascon128a-20:
	./delay-server.sh -t 20 -e 4 -p $(DELAY_SERVER_PORT)
delay-server-ascon128a-9:
	./delay-server.sh -t 9 -e 4 -p $(DELAY_SERVER_PORT)
delay-server-ascon128a-0:
	./delay-server.sh -t 0 -e 4 -p $(DELAY_SERVER_PORT)

delay-server-ascon128-20:
	./delay-server.sh -t 20 -e 5 -p $(DELAY_SERVER_PORT)
delay-server-ascon128-9:
	./delay-server.sh -t 9 -e 5 -p $(DELAY_SERVER_PORT)
delay-server-ascon128-0:
	./delay-server.sh -t 0 -e 5 -p $(DELAY_SERVER_PORT)

delay-server-noencrypt-20:
	./delay-server.sh -t 20 -e 1 -p $(DELAY_SERVER_PORT)
delay-server-noenrypt-9:
	./delay-server.sh -t 9 -e 1 -p $(DELAY_SERVER_PORT)
delay-server-noencrypt-0:
	./delay-server.sh -t 0 -e 1 -p $(DELAY_SERVER_PORT)

delay-client-aes-20:
	./delay-client.sh -t 20 -e 0 -p $(DELAY_CLIENT_PORT)

delay-client-aes-0:
	./delay-client.sh -t 0 -e 0 -p $(DELAY_CLIENT_PORT)