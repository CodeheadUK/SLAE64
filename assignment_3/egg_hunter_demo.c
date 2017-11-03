// Egg Hunter Demo - Payload on heap
// Compile with: 
//      gcc -z execstack -fno-stack-protector egg_hunter_demo.c -o egg_demo

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
 
unsigned char egghunter[] = \
"\xbb\xeb\x02\xeb\xfc\x53\x48\xc1\xe3\x20\x48\x0b\x1c\x24\x48\x31\xd2\x52\xb6\x10\x5f\x57\x5e\x6a\x15\x58\x0f\x05\x3c\xf2\x75\x05\x48\x01\xd7\xeb\xf2\x52\x59\x83\xe9\x08\x48\x3b\x1f\x74\x0b\x48\xff\xc7\xe2\xf6\x48\x83\xc7\x08\xeb\xdd\xff\xe7";

unsigned char payload[] = \
"\x48\x31\xc9\x48\xf7\xe1\x50\x5f\xff\xc0\x48\x83\xc2\x08\x68\x45\x47\x47\x0a\x48\x89\xe6\x0f\x05\x6a\x3c\x58\x0f\x05";

main()
{
	int nPages, nBytes;
	time_t t;
	
	printf("Allocating heap data\n");
	
	srand((unsigned) time(&t));
	nPages = (rand()%1000)+2;
	printf("Padding heap with %d pages of junk.\n", nPages);
	for(;nPages!=0;--nPages)
	{
		unsigned char *padding = malloc(1024);
	}
	
	printf("Appending payload\n");
	
	unsigned char *heap = malloc(1024);
	nBytes =  rand()%512;
	printf("Padding payload page with %d bytes of junk\n", nBytes);
		
	memcpy(&heap[nBytes], "\xeb\x02\xeb\xfc", 4);
	memcpy(&heap[nBytes+4], &heap[nBytes], 4);
	memcpy(&heap[nBytes+8], payload, 29);
	
	printf("Triggering egg hunter\n");
	int (*ret)() = (int(*)())egghunter;

	ret();

}
