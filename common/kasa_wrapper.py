import asyncio
from kasa import Discover

async def get_all_devices():
  return {device.alias: device for device in await Discover().values()}