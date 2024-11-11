from kasa_wrapper import *
import pytest

def show_instructions(instructions):
  instructions += " After doing so, press any key to continue."
  print(instructions)
  input()
  return

@pytest.mark.asyncio(loop_scope="module")
async def test_main_usb_hub_all_ports_off(capsys):
  with capsys.disabled():
    instructions = "Please POWER OFF ALL PORTS on the Main USB Hub."
    show_instructions(instructions)

  await check_main_usb_hub_ports_off()

  stdout = capsys.readouterr().out
  assert("Main USB Hub has no ports powered on." in stdout)
  assert("All devices have been powered off. Ready to begin experiment." in stdout)
  return

@pytest.mark.asyncio(loop_scope="module")
async def test_main_usb_hub_sniffer_on():
  instructions = "Please POWER ON ONLY the NRF SNIFFER port on the Main USB Hub."
  show_instructions(instructions)

  with pytest.raises(AssertionError):
    await check_main_usb_hub_ports_off()
  return