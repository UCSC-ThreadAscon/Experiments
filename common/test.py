from kasa_wrapper import *
import pytest

def show_instructions(capsys):
  with capsys.disabled():
    instructions = "Please power off ALL ports on the Main USB Hub. " + \
                   "After doing so, press any key to continue."
    print(instructions)
    input()
  return


@pytest.mark.asyncio
async def test_main_usb_hub_all_ports_off(capsys):
  show_instructions(capsys)

  await check_main_usb_hub_ports_off()

  stdout = capsys.readouterr().out
  assert("Main USB Hub has no ports powered on." in stdout)
  assert("All devices have been powered off. Ready to begin experiment." in stdout)
  return