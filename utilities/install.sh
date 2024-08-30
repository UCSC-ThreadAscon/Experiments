# This script automates the installation process of the ESP-IDF and OpenThread forks
# that use ASCON encryption, based upon the ESP-IDF installation instructions
# for Mac and Linux:
# https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/linux-macos-setup.html#step-2-get-esp-idf
#

# Remove ESP-IDF and the parent "esp" directory, if installed.
rm -r -f $HOME/esp
echo "Removed ESP-IDF Directory."

# Remove the ".espressif" directory, so that when reinstalling ESP-IDF,
# the Python virtual env will use the same version as the native OS.
#
rm -r -f $HOME/.espressif
echo "Removed the ~/.espressif directory."

# Set up the ESP-IDF root repository.
mkdir -p $HOME/esp
cd $HOME/esp
git clone --recursive git@github.com:UCSC-ThreadAscon/esp-idf.git esp-idf

# Installation of ESP-IDF.
cd $HOME/esp/esp-idf
./install.sh all
. $HOME/esp/esp-idf/export.sh