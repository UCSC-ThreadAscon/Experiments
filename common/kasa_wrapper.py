import asyncio
import serial.tools.list_ports as pyserial_tools
from time import sleep
from kasa import Discover

DEBUG = False
PORT_CONNECT_WAIT_SECONDS = 5

async def get_all_devices():
  devicesDict = await Discover().discover()
  return {device.alias: device for device in devicesDict.values()}

DEVICES = asyncio.run(get_all_devices())

async def power_off(alias):
  await DEVICES[alias].set_state(False)
  if DEBUG:
    print(f"{alias} has been powered off.")
  return

async def power_on(alias):
  await DEVICES[alias].set_state(True)
  if DEBUG:
    print(f"{alias} has been powered on.")
  return

async def power_off_all_devices():
  for device_alias in DEVICES:
    await power_off(device_alias)
  return

def _get_ports(regex):
  return list(pyserial_tools.grep(regex))

def _print_ports(ports):
  for port in ports:
    print(f"{port} has been found.")
  return

async def _assert_no_ports(ports):
  error = "Port(s) "
  for i in range(0, len(ports)):
    port = ports[i]
    error += str(port) + (", " if i < len(ports) - 1 else "")

  error += " found when no ports should have been found. " + \
           "Main USB Hub has ports powered on that should not be powered on."

  if len(ports) > 0:
    await power_off_all_devices()
    raise AssertionError(error)
  else:
    print("0 ports found when no ports should be found.")

  return

async def _assert_num_ports(ports, num_ports):
  error = f"{len(ports)} ports found when {num_ports} ports expected."

  if len(ports) != num_ports:
    await power_off_all_devices()
    raise AssertionError(error)
  else:
    _print_ports(ports)

  return

""" All USB ports in the Main USB Hub has on/off switches to toggle
    on/off the power of a given USB port. Even though the power for a given
     USB port is off, the Main USB Hub will still allow USB data transfer
     for that USB port.

    There are 4 smaller USB hubs that are connected to the USB Hub.
    We do not want the ports Main USB Hub to powered on at the same time
    as the smaller USB Hubs, as it may potentially supply too much power
    to the MCUs (each of which are connected to the smaller USB hubs).

    As a result, we want to check that for each of the 4 smaller USB hubs,
    that the corresponding port that it is plugged into in the Main USB Hub
    is off. If this is not the case, we end the experiment and power of all
    of the smart plugs powering the USB hubs.
  
    RESOUCES UTILIZED:
      https://pyserial.readthedocs.io/en/latest/tools.html#serial.tools.list_ports.grep
      https://stackoverflow.com/a/423596
"""
async def check_main_usb_hub_ports_off():
  global DEBUG
  DEBUG = True
  await power_off_all_devices()
  sleep(PORT_CONNECT_WAIT_SECONDS)

  print("Begin test to check that all Main USB Hub ports are powered off.")
  await power_on("Main USB Hub")
  sleep(PORT_CONNECT_WAIT_SECONDS)

  ports = _get_ports("/dev/ttyACM*")
  await _assert_no_ports(ports)
  
  print("Main USB Hub has no ports powered on.")

  await power_off_all_devices()
  DEBUG = False

  print("All devices have been powered off. Ready to begin experiment.")
  return