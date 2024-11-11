from kasa_wrapper import *
import pytest

def show_instructions(capsys, instructions):
  instructions += " After doing so, press any key to continue."
  with capsys.disabled():
    print(instructions)
    input()
  return

@pytest.mark.asyncio
async def test_main_usb_hub_all_ports_off(capsys):
  instructions = "Please power off ALL ports on the Main USB Hub."
  show_instructions(capsys, instructions)

  await check_main_usb_hub_ports_off()

  stdout = capsys.readouterr().out
  assert("Main USB Hub has no ports powered on." in stdout)
  assert("All devices have been powered off. Ready to begin experiment." in stdout)
  return