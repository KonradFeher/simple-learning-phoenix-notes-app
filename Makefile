.PHONY: up down restart logs build test ci migrate seed

COMPOSE_FILE=docker-compose.dev.yml
DC=docker compose -f $(COMPOSE_FILE)

up:
	./scripts/init_dirs.sh
	$(DC) up -d

down:
	$(DC) down

restart:
	$(DC) down
	$(DC) up -d

logs:
	$(DC) logs -f

build:
	$(DC) build

test:
	mix test

ci:
	mix test
	mix credo

migrate:
	$(DC) exec web mix ecto.migrate

seed:
	$(DC) exec web mix run priv/repo/seeds.exs
