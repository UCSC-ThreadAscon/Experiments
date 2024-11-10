import asyncio
from kasa import Discover

DEBUG = True

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
"""
async def check_main_usb_hub_ports_off():
  return