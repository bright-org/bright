.PHONY: setup setup_for_docker_user
.DEFAULT_GOAL := setup

setup:
	docker compose run --rm web mix setup

setup_for_docker_user:
	cp docker_dev/docker-compose.override.yml .
	echo "host_user_name=${USER}" > .env
	echo "host_group_name=${USER}" >> .env
	echo "host_uid=`id -u`" >> .env
	echo "host_gid=`id -g`" >> .env
