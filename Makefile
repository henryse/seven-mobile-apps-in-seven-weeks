makefile_version:=1.0

ifdef VERSION
	project_version:=$(VERSION)
else
	project_version:=$(shell git rev-parse --short=8 HEAD)
endif

ifdef PROJECT_NAME
	project_name:=$(PROJECT_NAME)
else
	project_name:=$(shell git config --local remote.origin.url | sed -n 's\#.*/\([^.]*\)\.git\#\1\#p')
endif

ifdef SRC_DIR
	source_directory:=$(SRC_DIR)
else
	source_directory:=$(CURDIR)/src
endif

repository:=henryse/$(project_name)
latest_image:=$(repository):latest
version_image:=$(repository):$(project_version)
docker_compose_dir:=$(CURDIR)/src
docker_compose_yml:=$(docker_compose_dir)/docker-compose.yml

docker_cmd:=$(shell if [[ `docker ps` == *"CONTAINER ID"* ]]; then echo "docker";else echo "sudo docker";fi)

docker_sub_version:=$(shell $(docker_cmd) --version | awk '{split($$0, a, ".");print a[2]}')

docker_tag_cmd:=$(shell if (($(docker_sub_version) > 11)); then echo "$(docker_cmd) tag";else echo "$(docker_cmd) tag -f";fi)

docker_compose_cmd:=$(shell if [[ `docker ps` == *"CONTAINER ID"* ]]; then echo "docker-compose";else echo "sudo docker-compose";fi)

docker_compose_up_cmd:=$(shell if [[ `docker ps` == *"CONTAINER ID"* ]]; then echo "docker-compose -f $(docker_compose_yml) up";else echo "sudo docker-compose -f $(docker_compose_yml) up -d";fi)

version:
	@printf "\e[1;34m[INFO] [version]\e[00m\n\n"
	@echo [INFO] Build Makefile Version $(makefile_version)

settings: version
	@printf "\e[1;34m[INFO] [settings]\e[00m\n\n"
	@echo [INFO]     project_version=$(project_version)
	@echo [INFO]     project_name=$(project_name)
	@echo [INFO]     repository=$(repository)
	@echo [INFO]     latest_image=$(latest_image)
	@echo [INFO]     version_image=$(version_image)
	@echo [INFO]     source_directory=$(source_directory)
	@echo [INFO]     docker_sub_version=$(docker_sub_version)
	@echo [INFO]     docker_cmd=$(docker_cmd)
	@echo [INFO]     docker_tag_cmd=$(docker_tag_cmd)
	@echo [INFO]     docker_compose_cmd=$(docker_compose_cmd)
	@echo [INFO]     docker_compose_yml=$(docker_compose_yml)

help: settings
	@printf "\e[1;34m[INFO] [information]\e[00m\n\n"
	@echo [INFO] This make process supports the following targets:
	@echo [INFO]    clean - clean up and targets in project
	@echo [INFO]    build - build both the project and Docker image
	@echo [INFO]    run   - run the service
	@echo [INFO]    zap   - zap all of the local images... BEWARE! this is evil.
	@echo
	@echo [INFO] The script supports the following parameters:
	@echo [INFO]     VERSION - version to tag docker image wth, default value is the git hash
	@echo [INFO]     PROJECT_NAME - project name, default is git project name
	@echo [INFO]     SRC_DIR - source code, default is "image"
	@echo [INFO]     IGNORE_CHECK - ignore the master file check from git, if not defined then check.
	@echo
	@echo [INFO] This will build either a Dockerfile or a project that uses Dockerfile.txt.
	@echo [INFO] This tool expects the project to be located in a directory called image.
	@echo [INFO] If there is a Makefile in the image directory, then this tool will execute it
	@echo [INFO] with either clean and build targets.
	@echo
	@echo [INFO] Examples:
	@echo
	@echo [INFO]    make build
	@echo
	@echo [INFO]    make build VERSION=666 PROJECT_NAME=dark_place SRC_DIR=src
	@echo

build_source_directory:
ifneq ("$(wildcard $(source_directory)/Makefile)","")
	@echo [DEBUG] Found Makefile
	$(MAKE) -C $(source_directory) build VERSION=$(project_version) PROJECT_NAME=$(project_name) SRC_DIR=$(source_directory)
endif

build_docker:

	@echo [INFO] Dockerfile used to build image
	cat $(source_directory)/Dockerfile
	$(docker_cmd) build --rm --tag $(version_image) $(source_directory)
	$(docker_tag_cmd) $(version_image) $(latest_image)

	@echo [INFO] Handy command to run this docker image:
	@echo [INFO]
	@echo [INFO] Run in interactive mode:
	@echo [INFO]
	@echo [INFO]     $(docker_cmd) run -t -i  $(version_image)
	@echo [INFO]
	@echo [INFO] Run as service with ports in interactive mode:
	@echo [INFO]
	@echo [INFO]     make run

build: settings build_source_directory build_docker

clean: settings
	@printf "\e[1;34m[INFO] [cleaning image]\e[00m\n\n"
ifneq ("$(wildcard $(source_directory)/Makefile)","")
	$(MAKE) -C $(source_directory) clean VERSION=$(project_version) PROJECT_NAME=$(project_name) SRC_DIR=$(source_directory)
endif
ifneq ("$(wildcard $(docker_compose_dir))","")
	cd $(docker_compose_dir);$(docker_compose_cmd) rm -f
endif
	docker rmi $(docker images -q | tail -n +2)
	$(docker_cmd) images | grep '<none>' | awk '{system("$(docker_cmd) rmi -f " $$3)}'
	$(docker_cmd) images | grep '$(repository)' | awk '{system("$(docker_cmd) rmi -f " $$3)}'

run: settings
	@printf "\e[1;34m[INFO] [run image]\e[00m\n\n"
	$(docker_compose_up_cmd)

zap: settings
	for i in $$($(docker_cmd) images -q); do echo $(docker_cmd) rmi -f $$i; done
	for i in $$($(docker_cmd) images -q); do $(docker_cmd) rmi -f $$i; done
	for i in $$($(docker_cmd) ps -aq); do $(docker_cmd) rm $i; done
