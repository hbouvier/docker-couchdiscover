NS = vp
NAME = couchdiscover
VERSION = 0.2.2
LOCAL_TAG = $(NS)/$(NAME):$(VERSION)

REGISTRY = callforamerica
ORG = vp
REMOTE_TAG = $(REGISTRY)/$(NAME):latest

GITHUB_REPO = docker-couchdiscover
DOCKER_REPO = couchdiscover
BUILD_BRANCH = master

DSHELL = ash

-include ../Makefile.inc

.PHONY: all build tag rebuild commit push shell run launch launch-net logs logsf start stop kill rm rmf rmi

all: build

checkout:
	@git checkout $(BUILD_BRANCH)

build:
	@docker build -t $(LOCAL_TAG) --force-rm .
	@$(MAKE) tag
	@$(MAKE) dclean

tag:
	@docker tag $(LOCAL_TAG) $(REMOTE_TAG)

rebuild:
	@docker build -t $(LOCAL_TAG) --force-rm --no-cache .
	@$(MAKE) tag
	@$(MAKE) dclean

commit:
	@git add -A .
	@git commit

push:
	@git push origin master

shell:
	@docker exec -ti $(NAME) $(DSHELL)

run:
	@docker run -it --rm --name $(NAME) $(LOCAL_TAG) $(DSHELL)

launch:
	@docker run -d --name $(NAME) -h $(NAME).local $(LOCAL_TAG) 

launch-net:
	@docker run -d --name $(NAME) -h $(NAME).local --network=local --net-alias $(NAME).local $(LOCAL_TAG)

logs:
	@docker logs $(NAME)

logsf:
	@docker logs -f $(NAME)

start:
	@docker start $(NAME)

kill:
	@docker kill $(NAME)

stop:
	@docker stop $(NAME)

rm:
	@docker rm $(NAME)

rmf:
	@docker rm -f $(NAME)

rmi:
	@docker rmi $(LOCAL_TAG)
	@docker rmi $(REMOTE_TAG)

default: build