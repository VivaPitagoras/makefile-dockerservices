# makefile-dockerservices
Makefile for some basic docker files and services management using CLI.

So I made this Makefile for myself to manage some very basic tasks on docker (docker-compose) for those who like to manage everything from the CLI.

It's nothing fancy but it helps with some routine and repetitive tasks.

In order to use the Makefile you will have to install the `make` package and put the Makefile in the folder from where you'll be launching the commands.

- Variables

| Variable | Default value | Explanation |
|--|--|--|
| SERVICES_DIR | $(HOME)/services | Base dir where all your docker stacks are located |
| COMPOSE_FILE | compose.yml | The name of the compose file |
| EDITOR | nano | The editor used to edit files |

- Single target commands

| Command | Usage | Explanation |
|--|--|--|
| \<target>.new | make plex.new | Create a new folder and open a compose.yml file with the prefered editor |
| \<target>.edit | make plex.edit | Edit the compose.yml file |
| \<target>.env | make plex.env | Edit the .env file |
| \<target>.del | make plex.del | Eliminate the corresponding stack folder* |
| \<target>.update | make plex.update | Update the image of the service |
| \<target>.up | make plex.up | `docker compose up -d`|
| \<target>.down | make plex.down | `docker compose down` |
| \<target>.reload | make plex.reload | `docker compose down && docker compose up -d` |


- Group tasks

| Command | Usage | Explanation |
|--|--|--|
| list | make list | List all available stacks|
| up | make up | `docker compose up -d` all stacks |
| down | make down | `docker compose down` all stacks|
| reload | make reload | `docker compose down &$ docker compsoe up -d` all stacks |
| update | make update | Update all images |
| dry-clean | make dry-clean | Check if there are non-stack folders |
| clean | make clean | Elimimnate all non-stack folders* |
| prune | make prune | Eliminate all unused images |

* IF you use the the stack folder to store other things (like bind volumes for the service config or data) this might fail due to file/folder permissions.
