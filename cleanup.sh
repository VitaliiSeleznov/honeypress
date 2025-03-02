#!/bin/bash
docker compose -f compose-for-traefik.yaml down
docker volume rm honeypress_logs
docker volume rm honeypress_wordpress
docker volume rm honeypress_db


