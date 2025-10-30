# find, share, and attach microcontroller to wsl
# needs to be run as admin, wsl must be active

$devices = $(usbipd list | findstr "JTAG")
$l = ($devices | Measure-Object -Line).Lines

for ($i = 0; $i -lt $l; $i++) {
    if ($devices[$i][1] -eq '-') {
        "device found: " + $devices[$i]
        $busid = $devices[$i].Substring(0, 3)
        usbipd bind --busid $busid --force
        usbipd attach --wsl --busid $busid
    }
}

# this is the line that seems to need admin
# I think this line is only needed if your computer
# is unfamiliar with this connection


# done, print devices lines again to show if
# the status has changed to attched
$devices = $(usbipd list | findstr "JTAG")
$l = ($devices | Measure-Object -Line).Lines

for ($i = 0; $i -lt $l; $i++) {
    if ($devices[$i][1] -eq '-') {
        "devices, see updated status: " + $devices[$i]
    }
}
