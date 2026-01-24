# makefile-dockerservices
Makefile for some basic docker files and services management using CLI.

So I made this Makefile for myself to manage some very basic tasks on docker (docker-compose) for those who like to manage everything from the CLI.

It's nothing fancy but it helps with some routine and repetitive tasks:

- up|down service:   cd into folder service + docker compose up|down
- reload a service:  docker compose down & up
- new service:      make new folder, create compose.yml, open it
- update images
- delete a service folder
- start|stop|reload|update all services
