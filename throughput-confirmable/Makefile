BORDER_ROUTER_PORT=/dev/cu.usbmodem2101
FTD_PORT=/dev/cu.usbserial-120

clean-queue:
	rm -r -f queue/*

# When executing Bash scripts on Ubuntu, I need to use "bash [script name]",
# rather than "./[script name]" on Ubuntu. Otherwise, the script will give a
# syntax error regarding "(".
#	https://stackoverflow.com/a/62929158/6621292

tp-con-aes-20:
	python3 ./main.py --tx-power 20 -encryption 0

tp-con-border-router-aes-20:
	bash ./border_router.sh -t 20 -e 0 -p $(BORDER_ROUTER_PORT)
tp-con-border-router-aes-9:
	bash ./border_router.sh -t 9 -e 0 -p $(BORDER_ROUTER_PORT)
tp-con-border-router-aes-0:
	bash ./border_router.sh -t 0 -e 0 -p $(BORDER_ROUTER_PORT)

tp-con-border-router-noencrypt-20:
	bash ./border_router.sh -t 20 -e 1 -p $(BORDER_ROUTER_PORT)
tp-con-border-router-noencrypt-9:
	bash ./border_router.sh -t 9 -e 1 -p $(BORDER_ROUTER_PORT)
tp-con-border-router-noencrypt-0:
	bash ./border_router.sh -t 0 -e 1 -p $(BORDER_ROUTER_PORT)

tp-con-border-router-ascon128a-20:
	bash ./border_router.sh -t 20 -e 4 -p $(BORDER_ROUTER_PORT)
tp-con-border-router-ascon128a-9:
	bash ./border_router.sh -t 9 -e 4 -p $(BORDER_ROUTER_PORT)
tp-con-border-router-ascon128a-0:
	bash ./border_router.sh -t 0 -e 4 -p $(BORDER_ROUTER_PORT)

tp-con-border-router-ascon128-20:
	bash ./border_router.sh -t 20 -e 5 -p $(BORDER_ROUTER_PORT)
tp-con-border-router-ascon128-9:
	bash ./border_router.sh -t 9 -e 5 -p $(BORDER_ROUTER_PORT)
tp-con-border-router-ascon128-0:
	bash ./border_router.sh -t 0 -e 5 -p $(BORDER_ROUTER_PORT)

tp-con-rcp-aes:
	bash ./rcp.sh -e 0 -p $(BORDER_ROUTER_PORT)
tp-con-rcp-noencrypt:
	bash ./rcp.sh -e 1 -p $(BORDER_ROUTER_PORT)
tp-con-rcp-ascon128a:
	bash ./rcp.sh -e 4 -p $(BORDER_ROUTER_PORT)
tp-con-rcp-ascon128:
	bash ./rcp.sh -e 5 -p $(BORDER_ROUTER_PORT)

tp-con-ftd-aes-20:
	bash ./ftd.sh -t 20 -e 0 -p $(FTD_PORT)
tp-con-ftd-aes-9:
	bash ./ftd.sh -t 9 -e 0 -p $(FTD_PORT)
tp-con-ftd-aes-0:
	bash ./ftd.sh -t 0 -e 0 -p $(FTD_PORT)

tp-con-ftd-noencrypt-20:
	bash ./ftd.sh -t 20 -e 1 -p $(FTD_PORT)
tp-con-ftd-noencrypt-9:
	bash ./ftd.sh -t 9 -e 1 -p $(FTD_PORT)
tp-con-ftd-noencrypt-0:
	bash ./ftd.sh -t 0 -e 1 -p $(FTD_PORT)

tp-con-ftd-ascon128a-20:
	bash ./ftd.sh -t 20 -e 4 -p $(FTD_PORT)
tp-con-ftd-ascon128a-9:
	bash ./ftd.sh -t 9 -e 4 -p $(FTD_PORT)
tp-con-ftd-ascon128a-0:
	bash ./ftd.sh -t 0 -e 4 -p $(FTD_PORT)

tp-con-ftd-ascon128-20:
	bash ./ftd.sh -t 20 -e 5 -p $(FTD_PORT)
tp-con-ftd-ascon128-9:
	bash ./ftd.sh -t 9 -e 5 -p $(FTD_PORT)
tp-con-ftd-ascon128-0:
	bash ./ftd.sh -t 0 -e 5 -p $(FTD_PORT)