import argparse
import itertools
import sys

def main():

	args = setArgs()

	sc = args.shellcode.split(',')
	enc = encrypt(sc, args.key)

	print("\nHex Shellcode")
	dumpHexCode(enc)
	print("\nC Style Array")
	dumpCodeArray(enc)


def encrypt(clear, keystr):
	key = itertools.cycle(keystr)
	cipher = bytearray()
	for b in clear:
		offset = ord(next(key))
		cipher.append((int(b, 16)+offset)%256)

	return cipher


def dumpHexCode(code):
	nChars = 0
	for c in code:
		sys.stdout.write("0x{0:02x},".format(c))
		nChars+=1
		if nChars == 10:
			sys.stdout.write("\n")
			nChars = 0

def dumpCodeArray(code):
	nChars = 0
	sys.stdout.write("\"")
	for c in code:
		sys.stdout.write("\\x{0:02x}".format(c))
		nChars+=1
		if nChars == 10:
			sys.stdout.write("\"\n\"")
			nChars = 0
	sys.stdout.write("\";\n")

def setArgs():
	parser = argparse.ArgumentParser(description='Vigenere ecrypt shellcode')
	parser.add_argument('shellcode', help='A shellcode string in 0xXX,0xXX,0xXX format.')
	parser.add_argument('key', help='The encryption key string')

	return parser.parse_args()

if __name__ == '__main__':
	main()
