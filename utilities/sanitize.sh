# Removes all ANSI escape characters, and NUL characters, from an output text file.
#
# Command line format:
#   sanitize [input filename] [output filename.txt]
#
# Example:
#   sanitize input.txt output.txt
#
# The command I use to remove all ANSI escape chaaracters comes from:
#   https://superuser.com/a/380778
#
# The command I use to remove all NUL characters comes from:
#   https://stackoverflow.com/a/2398400/6621292
#

cat $1 | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | tr -d '\000' &> $2