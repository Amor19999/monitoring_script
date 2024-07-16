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
# Перевірка існування файлу .env_pro
if [ ! -f ./.env_pro ]; then
  echo "Файл .env_pro не знайдено!"
  exit 1
fi
source .env_pro
# if ! [ -x "$(command -v docker-compose)" ]; then
#   echo "Docker Compose не встановлений. Встановлення Docker Compose..."
#   sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#   sudo chmod +x /usr/local/bin/docker-compose
#   sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
# else
#   echo "Docker Compose вже встановлений."
# fi

# Наступний файл для  Налаштування правил сповіщень у Prometheus
cat <<EOF > alerts.yml
groups:
  - name: example
    rules:
      - alert: InstanceDown
        expr: up == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Instance {{ $labels.instance }} down"
          description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes."

  - name: example_log
    rules:
      - alert: CriticalLogs
        expr: sum(rate({job="varlogs", level="critical"}[5m])) > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Critical log entries detected"
          description: "There are critical log entries in the last 5 minutes."

  - name: example_cpu
    rules:
      - alert: HighCPULoad
        expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: "High CPU load on {{ $labels.instance }}"
          description: "CPU load is above 80% on {{ $labels.instance }}."

  - name: example_info_test
    rules:
      - alert: TestAlert
        expr: vector(1)  # Це правило завжди буде спрацьовувати
        for: 1m
        labels:
          severity: info
        annotations:
          summary: "Test Alert"
          description: "This is a test alert for verifying alerting setup."
EOF

# Створення entrypoint для Prometheus 
cat <<EOF > entrypoint.sh
#!/bin/sh

# Вивести повідомлення для діагностики
echo "Starting entrypoint script..."

# # Завантажити змінні з .env_pro файлу
# if [ -f /etc/prometheus/.env_pro ]; then
#     echo "Loading environment variables from .env_pro"
export $(grep -v '^#' /etc/prometheus/.env_pro | xargs)
# else
#     echo ".env_pro file not found!"
#     exit 1
# fi

# Вивести значення змінних для діагностики
echo "ALERTMANAGER_IP=${ALERTMANAGER_IP}"
echo "ALERTMANAGER_PORT=${ALERTMANAGER_PORT}"
echo "PROMETHEUS_IP=${PROMETHEUS_IP}"
echo "PROMETHEUS_PORT=${PROMETHEUS_PORT}"
echo "NODE_EXP_IP=${NODE_EXP_IP}"
echo "NODE_EXP_PORT=${NODE_EXP_PORT}"
echo "LOKI_IP=${LOKI_IP}"
echo "LOKI_PORT=${LOKI_PORT}"

# Обробити шаблонний файл і згенерувати prometheus.yml
envsubst < /etc/prometheus/prometheus.yml.tpl > /etc/prometheus/prometheus.yml

# Вивести вміст згенерованого файлу для перевірки
echo "Generated prometheus.yml:"
cat /etc/prometheus/prometheus.yml

# Запустити Prometheus
prometheus --config.file=/etc/prometheus/prometheus.yml
EOF

# Створення конфігураційного файлу Prometheus 
cat <<EOF > prometheus.yml.tpl
global:
  scrape_interval: 1m
  scrape_timeout: 10s
  evaluation_interval: 1m

alerting:
  alertmanagers:
    - static_configs:
        - targets: 
            - ${ALERTMANAGER_IP}:${ALERTMANAGER_PORT}

rule_files:
  - /etc/prometheus/alerts.yml

scrape_configs:
  - job_name: prometheus
    honor_timestamps: true
    scrape_interval: 1m
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    follow_redirects: true
    static_configs:
      - targets:
          - ${PROMETHEUS_IP}:${PROMETHEUS_PORT}

  - job_name: node_exporter
    honor_timestamps: true
    scrape_interval: 1m
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    follow_redirects: true
    static_configs:
      - targets: 
          - ${NODE_EXP_IP}:${NODE_EXP_PORT}

  - job_name: loki
    honor_timestamps: true
    scrape_interval: 1m
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    follow_redirects: true
    static_configs:
      - targets: 
          - ${LOKI_IP}:${LOKI_PORT}

  - job_name: alertmanager
    static_configs:
      - targets: 
          - ${ALERTMANAGER_IP}:${ALERTMANAGER_PORT}
EOF

# mv entrypoint entrypoint.sh
chmod +x entrypoint.sh

cat <<EOF > Dockerfile
FROM alpine:latest

RUN apk add --no-cache \
    prometheus \
    gettext

COPY prometheus.yml.tpl /etc/prometheus/prometheus.yml.tpl
COPY alerts.yml /etc/prometheus/alerts.yml
COPY entrypoint.sh /etc/prometheus/entrypoint.sh
COPY .env_pro /etc/prometheus/.env_pro

ENTRYPOINT ["/bin/sh", "/etc/prometheus/entrypoint.sh"]
EOF

# Створення docker-compose.yml
cat <<EOF > docker-compose.yml
services:
  prometheus:
    build: .
    container_name: prometheus
    restart: always
    volumes:
      - prometheus_data:/prometheus
      - ./prometheus.yml.tpl:/etc/prometheus/prometheus.yml.tpl
      - ./alerts.yml:/etc/prometheus/alerts.yml
      - ./entrypoint.sh:/entrypoint.sh
      - ./.env_pro:/etc/prometheus/.env_pro
    ports:
      - "${PROMETHEUS_PORT}:9090"
    env_file:
      - .env_pro
    command:
      # - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.enable-lifecycle'
      - '--web.listen-address=0.0.0.0:${PROMETHEUS_PORT}'

  node_exporter:
    image: quay.io/prometheus/node-exporter:latest
    container_name: node_exporter
    pid: host
    restart: always
    ports:
      - "${NODE_EXP_PORT}:9100"
    volumes:
      - '/:/host:ro,rslave'
    env_file:
      - .env_node

volumes:
  prometheus_data:
EOF

# Запуск docker-compose
 docker compose up -d --build
