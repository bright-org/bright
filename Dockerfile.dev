FROM elixir:1.14-alpine AS base

RUN apk update && apk add \
  inotify-tools git build-base npm bash

FROM base AS setup_user
ARG host_user_name
ARG host_group_name
ARG host_uid
ARG host_gid

RUN apk add shadow && groupadd -g $host_gid $host_group_name \
  && useradd -m -s /bin/bash -u $host_uid -g $host_gid $host_user_name

USER $host_user_name

FROM setup_user AS build_as_user
RUN mix do local.hex --force, local.rebar --force, archive.install --force hex phx_new

FROM base AS build_as_root
RUN mix do local.hex --force, local.rebar --force, archive.install --force hex phx_new
