# Introduction

I wanted a simple way to run the sample server from the book [Seven Mobile Apps in Seven Weeks](https://pragprog.com/book/7apps/seven-mobile-apps-in-seven-weeks).  
So this is simple [Docker](https://www.docker.com) container that implements the sample API server found in the book.

# Setup

You will need to go to [MapQuest Developer Website](http://developer.mapquest.com) to get a key.

Once you have a key enter it into the 'docker-compose.yml' file:

		environment:
			MAPQUEST_API_KEY: [put your key here]

Then run the make file:

		make build
		make run

To test the container you can execute the following command to get a list of time zones:

        curl -H "Content-Type:application/json" -H "Accept:application/json" http://localhost:3000/clock/time_zones

# Makefile commands

	This make process supports the following targets:
	
* **clean** - clean up and targets in project
* **build** - build both the project and Docker image
* **run**   - run the service
* **zap**   - zap all of the local images... BEWARE! this is evil.
	