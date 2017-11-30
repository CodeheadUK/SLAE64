# Shellcode extraction tool
# Dumps raw code from .text section of ELF files
# Output in 'C' style and Python arrays

start=$((16#`objdump -h $1 | grep -i ".text" | awk -F" " '{print $6}'`))
length=$((16#`objdump -h $1 | grep -i ".text" | awk -F" " '{print $3}'`))
echo $length bytes
hexdump -v -e '"\\""x" 1/1 "%02x" ""' -s $start -n $length $1
echo
hexdump -v -e '"0x" 1/1 "%02x," ""' -s $start -n $length $1
echo
