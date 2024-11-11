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
  await power_off("Main USB Hub")
  await power_off("Border Router")
  await power_off("Radio Co-Processor")
  await power_off("Full Thread Device")
  await power_off("Packet Sniffer")
  return

def _get_ports(regex):
  return list(pyserial_tools.grep(regex))

def _print_ports(ports):
  for port in ports:
    print(f"{port} has been found.")
  return

def _assert_no_ports(ports):
  error = f"Ports {ports} found when no ports should have been found. " + \
            "Main USB has ports powered on they should not be on."
  if len(ports) > 0:
    raise AssertionError(error)
  else:
    _print_ports(ports)
  return

def _assert_num_ports(ports, num_ports):
  error = f"{len(ports)} found when {num_ports} ports expected."
  if len(ports != num_ports):
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

    https://pyserial.readthedocs.io/en/latest/tools.html#serial.tools.list_ports.grep
"""
async def check_main_usb_hub_ports_off():
  try:
    print("Begin test to check that that all Main USB Hub ports are powered off.")
    await power_on("Main USB Hub")

    ports = _get_ports("/dev/ttyACM*")
    _assert_no_ports(ports)

    print("Powering on nRF Sniffer, FTD, and RCP.")
    await power_on("Packet Sniffer")
    await power_on("Full Thread Device")
    await power_on("Radio Co-Processor")
    sleep(PORT_CONNECT_WAIT_SECONDS)

    ports = _get_ports("/dev/ttyACM*")
    _assert_num_ports(ports, 3)

    print("Powering off nRF Sniffer, FTD, and RCP.")
    await power_off("Packet Sniffer")
    await power_off("Full Thread Device")
    await power_off("Radio Co-Processor")
    sleep(PORT_CONNECT_WAIT_SECONDS)

    print("Powering on nRF Sniffer, FTD, and Border Router Host.")
    await power_on("Packet Sniffer")
    await power_on("Full Thread Device")
    await power_on("Border Router")

    ports = _get_ports("/dev/ttyACM*")
    _assert_no_ports(ports)

    ports = _get_ports("/dev/ttyACM*")
    _assert_num_ports(ports, 3)
    
    print("Main USB Hub has no ports powered on. Ready to begin experiment.")
    await power_off_all_devices()
  except AssertionError:
    await power_off_all_devices()
  return