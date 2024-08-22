# This script automates the installation process of the ESP-IDF and OpenThread forks
# that use ASCON encryption, based upon the ESP-IDF installation instructions
# for Mac and Linux:
# https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/linux-macos-setup.html#step-2-get-esp-idf
#

# Remove ESP-IDF and the parent "esp" directory, if installed.
rm -r -f $HOME/esp
echo "Removed ESP-IDF Directory."

# Set up the ESP-IDF root repository.
mkdir -p $HOME/esp
cd $HOME/esp
git clone -b v5.3 --recursive git@github.com:UCSC-ThreadAscon/esp-idf.git esp-idf

# Installation of ESP-IDF.
cd $HOME/esp/esp-idf
./install.sh all
. $HOME/esp/esp-idf/export.sh