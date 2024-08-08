The ESP-IDF serial monitor is an interactive terminal. As a result,
`tee` may print out weird characters when copying over the contents
of the serial monitor to an output file.

Upon doing further investigation, it seems that these weird characters
are mostly ANSI color codes. If I use the VSCode ANSI Colors extension,
then most of the red icons would disappear and I would see the ANSI colors.