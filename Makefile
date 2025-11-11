
COMPOSE = docker-compose

MLOGIN = rdel-fra

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down --rmi local
	sudo rm -rf /home/$(MLOGIN)/data/

logs:
	$(COMPOSE) logs -f

.PHONY: build up down clean logs