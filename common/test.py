from kasa_wrapper import *
import pytest

def show_instructions(instructions):
  instructions += " After doing so, press any key to continue."
  print(instructions)
  input()
  return

# @pytest.mark.asyncio(loop_scope="module")
# async def test_main_usb_hub_all_ports_off(capsys):
#   with capsys.disabled():
#     instructions = "Please POWER OFF ALL PORTS on the Main USB Hub."
#     show_instructions(instructions)

#   await check_main_usb_hub_ports_off()

#   stdout = capsys.readouterr().out
#   assert("Main USB Hub has no ports powered on." in stdout)
#   assert("All devices have been powered off. Ready to begin experiment." in stdout)
#   return

@pytest.mark.asyncio(loop_scope="module")
async def test_main_usb_hub_three_ports_on():
  instructions = "Please POWER ON ANY THREE PORTS on the Main USB Hub AT THE SAME TIME."
  instructions += "DO NOT power on both the Border Router and RCP at the same time."
  show_instructions(instructions)

  with pytest.raises(AssertionError) as exception_info:
    await check_main_usb_hub_ports_off()

  assert(exception_info.type == AssertionError)

  error_message = str(exception_info.value)

  assert(error_message.count("/dev/ttyACM") == 3)
  assert("Main USB Hub has ports powered on that should not be powered on."
          in error_message)
  return

@pytest.mark.asyncio(loop_scope="module")
async def test_main_usb_hub_one_port_on():
  instructions = "Please POWER ON ONLY A SINGLE PORT on the Main USB Hub."
  show_instructions(instructions)

  with pytest.raises(AssertionError) as exception_info:
    await check_main_usb_hub_ports_off()

  assert(exception_info.type == AssertionError)

  error_message = str(exception_info.value)

  assert(error_message.count("/dev/ttyACM") == 1)
  assert("Main USB Hub has ports powered on that should not be powered on."
          in error_message)
  return