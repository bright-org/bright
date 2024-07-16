.PHONY: setup setup_for_docker_user
.DEFAULT_GOAL := setup

setup:
	docker compose run --rm web mix setup

format:
	docker compose run --rm web mix format

credo:
	docker compose run --rm web mix credo

#「test」とラベルが使えない為「test1」というラベルを使ってます
test1:
	docker compose run --rm web mix test

testwatch:
	docker compose run --rm web mix test.watch

clean:
	docker compose run --rm web mix clean

# github pushの事前チェック
check: format credo test1

setup_for_docker_user:
	cp docker_dev/docker-compose.override.yml .
	echo "host_user_name=${USER}" > .env
	echo "host_group_name=${USER}" >> .env
	echo "host_uid=`id -u`" >> .env
	echo "host_gid=`id -g`" >> .env


## bright-jobへDBと繋ぐためのnetwork作成

```
docker network create bright-network
```