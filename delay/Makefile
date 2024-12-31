DELAY_SERVER_PORT=/dev/ttyUSB0
DELAY_CLIENT_PORT=/dev/ttyUSB1

clean-queue:
	rm -r -f ./queue/*

post-process:
	rm -f ./queue/full-log.txt ./queue/delay-final-average*
	python3 ./parse.py

# When executing Bash scripts on Ubuntu, I need to use "bash [script name]",
# rather than "./[script name]" on Ubuntu. Otherwise, the script will give a
# syntax error regarding "(".
#	https://stackoverflow.com/a/62929158/6621292

delay-aes-20:
	python3 ../common/coap.py --tx-power 20 --encryption 0 --experiment 0