start=$((16#`objdump -h $1 | grep ".text" | awk -F" " '{print $6}'`))
length=$((16#`objdump -h $1 | grep ".text" | awk -F" " '{print $3}'`))
echo $length bytes
hexdump -v -e '"\\""x" 1/1 "%02x" ""' -s $start -n $length $1
echo
