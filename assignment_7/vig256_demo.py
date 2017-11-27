import itertools
import sys

def main():
	message = b"HELLO, I AM A TEST MESSAGE!"
	#message = [0x68, 0x73, 0x77, 0x64, 0x01, 0x48, 0xbb, 0x2f, 0x65, 0x74, 0x63, 0x2f,
	#		   0x70, 0x61, 0x73, 0x53, 0x48, 0x89, 0xe7, 0xfe, 0x4f, 0x0b, 0x6a, 0x02,
	#		   0x48, 0x29, 0xf6, 0x58, 0x0f, 0x05, 0x50, 0x48, 0x96, 0x50, 0x5a, 0x5f,
	#		   0x66, 0x81, 0xea, 0x01, 0xf0, 0x48, 0x29, 0xd4, 0x48, 0x8d, 0x34, 0x24,
	#		   0x0f, 0x05, 0x6a, 0x01, 0x5a, 0x48, 0x92, 0x50, 0x5f, 0x0f, 0x05, 0x6a,
	#		   0x3c, 0x58, 0x0f, 0x05]
	keytext = b"TOPSECRET"

	out = encrypt(message, keytext)
	dump_hex(out)

	out = decrypt(out, keytext)
	dump_hex(out)

	print(out.decode('utf-8'))


def encrypt(clear_text, keystr):
	key = itertools.cycle(keystr)
	cipher_text = bytearray()
	for ch in clear_text:
		offset = next(key)
		cipher_text.append((ch+offset)%256)

	return cipher_text


def decrypt(cipher_text, keystr):
	key = itertools.cycle(keystr)
	clear_text = bytearray()
	for ch in cipher_text:
		offset = next(key)
		clear_text.append((ch-offset)%256)

	return clear_text


def dump_hex(hexarray):
	for h in hexarray:
		sys.stdout.write('\\' + hex(h)[1:])
	print("")

if __name__ == '__main__':
	main()