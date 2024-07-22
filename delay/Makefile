DELAY_SERVER_PORT=/dev/cu.usbserial-130
DELAY_CLIENT_PORT=/dev/cu.usbserial-140

delay_server_aes_20:
	./delay_server.sh -t 20 -e 0 -p $(DELAY_SERVER_PORT)
delay_server_aes_9:
	./delay_server.sh -t 9 -e 0 -p $(DELAY_SERVER_PORT)
delay_server_aes_0:
	./delay_server.sh -t 0 -e 0 -p $(DELAY_SERVER_PORT)

delay_server_ascon128a_20:
	./delay_server.sh -t 20 -e 4 -p $(DELAY_SERVER_PORT)
delay_server_ascon128a_9:
	./delay_server.sh -t 9 -e 4 -p $(DELAY_SERVER_PORT)
delay_server_ascon128a_0:
	./delay_server.sh -t 0 -e 4 -p $(DELAY_SERVER_PORT)

delay_server_ascon128_20:
	./delay_server.sh -t 20 -e 5 -p $(DELAY_SERVER_PORT)
delay_server_ascon128_9:
	./delay_server.sh -t 9 -e 5 -p $(DELAY_SERVER_PORT)
delay_server_ascon128_0:
	./delay_server.sh -t 0 -e 5 -p $(DELAY_SERVER_PORT)

delay_server_noencrypt_20:
	./delay_server.sh -t 20 -e 1 -p $(DELAY_SERVER_PORT)
delay_server_noenrypt_9:
	./delay_server.sh -t 9 -e 1 -p $(DELAY_SERVER_PORT)
delay_server_noencrypt_0:
	./delay_server.sh -t 0 -e 1 -p $(DELAY_SERVER_PORT)

delay_client_aes_20:
	./delay_client.sh -t 20 -e 0 -p $(DELAY_CLIENT_PORT)