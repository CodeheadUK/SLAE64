#include<stdio.h>
#include<string.h>

unsigned char code[] = \
"{Paste Shellcode here in \x90\x90\x90\x90 format}";

main()
{

	printf("Shellcode Length:  %d\n", (int)strlen(code));

	int (*ret)() = (int(*)())code;

	ret();

}
