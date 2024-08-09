test=$(cat delay-client-AES-20dbm.txt | grep "The AVERAGE delay is:" | awk '{print $8}')
echo $test