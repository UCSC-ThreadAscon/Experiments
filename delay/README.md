# Delay Experiments

This README describes how to use the scripts in order to run the Delay experiments.

## Starting The Experiment

1. Make sure the nRF52840 dongle or development kit is configured to operate as an 802.15.4 packet sniffer.
   Plug the nRF42840 device onto your computer, and make sure it is powered on.

   Start up Wireshark, and make it listen for packets on the nRF52840 interface.

2. Make sure the ESP32-H2 that is the Delay server is plugged into your computer and powered on.
   Open one terminal window, and cd to `/delay`. Run the following command:

   ```bash
   make delay-server-[cipher]-[txpower]
   ```

   to start the Delay server.

   Replace `[cipher]` with either `aes`, `ascon128a`, or `ascon128`, depending on which encryption algorithm
   you will use for the experiment. If running the experiment in plaintext, replace `[cipher]` with `noencrypt`.

   Replace `[txpower]` with either `0`, `9`, or `20`, to for the Delay server to run at a TX power of
   0 dBm, 9 dBm, or 20 dBm, respectively.

   Wait for the Delay server to form a Thread network with *itself* as the Leader before moving
   on the next step.
   
   **Note** that the Delay client must be *off* when following this step
   Given that Linux USB serial ports `/dev/tty*` are numbered in the order in which
   the devices were connected, connecting the Delay client ESP32-H2
   first may result in it being flashed the Delay server program.

3. Make sure the ESP32-H2 that is the Delay client is plugged into your computer and powered on.
   Open another terminal, cd to `/delay`, and run the following command:

   ```bash
   make delay-client-[cipher]-[txpower]
   ```

   to start the Delay client. Make sure that both `[cipher]` and `[txpower]` are using the *same exact values*
   that you used when starting the Delay server.

4. Wait for the Delay client the 100 trials to run automatically. Once the Delay client has
   finished running all the trials, you are free to stop the processes on both terminal windows.

5. Save the Wireshark packet capture file under the following name:

   ```
   delay-pcap-[cipher]-[txpower]dbm.pcapng
   ```
   
   Make sure that both `[cipher]` and `[txpower]` are using the *same exact values*
   that you used when starting the Delay client and server.

6. Create a `NOTES.md` file where you document the activity occuring in the experimental setup (i.e. the house the experiment is taking place in) during the experiment.

## Post Processing

1. Run the following command:

   ```bash
   make post-process
   ```

  The command will result in two files in `/queue`: `full-log.txt` and
  `delay-final-average-[cipher]-[txpower]dbm.txt`.

2. Create a new directory with the name:

  ```
  delay-[cipher]-[txpower]-trial-[trial number]
  ```

  Where `[trial number]` is the `nth` attempt (trial) that you have done for the current experiment,
  given specified encryption algorithm (i.e. `[cipher]`) and TX power (i.e. `[txpower]`).

  Move all files in `queue` into this new directory, and move the directory into `/data`.


3. Commit and push all changes. In addition, store all of files in `/delay-[cipher]-[txpower]-trial-[trial number]`
   in the Synology NAS and locally on an external SSD.

   Note that I used to store files on Github, but I do not do so anymore, as the files tend to be very large.

After following these steps, you have completed a Delay experiment, given the specified
`[cipher]`, and `[txpower]` independent variables.