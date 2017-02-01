# Introduction

This is simply the sample API from [Seven Mobile Apps in Seven Weeks](https://pragprog.com/book/7apps/seven-mobile-apps-in-seven-weeks) in docker form.

# Setup

You will need to go to [MapQuest Developer Website](http://developer.mapquest.com) to get a key.

Once you have a key enter it into the 'docker-compose.yml' file:

		environment:
			MAPQUEST_API_KEY: [put your key here]

Then run the make file:

		make build
		make run

# Makefile commands

	This make process supports the following targets:
	
* **clean** - clean up and targets in project
* **build** - build both the project and Docker image
* **run**   - run the service
* **zap**   - zap all of the local images... BEWARE! this is evil.
	