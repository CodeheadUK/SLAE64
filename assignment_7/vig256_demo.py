import itertools
import sys

def main():
	message = b"HELLO, I AM A TEST MESSAGE!"
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
