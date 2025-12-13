.PHONY: up down restart logs build test ci migrate seed

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose down
	docker compose up -d

logs:
	docker compose logs -f

build:
	docker compose build

test:
	mix test

ci:
	mix test
	mix credo

migrate:
	docker compose exec web mix ecto.migrate

seed:
	docker compose exec web mix run priv/repo/seeds.exs
