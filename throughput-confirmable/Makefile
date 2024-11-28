# RESOURCES UTILIZED:
# https://stackoverflow.com/a/62929158/6621292
# https://stackoverflow.com/questions/36804181/long-running-py-test-stop-at-first-failure
# https://docs.pytest.org/en/stable/how-to/capture-stdout-stderr.html#setting-capturing-methods-or-disabling-capturing

BORDER_ROUTER_PORT=/dev/cu.usbmodem2101
FTD_PORT=/dev/cu.usbserial-120

clean-queue:
	rm -r -f queue/*

power-off:
	kasa --host 10.0.0.6 off
	kasa --host 10.0.0.8 off
	kasa --host 10.0.0.9 off
	kasa --host 10.0.0.10 off
	kasa --host 10.0.0.11 off
	kasa --host 10.0.0.21 off

tp-con-run-all:
	bash ./run_experiments.sh

test:
	pytest --exitfirst --capture=tee-sys /home/simeon/Desktop/Repositories/Experiments/common/test.py

tp-con-aes-20:
	python3 ../common/main.py --tx-power 20 --encryption 0 --experiment 1