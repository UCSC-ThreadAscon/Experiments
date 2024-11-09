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