# RESOURCES UTILIZED:
# https://ryanstutorials.net/bash-scripting-tutorial/bash-if-statements.php#case
#
case $1 in
  "AES") echo 0 ;;
  "NoEncrypt") echo 1 ;;
  "LibAscon-128a") echo 4 ;;
  "LibAscon-128") echo 5;;
esac