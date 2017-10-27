// Paste shellcode into the code[] array in \x90\x90\x90\x90 format
// Compile with: 
//      gcc -z execstack -fno-stack-protector shellcode_wrapper.c -o shellcode

#include<stdio.h>
#include<string.h>
 
unsigned char code[] = \
"\x90\x90\x90\x90";

main()
{

	printf("Shellcode Length:  %d\n", (int)strlen(code));

	int (*ret)() = (int(*)())code;

	ret();

}
