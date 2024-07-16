#!/bin/bash

# # Перевірка чи встановлений Docker
# if ! [ -x "$(command -v docker)" ]; then
#   echo "Docker не встановлений. Встановлення Docker..."
#   curl -fsSL https://get.docker.com -o get-docker.sh
#   sh get-docker.sh
#   rm get-docker.sh
#   sudo systemctl start docker
#   sudo systemctl enable docker
# else
#   echo "Docker вже встановлений."
# fi
# if ! [ -x "$(command -v docker-compose)" ]; then
#   echo "Docker Compose не встановлений. Встановлення Docker Compose..."
#   sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#   sudo chmod +x /usr/local/bin/docker-compose
#   sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
# else
#   echo "Docker Compose вже встановлений."
# fi

# Створення .env файлів для Promtail та Loki
# cat <<EOF > .env_loki
# LOKI_PORT=3100
# LOKI_LOG_LEVEL=info
# LOKI_CONFIG_FILE=/etc/loki/config.yml
# LOKI_SERVER_HTTP_LISTEN_PORT=${LOKI_PORT}
# LOKI_TABLE_MANAGER_RETENTION_PERIOD=24h
# EOF
# cat <<EOF > .env_promtail
# PROMTAIL_CONFIG_FILE=/etc/promtail/promtail.yml
# PROMTAIL_POSITIONS_FILE=/tmp/positions.yaml
# PROMTAIL_CLIENT_URL=http://localhost:${LOKI_PORT}/loki/api/v1/push
# PROMTAIL_LOG_LEVEL=info
# EOF
source .env_loki

cat <<EOF > promtail-config.yml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:${LOKI_PORT}/loki/api/v1/push
    batchwait: 5s
    batchsize: 102400

scrape_configs:
  - job_name: varlogs
    static_configs:
      - targets:
          - localhost
        labels:
          job: varlogs
          __path__: ${LOG_PATH}/*

    pipeline_stages:
      - match:
          selector: '{job="varlogs"}'
          stages:
            - regex:
                expression: '.*(ERROR|WARN|CRITICAL).*'
            - timestamp:
                source: time
                format: RFC3339
            - labels:
                level: level
            - output:
                source: log
                format: logfmt
                fields:
                  time: timestamp
                  path: filename
                  log: message

EOF

cat <<EOF > loki-config.yml
auth_enabled: false

server:
  http_listen_port: ${LOKI_PORT}

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
  chunk_idle_period: 3m
  chunk_retain_period: 1m

schema_config:
  configs:
  - from: 2020-10-24
    store: boltdb-shipper
    object_store: filesystem
    schema: v11
    index:
      prefix: index_
      period: 24h

storage_config:
  boltdb_shipper:
    active_index_directory: /loki/index
    cache_location: /loki/cache
    cache_ttl: 24h
    shared_store: filesystem
  filesystem:
    directory: /loki/chunks

compactor:
  working_directory: /loki/compactor
  shared_store: filesystem

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
  ingestion_rate_mb: 10
  ingestion_burst_size_mb: 20
  max_entries_limit_per_query: 5000
  max_global_streams_per_user: 10000



chunk_store_config:
  max_look_back_period: 0s

table_manager:
  retention_deletes_enabled: false
  retention_period: 0s
EOF

# Створення docker-compose.yml
cat <<EOF > docker-compose.yml
services:
  loki:
    image: grafana/loki:latest
    container_name: loki
    restart: unless-stopped
    ports:
      - "${LOKI_PORT}:3100"
    volumes:
      - ./loki-config.yml:/etc/loki/config.yml
    env_file:
      - .env_loki

  promtail:
    image: grafana/promtail:latest
    container_name: promtail
    volumes:
      - ./promtail-config.yml:/etc/promtail/promtail.yml
      - /var/log:/var/log
    command:
      - '-config.file=/etc/promtail/promtail.yml'
    env_file:
      - .env_promtail

EOF

# Запуск docker-compose
docker compose up -d

