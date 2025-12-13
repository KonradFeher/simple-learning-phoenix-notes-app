#!/bin/bash
set -e

# Grafana folders
mkdir -p grafana_data/{csv,dashboards,plugins,pdf,png}

# Postgres folders
mkdir -p pgdata/data/pgdata

sudo chown -R $(whoami):$(whoami) pgdata grafana_data
