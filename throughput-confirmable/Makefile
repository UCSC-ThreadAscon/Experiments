BORDER_ROUTER_PORT=/dev/ttyUSB0
FTD_PORT=/dev/ttyUSB1

# When executing Bash scripts on Ubuntu, I need to use "bash [script name]",
# rather than "./[script name]" on Ubuntu. Otherwise, the script will give a
# syntax error regarding "(".
#	https://stackoverflow.com/a/62929158/6621292

tp-con-border-router-aes-20:
	bash ./border_router.sh -t 20 -e 0 -p $(BORDER_ROUTER_PORT)