import asyncio
from kasa import Discover

async def _get_all_devices():
  devicesDict = await Discover().discover()
  return {device.alias: device for device in devicesDict.values()}

DEVICES = asyncio.run(_get_all_devices())

def power_off(alias):
  async def _power_off(alias):
    await DEVICES[alias].turn_off()
    print(f"{alias} has been powered off.")
    return

  return asyncio.run(_power_off(alias))

def power_on(alias):
  async def _power_on(alias):
    await DEVICES[alias].turn_on()
    print(f"{alias} has been powered on.")
    return

  return asyncio.run(_power_on(alias))