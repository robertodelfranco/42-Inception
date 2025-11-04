
COMPOSE = docker-compose

LOGIN = cadete

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v --rmi local --remove-orphans
	sudo rm -rf /home/$(LOGIN)/data/

logs:
	$(COMPOSE) logs -f

.PHONY: build up down clean logs