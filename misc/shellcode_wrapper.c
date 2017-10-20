#include<stdio.h>
#include<string.h>

unsigned char code[] = \
"\x90 ShellCode Goes Here \x90";


main()
{

	printf("Shellcode Length:  %d\n", (int)strlen(code));

	int (*ret)() = (int(*)())code;

	ret();

}
