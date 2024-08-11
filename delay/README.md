# Delay Experiments

This README describes how to use the scripts in order to run the Delay experiments.

## Starting The Experiment




1. Run the Makefile commands to start the Delay Server and Client.

2. Let the 100 trials run automatically. Save the output to text files.
   Don't remove any escape characters. We want the raw, unedited, output
   from the logs.

   What you get from the logs is what you get from the logs! You do not want
   to edit or tamper with the logs in any way whatsoever! However, you can make
   a script to make a copy of the logs that is more human readable.

3. Create a script to parse through the log files and to calculate the average
   for all the trials, for the given experiment. Save the average Delay
   in both a file and in a PostgreSQL database.