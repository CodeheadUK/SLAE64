import itertools

table = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

def main():
	message = "HELLO, I AM A TEST MESSAGE!"
	keytext = "TOPSECRET"

	ciphertext = encrypt(message, keytext)

	# Expected result - "ASADS K RQ T MSHL QGJWTZS"
	print(ciphertext)

	cleartext = decrypt(ciphertext, keytext)
	print(cleartext)


def encrypt(clear_text, key_str):
	global table
	key = itertools.cycle(key_str)
	cipher_text = bytearray()
	for ch in clear_text:
		if ch in table:
			row_offset = table.find(ch)
			col_offset = table.find(next(key))
			cipher_text.append(ord(table[(row_offset+col_offset)%26]))
		else:
			cipher_text.append(ord(ch))

	return cipher_text.decode('utf-8')


def decrypt(cipher_text, key_str):
	global table
	key = itertools.cycle(key_str)
	clear_text = bytearray()
	for ch in cipher_text:
		if ch in table:
			row_offset = table.find(ch)
			col_offset = table.find(next(key))
			clear_text.append(ord(table[(row_offset-col_offset)%26]))
		else:
			clear_text.append(ord(ch))

	return clear_text.decode('utf-8')


if __name__ == '__main__':
	main()

