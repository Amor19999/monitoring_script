#!/bin/bash

# Перевірка чи встановлений Docker
if ! [ -x "$(command -v docker)" ]; then
  echo "Docker не встановлений. Встановлення Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
  if ! getent group docker > /dev/null; then
    sudo groupadd docker
  fi
  sudo usermod -aG docker $USER
  sudo systemctl start docker
  sudo systemctl enable docker
  echo "Вийдіть і зайдіть знову, щоб зміни набули чинності."
else
  echo "Docker вже встановлений."
fi

# Перевірка чи встановлений Docker Compose
if ! [ -x "$(command -v docker-compose)" ]; then
  echo "Docker Compose не встановлений. Встановлення Docker Compose..."
  sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose || true
  sudo systemctl restart docker
else
  echo "Docker Compose вже встановлений."
fi
# # Перевірка чи встановлений Docker
# if ! [ -x "$(command -v docker)" ]; then
#   echo "Docker не встановлений. Встановлення Docker..."
#   # Встановлення Docker
#   curl -fsSL https://get.docker.com -o get-docker.sh
#   sh get-docker.sh
#   rm get-docker.sh
#   # Запуск Docker
#   sudo groupadd docker
#   sudo usermod -aG docker $USER
#   sudo systemctl start docker
#   sudo systemctl enable docker
#   newgrp docker
# else
#   echo "Docker вже встановлений."
# fi

# # Перевірка чи встановлений Docker Compose
# if ! [ -x "$(command -v docker-compose)" ]; then
#   echo "Docker Compose не встановлений. Встановлення Docker Compose..."
#   # Встановлення Docker Compose
#   sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#   sudo chmod +x /usr/local/bin/docker-compose
#   sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
#   sudo systemctl restart docker
# else
#   echo "Docker Compose вже встановлений."
# fi
source .env
# # Отримання TELEGRAM_CHAT_ID
# echo "Отримання TELEGRAM_CHAT_ID..."
# # TELEGRAM_BOT_TOKEN="6844304878:AAEoIVoqU7NHrPZo0Apv47PL0q487oHO6Ag"
# CHAT_ID=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates" | grep -o '"chat":{"id":[0-9]*' | grep -o '[0-9]*')

# # Перевірка чи отримано chat_id
# if [ -z "$CHAT_ID" ]; then
#   echo "Не вдалося автоматично отримати TELEGRAM_CHAT_ID. Будь ласка, введіть його вручну:"
#   read -p "TELEGRAM_CHAT_ID: " CHAT_ID
# else
#   echo "TELEGRAM_CHAT_ID: $CHAT_ID"
# fi

# export TELEGRAM_CHAT_ID=$CHAT_ID
# # Створення .env файлів для Grafana та Alertmanager
# # cat <<EOF > .env
# # GF_SECURITY_ADMIN_PASSWORD=admin
# # GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource,grafana-piechart-panel
# # GF_SERVER_HTTP_PORT=3000
# # ALERTMANAGER_CONFIG_FILE=/etc/alertmanager/alertmanager.yml
# # ALERTMANAGER_LOG_LEVEL=info
# # TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
# # TELEGRAM_CHAT_ID=$CHAT_ID
# # EOF

# Створення alertmanager.yml
cat <<EOF > alertmanager.yml
global:
  resolve_timeout: 1m

route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 1m
  repeat_interval: 15m
  receiver: 'telegram'

receivers:
  - name: 'telegram'
    telegram_configs:
      - bot_token: ${TELEGRAM_BOT_TOKEN}
        chat_id: ${TELEGRAM_CHAT_ID}
        message: '{{ template "telegram.default.message" . }}'
templates:
  - '/etc/alertmanager/template/*.tmpl'

EOF

# Створення скрипту для налаштування джерел даних Grafana
cat <<EOF > datasources.yml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://${PROMETHEUS_SERVE_IP}:${PROMETHEUS_SERVE_PORT}
    isDefault: true

  - name: Loki
    type: loki
    access: proxy
    url: http://${LOKI_SERVE_IP}:${LOKI_SERVE_PORT}
EOF


# Dashboard for Loki test
cat <<EOF > dashboard-config.yml
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    editable: true
    options:
      path: /var/lib/grafana/dashboards

  - name: 'imported-dashboards'
    orgId: 1
    folder: ''
    type: file
    options:
      path: /var/lib/grafana/dashboards/imported
EOF

mkdir dashboards
mkdir dashboards/imported

cat <<EOF > dashboards/imported/11074.json
{
  "annotations": {
    "list": [
      {
        "$$hashKey": "object:2875",
        "builtIn": 1,
        "datasource": {
          "type": "datasource",
          "uid": "grafana"
        },
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "description": "【English version】Update 2020.10.10, add the overall resource overview! Support Grafana6&7,Support Node Exporter v0.16 and above.Optimize the main metrics display. Includes: CPU, memory, disk IO, network, temperature and other monitoring metrics。https://github.com/starsliao/Prometheus",
  "editable": true,
  "fiscalYearStartMonth": 0,
  "gnetId": 11074,
  "graphTooltip": 0,
  "id": 4,
  "links": [
    {
      "$$hashKey": "object:2300",
      "icon": "bolt",
      "tags": [],
      "targetBlank": true,
      "title": "Update",
      "tooltip": "Update dashboard",
      "type": "link",
      "url": "https://grafana.com/grafana/dashboards/11074"
    },
    {
      "$$hashKey": "object:2301",
      "icon": "question",
      "tags": [],
      "targetBlank": true,
      "title": "GitHub",
      "tooltip": "more dashboard",
      "type": "link",
      "url": "https://github.com/starsliao"
    },
    {
      "$$hashKey": "object:2302",
      "asDropdown": true,
      "icon": "external link",
      "tags": [],
      "targetBlank": true,
      "title": "",
      "type": "dashboards"
    }
  ],
  "liveNow": false,
  "panels": [
    {
      "collapsed": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "gridPos": {
        "h": 1,
        "w": 24,
        "x": 0,
        "y": 0
      },
      "id": 187,
      "panels": [],
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "refId": "A"
        }
      ],
      "title": "Resource Overview (associated JOB)，Host：$show_hostname，Instance：$node",
      "type": "row"
    },
    {
      "columns": [],
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "description": "Partition utilization, disk read, disk write, download bandwidth, upload bandwidth, if there are multiple network cards or multiple partitions, it is the value of the network card or partition with the highest utilization rate collected.\n\nCurrEstab: The number of TCP connections whose current status is ESTABLISHED or CLOSE-WAIT.",
      "fontSize": "80%",
      "gridPos": {
        "h": 7,
        "w": 24,
        "x": 0,
        "y": 1
      },
      "id": 185,
      "showHeader": true,
      "sort": {
        "col": 31,
        "desc": false
      },
      "styles": [
        {
          "$$hashKey": "object:1600",
          "alias": "Hostname",
          "align": "auto",
          "colors": [
            "rgba(245, 54, 54, 0.9)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(50, 172, 45, 0.97)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 1,
          "link": false,
          "linkTooltip": "",
          "linkUrl": "",
          "mappingType": 1,
          "pattern": "nodename",
          "thresholds": [],
          "type": "string",
          "unit": "bytes"
        },
        {
          "$$hashKey": "object:1601",
          "alias": "IP（Link to details）",
          "align": "auto",
          "colors": [
            "rgba(245, 54, 54, 0.9)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(50, 172, 45, 0.97)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 2,
          "link": true,
          "linkTargetBlank": false,
          "linkTooltip": "Browse host details",
          "linkUrl": "d/xfpJB9FGz/node-exporter?orgId=1&var-job=${job}&var-hostname=All&var-node=${__cell}&var-device=All&var-origin_prometheus=$origin_prometheus",
          "mappingType": 1,
          "pattern": "instance",
          "thresholds": [],
          "type": "number",
          "unit": "short"
        },
        {
          "$$hashKey": "object:1602",
          "alias": "Memory",
          "align": "auto",
          "colors": [
            "rgba(245, 54, 54, 0.9)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(50, 172, 45, 0.97)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 2,
          "link": false,
          "mappingType": 1,
          "pattern": "Value #B",
          "thresholds": [],
          "type": "number",
          "unit": "bytes"
        },
        {
          "$$hashKey": "object:1603",
          "alias": "CPU Cores",
          "align": "auto",
          "colors": [
            "rgba(245, 54, 54, 0.9)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(50, 172, 45, 0.97)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "mappingType": 1,
          "pattern": "Value #C",
          "thresholds": [],
          "type": "number",
          "unit": "short"
        },
        {
          "$$hashKey": "object:1604",
          "alias": " Uptime",
          "align": "auto",
          "colors": [
            "rgba(245, 54, 54, 0.9)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(50, 172, 45, 0.97)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 2,
          "mappingType": 1,
          "pattern": "Value #D",
          "thresholds": [],
          "type": "number",
          "unit": "s"
        },
        {
          "$$hashKey": "object:1605",
          "alias": "Partition used%*",
          "align": "auto",
          "colorMode": "cell",
          "colors": [
            "rgba(50, 172, 45, 0.97)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(245, 54, 54, 0.9)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 2,
          "mappingType": 1,
          "pattern": "Value #E",
          "thresholds": [
            "70",
            "85"
          ],
          "type": "number",
          "unit": "percent"
        },
        {
          "$$hashKey": "object:1606",
          "alias": "CPU used%",
          "align": "auto",
          "colorMode": "cell",
          "colors": [
            "rgba(50, 172, 45, 0.97)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(245, 54, 54, 0.9)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 2,
          "mappingType": 1,
          "pattern": "Value #F",
          "thresholds": [
            "70",
            "85"
          ],
          "type": "number",
          "unit": "percent"
        },
        {
          "$$hashKey": "object:1607",
          "alias": "Memory used%",
          "align": "auto",
          "colorMode": "cell",
          "colors": [
            "rgba(50, 172, 45, 0.97)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(245, 54, 54, 0.9)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 2,
          "mappingType": 1,
          "pattern": "Value #G",
          "thresholds": [
            "70",
            "85"
          ],
          "type": "number",
          "unit": "percent"
        },
        {
          "$$hashKey": "object:1608",
          "alias": "Disk read*",
          "align": "auto",
          "colorMode": "cell",
          "colors": [
            "rgba(50, 172, 45, 0.97)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(245, 54, 54, 0.9)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 2,
          "mappingType": 1,
          "pattern": "Value #H",
          "thresholds": [
            "10485760",
            "20485760"
          ],
          "type": "number",
          "unit": "Bps"
        },
        {
          "$$hashKey": "object:1609",
          "alias": "Disk write*",
          "align": "auto",
          "colorMode": "cell",
          "colors": [
            "rgba(50, 172, 45, 0.97)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(245, 54, 54, 0.9)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 2,
          "mappingType": 1,
          "pattern": "Value #I",
          "thresholds": [
            "10485760",
            "20485760"
          ],
          "type": "number",
          "unit": "Bps"
        },
        {
          "$$hashKey": "object:1610",
          "alias": "Download*",
          "align": "auto",
          "colorMode": "cell",
          "colors": [
            "rgba(50, 172, 45, 0.97)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(245, 54, 54, 0.9)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 2,
          "mappingType": 1,
          "pattern": "Value #J",
          "thresholds": [
            "30485760",
            "104857600"
          ],
          "type": "number",
          "unit": "bps"
        },
        {
          "$$hashKey": "object:1611",
          "alias": "Upload*",
          "align": "auto",
          "colorMode": "cell",
          "colors": [
            "rgba(50, 172, 45, 0.97)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(245, 54, 54, 0.9)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 2,
          "mappingType": 1,
          "pattern": "Value #K",
          "thresholds": [
            "30485760",
            "104857600"
          ],
          "type": "number",
          "unit": "bps"
        },
        {
          "$$hashKey": "object:1612",
          "alias": "5m load",
          "align": "auto",
          "colors": [
            "rgba(245, 54, 54, 0.9)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(50, 172, 45, 0.97)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 2,
          "mappingType": 1,
          "pattern": "Value #L",
          "thresholds": [],
          "type": "number",
          "unit": "short"
        },
        {
          "$$hashKey": "object:1613",
          "alias": "CurrEstab",
          "align": "auto",
          "colorMode": "cell",
          "colors": [
            "rgba(50, 172, 45, 0.97)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(245, 54, 54, 0.9)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 2,
          "mappingType": 1,
          "pattern": "Value #M",
          "thresholds": [
            "1000",
            "1500"
          ],
          "type": "string",
          "unit": "short"
        },
        {
          "$$hashKey": "object:1614",
          "alias": "TCP_tw",
          "align": "center",
          "colorMode": "cell",
          "colors": [
            "rgba(50, 172, 45, 0.97)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(245, 54, 54, 0.9)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "mappingType": 1,
          "pattern": "Value #N",
          "thresholds": [
            "5000",
            "20000"
          ],
          "type": "number",
          "unit": "short"
        },
        {
          "$$hashKey": "object:1615",
          "alias": "",
          "align": "right",
          "colors": [
            "rgba(245, 54, 54, 0.9)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(50, 172, 45, 0.97)"
          ],
          "decimals": 2,
          "pattern": "/.*/",
          "thresholds": [],
          "type": "hidden",
          "unit": "short"
        }
      ],
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_uname_info{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"} - 0",
          "format": "table",
          "instant": true,
          "interval": "",
          "legendFormat": "主机名",
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "sum(time() - node_boot_time_seconds{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"})by(instance)",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "",
          "legendFormat": "运行时间",
          "refId": "D"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_memory_MemTotal_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"} - 0",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "",
          "legendFormat": "总内存",
          "refId": "B"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "count(node_cpu_seconds_total{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",mode='system'}) by (instance)",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "",
          "legendFormat": "总核数",
          "refId": "C"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_load5{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"}",
          "format": "table",
          "instant": true,
          "interval": "",
          "legendFormat": "5分钟负载",
          "refId": "L"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "(1 - avg(rate(node_cpu_seconds_total{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",mode=\"idle\"}[$interval])) by (instance)) * 100",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "",
          "legendFormat": "CPU使用率",
          "refId": "F"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "(1 - (node_memory_MemAvailable_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"} / (node_memory_MemTotal_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"})))* 100",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "",
          "legendFormat": "内存使用率",
          "refId": "G"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "max((node_filesystem_size_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",fstype=~\"ext.?|xfs\"}-node_filesystem_free_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",fstype=~\"ext.?|xfs\"}) *100/(node_filesystem_avail_bytes {origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",fstype=~\"ext.?|xfs\"}+(node_filesystem_size_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",fstype=~\"ext.?|xfs\"}-node_filesystem_free_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",fstype=~\"ext.?|xfs\"})))by(instance)",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "",
          "legendFormat": "分区使用率",
          "refId": "E"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "max(rate(node_disk_read_bytes_total{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"}[$interval])) by (instance)",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "",
          "legendFormat": "最大读取",
          "refId": "H"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "max(rate(node_disk_written_bytes_total{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"}[$interval])) by (instance)",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "",
          "legendFormat": "最大写入",
          "refId": "I"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_netstat_Tcp_CurrEstab{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"} - 0",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "",
          "legendFormat": "连接数",
          "refId": "M"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_sockstat_TCP_tw{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"} - 0",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "",
          "legendFormat": "TIME_WAIT",
          "refId": "N"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "max(rate(node_network_receive_bytes_total{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"}[$interval])*8) by (instance)",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "",
          "legendFormat": "下载带宽",
          "refId": "J"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "max(rate(node_network_transmit_bytes_total{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"}[$interval])*8) by (instance)",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "",
          "legendFormat": "上传带宽",
          "refId": "K"
        }
      ],
      "title": "Server Resource Overview【JOB：$job，Total：$total】",
      "transform": "table",
      "type": "table-old"
    },
    {
      "aliasColors": {
        "192.168.200.241:9100_Total": "dark-red",
        "Idle - Waiting for something to happen": "#052B51",
        "guest": "#9AC48A",
        "idle": "#052B51",
        "iowait": "#EAB839",
        "irq": "#BF1B00",
        "nice": "#C15C17",
        "sdb_每秒I/O操作%": "#d683ce",
        "softirq": "#E24D42",
        "steal": "#FCE2DE",
        "system": "#508642",
        "user": "#5195CE",
        "磁盘花费在I/O操作占比": "#ba43a9"
      },
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "description": "",
      "fieldConfig": {
        "defaults": {
          "links": [],
          "unitScale": true
        },
        "overrides": []
      },
      "fill": 0,
      "fillGradient": 0,
      "gridPos": {
        "h": 7,
        "w": 8,
        "x": 0,
        "y": 8
      },
      "hiddenSeries": false,
      "id": 191,
      "legend": {
        "alignAsTable": false,
        "avg": false,
        "current": true,
        "hideEmpty": true,
        "hideZero": true,
        "max": false,
        "min": false,
        "rightSide": false,
        "show": true,
        "sort": "current",
        "sortDesc": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 2,
      "links": [],
      "maxPerRow": 6,
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "10.3.7",
      "pointradius": 5,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [
        {
          "$$hashKey": "object:2312",
          "alias": "Overall average used%",
          "lines": false,
          "pointradius": 1,
          "points": true,
          "yaxis": 2
        },
        {
          "$$hashKey": "object:2313",
          "alias": "CPU Cores",
          "color": "#C4162A"
        }
      ],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "count(node_cpu_seconds_total{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\", mode='system'})",
          "format": "time_series",
          "hide": false,
          "instant": false,
          "interval": "30m",
          "intervalFactor": 1,
          "legendFormat": "CPU Cores",
          "refId": "B",
          "step": 240
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "sum(node_load5{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"})",
          "format": "time_series",
          "hide": false,
          "interval": "30m",
          "intervalFactor": 1,
          "legendFormat": "Total 5m load",
          "refId": "A",
          "step": 240
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "avg(1 - avg(rate(node_cpu_seconds_total{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",mode=\"idle\"}[$interval])) by (instance)) * 100",
          "format": "time_series",
          "hide": false,
          "interval": "30m",
          "intervalFactor": 1,
          "legendFormat": "Overall average used%",
          "refId": "F",
          "step": 240
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "$job：Overall total 5m load & average CPU used%",
      "tooltip": {
        "shared": true,
        "sort": 2,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "$$hashKey": "object:8791",
          "format": "short",
          "label": "Total 5m load",
          "logBase": 1,
          "show": true
        },
        {
          "$$hashKey": "object:8792",
          "decimals": 0,
          "format": "percent",
          "label": "Overall average used%",
          "logBase": 1,
          "show": true
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "aliasColors": {
        "192.168.200.241:9100_总内存": "dark-red",
        "内存_Avaliable": "#6ED0E0",
        "内存_Cached": "#EF843C",
        "内存_Free": "#629E51",
        "内存_Total": "#6d1f62",
        "内存_Used": "#eab839",
        "可用": "#9ac48a",
        "总内存": "#bf1b00"
      },
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "decimals": 1,
      "fieldConfig": {
        "defaults": {
          "links": [],
          "unitScale": true
        },
        "overrides": []
      },
      "fill": 0,
      "fillGradient": 0,
      "gridPos": {
        "h": 7,
        "w": 8,
        "x": 8,
        "y": 8
      },
      "height": "300",
      "hiddenSeries": false,
      "id": 195,
      "legend": {
        "alignAsTable": false,
        "avg": false,
        "current": true,
        "max": false,
        "min": false,
        "rightSide": false,
        "show": true,
        "sort": "current",
        "sortDesc": false,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 2,
      "links": [],
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "10.3.7",
      "pointradius": 5,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [
        {
          "$$hashKey": "object:2494",
          "alias": "Total",
          "color": "#C4162A",
          "fill": 0
        },
        {
          "$$hashKey": "object:2495",
          "alias": "Overall Average Used%",
          "lines": false,
          "pointradius": 1,
          "points": true,
          "yaxis": 2
        }
      ],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "sum(node_memory_MemTotal_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"})",
          "format": "time_series",
          "hide": false,
          "instant": false,
          "interval": "30m",
          "intervalFactor": 1,
          "legendFormat": "Total",
          "refId": "A",
          "step": 4
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "sum(node_memory_MemTotal_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"} - node_memory_MemAvailable_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"})",
          "format": "time_series",
          "hide": false,
          "interval": "30m",
          "intervalFactor": 1,
          "legendFormat": "Total Used",
          "refId": "B",
          "step": 4
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "(sum(node_memory_MemTotal_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"} - node_memory_MemAvailable_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"}) / sum(node_memory_MemTotal_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"}))*100",
          "format": "time_series",
          "hide": false,
          "interval": "30m",
          "intervalFactor": 1,
          "legendFormat": "Overall Average Used%",
          "refId": "H"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "$job：Overall total memory & average memory used%",
      "tooltip": {
        "shared": true,
        "sort": 2,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "$$hashKey": "object:8938",
          "format": "bytes",
          "label": "Total",
          "logBase": 1,
          "min": "0",
          "show": true
        },
        {
          "$$hashKey": "object:8939",
          "format": "percent",
          "label": "Overall Average Used%",
          "logBase": 1,
          "show": true
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "decimals": 1,
      "description": "",
      "fieldConfig": {
        "defaults": {
          "links": [],
          "unitScale": true
        },
        "overrides": []
      },
      "fill": 0,
      "fillGradient": 0,
      "gridPos": {
        "h": 7,
        "w": 8,
        "x": 16,
        "y": 8
      },
      "hiddenSeries": false,
      "id": 197,
      "legend": {
        "alignAsTable": false,
        "avg": false,
        "current": true,
        "hideEmpty": false,
        "hideZero": false,
        "max": false,
        "min": false,
        "rightSide": false,
        "show": true,
        "sort": "current",
        "sortDesc": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 2,
      "links": [],
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "10.3.7",
      "pointradius": 5,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [
        {
          "$$hashKey": "object:2617",
          "alias": "Overall Average Used%",
          "lines": false,
          "pointradius": 1,
          "points": true,
          "yaxis": 2
        },
        {
          "$$hashKey": "object:2618",
          "alias": "Total",
          "color": "#C4162A"
        }
      ],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "sum(avg(node_filesystem_size_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",fstype=~\"xfs|ext.*\"})by(device,instance))",
          "format": "time_series",
          "instant": false,
          "interval": "30m",
          "intervalFactor": 1,
          "legendFormat": "Total",
          "refId": "E"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "sum(avg(node_filesystem_size_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",fstype=~\"xfs|ext.*\"})by(device,instance)) - sum(avg(node_filesystem_free_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",fstype=~\"xfs|ext.*\"})by(device,instance))",
          "format": "time_series",
          "instant": false,
          "interval": "30m",
          "intervalFactor": 1,
          "legendFormat": "Total Used",
          "refId": "C"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "(sum(avg(node_filesystem_size_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",fstype=~\"xfs|ext.*\"})by(device,instance)) - sum(avg(node_filesystem_free_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",fstype=~\"xfs|ext.*\"})by(device,instance))) *100/(sum(avg(node_filesystem_avail_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",fstype=~\"xfs|ext.*\"})by(device,instance))+(sum(avg(node_filesystem_size_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",fstype=~\"xfs|ext.*\"})by(device,instance)) - sum(avg(node_filesystem_free_bytes{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",fstype=~\"xfs|ext.*\"})by(device,instance))))",
          "format": "time_series",
          "instant": false,
          "interval": "30m",
          "intervalFactor": 1,
          "legendFormat": "Overall Average Used%",
          "refId": "A"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "$job：Overall total disk & average disk used%",
      "tooltip": {
        "shared": true,
        "sort": 2,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "$$hashKey": "object:8990",
          "decimals": 1,
          "format": "bytes",
          "label": "Total",
          "logBase": 1,
          "min": "0",
          "show": true
        },
        {
          "$$hashKey": "object:8991",
          "format": "percent",
          "label": "Overall Average Used%",
          "logBase": 1,
          "show": true
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "collapsed": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "gridPos": {
        "h": 1,
        "w": 24,
        "x": 0,
        "y": 15
      },
      "id": 189,
      "panels": [],
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "refId": "A"
        }
      ],
      "title": "Resource Details：【$show_hostname】",
      "type": "row"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "decimals": 0,
          "mappings": [
            {
              "options": {
                "match": "null",
                "result": {
                  "text": "N/A"
                }
              },
              "type": "special"
            }
          ],
          "nullValueMode": "null",
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "rgba(245, 54, 54, 0.9)"
              },
              {
                "color": "rgba(237, 129, 40, 0.89)",
                "value": 1
              },
              {
                "color": "rgba(50, 172, 45, 0.97)",
                "value": 3
              }
            ]
          },
          "unit": "s"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 2,
        "w": 2,
        "x": 0,
        "y": 16
      },
      "hideTimeOverride": true,
      "id": 15,
      "links": [],
      "maxDataPoints": 100,
      "options": {
        "colorMode": "value",
        "graphMode": "none",
        "justifyMode": "auto",
        "orientation": "horizontal",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "",
          "values": false
        },
        "textMode": "auto"
      },
      "pluginVersion": "7.2.0",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "avg(time() - node_boot_time_seconds{instance=~\"$node\"})",
          "format": "time_series",
          "hide": false,
          "instant": true,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A",
          "step": 40
        }
      ],
      "title": "Uptime",
      "type": "stat"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "fieldConfig": {
        "defaults": {
          "color": {
            "mode": "thresholds"
          },
          "custom": {},
          "decimals": 1,
          "mappings": [
            {
              "options": {
                "0": {
                  "text": "N/A"
                }
              },
              "type": "value"
            }
          ],
          "max": 100,
          "min": 0.1,
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "green"
              },
              {
                "color": "#EAB839",
                "value": 70
              },
              {
                "color": "red",
                "value": 90
              }
            ]
          },
          "unit": "percent"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 6,
        "w": 3,
        "x": 2,
        "y": 16
      },
      "id": 177,
      "options": {
        "displayMode": "lcd",
        "orientation": "horizontal",
        "reduceOptions": {
          "calcs": [
            "last"
          ],
          "fields": "",
          "values": false
        },
        "showUnfilled": true
      },
      "pluginVersion": "7.2.0",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "100 - (avg(rate(node_cpu_seconds_total{instance=~\"$node\",mode=\"idle\"}[$interval])) * 100)",
          "instant": true,
          "interval": "",
          "legendFormat": "CPU Busy",
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "avg(rate(node_cpu_seconds_total{instance=~\"$node\",mode=\"iowait\"}[$interval])) * 100",
          "hide": true,
          "instant": true,
          "interval": "",
          "legendFormat": "IOwait使用率",
          "refId": "C"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "(1 - (node_memory_MemAvailable_bytes{instance=~\"$node\"} / (node_memory_MemTotal_bytes{instance=~\"$node\"})))* 100",
          "instant": true,
          "interval": "",
          "legendFormat": "Used RAM Memory",
          "refId": "B"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "(node_filesystem_size_bytes{instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint=\"$maxmount\"}-node_filesystem_free_bytes{instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint=\"$maxmount\"})*100 /(node_filesystem_avail_bytes {instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint=\"$maxmount\"}+(node_filesystem_size_bytes{instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint=\"$maxmount\"}-node_filesystem_free_bytes{instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint=\"$maxmount\"}))",
          "hide": false,
          "instant": true,
          "interval": "",
          "legendFormat": "Used Max Mount($maxmount)",
          "refId": "D"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "(1 - ((node_memory_SwapFree_bytes{instance=~\"$node\"} + 1)/ (node_memory_SwapTotal_bytes{instance=~\"$node\"} + 1))) * 100",
          "instant": true,
          "interval": "",
          "legendFormat": "Used SWAP",
          "refId": "F"
        }
      ],
      "transformations": [],
      "type": "bargauge"
    },
    {
      "columns": [],
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "description": "In this kanban: the total disk, usage, available, and usage rate are consistent with the values of the Size, Used, Avail, and Use% columns of the df command, and the value of Use% will be rounded to one decimal place, which will be more accurate .\n\nNote: The Use% algorithm in df is: (size-free) * 100 / (avail + (size-free)), the result is divisible by this value, non-divisible by this value is +1, and the unit of the result is %.\nRefer to the df command source code:",
      "fieldConfig": {
        "defaults": {
          "custom": {}
        },
        "overrides": []
      },
      "fontSize": "80%",
      "gridPos": {
        "h": 6,
        "w": 10,
        "x": 5,
        "y": 16
      },
      "id": 181,
      "links": [
        {
          "targetBlank": true,
          "title": "https://github.com/coreutils/coreutils/blob/master/src/df.c",
          "url": "https://github.com/coreutils/coreutils/blob/master/src/df.c"
        }
      ],
      "scroll": true,
      "showHeader": true,
      "sort": {
        "col": 6,
        "desc": false
      },
      "styles": [
        {
          "$$hashKey": "object:307",
          "alias": "Mounted on",
          "align": "auto",
          "colors": [
            "rgba(50, 172, 45, 0.97)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(245, 54, 54, 0.9)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 2,
          "mappingType": 1,
          "pattern": "mountpoint",
          "thresholds": [
            ""
          ],
          "type": "string",
          "unit": "bytes"
        },
        {
          "$$hashKey": "object:308",
          "alias": "Avail",
          "align": "auto",
          "colorMode": "value",
          "colors": [
            "rgba(245, 54, 54, 0.9)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(50, 172, 45, 0.97)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 1,
          "mappingType": 1,
          "pattern": "Value #A",
          "thresholds": [
            "10000000000",
            "20000000000"
          ],
          "type": "number",
          "unit": "bytes"
        },
        {
          "$$hashKey": "object:309",
          "alias": "Used",
          "align": "auto",
          "colorMode": "cell",
          "colors": [
            "rgba(50, 172, 45, 0.97)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(245, 54, 54, 0.9)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 1,
          "mappingType": 1,
          "pattern": "Value #B",
          "thresholds": [
            "70",
            "85"
          ],
          "type": "number",
          "unit": "percent"
        },
        {
          "$$hashKey": "object:310",
          "alias": "Size",
          "align": "auto",
          "colors": [
            "rgba(245, 54, 54, 0.9)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(50, 172, 45, 0.97)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 0,
          "link": false,
          "mappingType": 1,
          "pattern": "Value #C",
          "thresholds": [],
          "type": "number",
          "unit": "bytes"
        },
        {
          "$$hashKey": "object:311",
          "alias": "Filesystem",
          "align": "auto",
          "colors": [
            "rgba(245, 54, 54, 0.9)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(50, 172, 45, 0.97)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 2,
          "link": false,
          "mappingType": 1,
          "pattern": "fstype",
          "thresholds": [],
          "type": "string",
          "unit": "short"
        },
        {
          "$$hashKey": "object:312",
          "alias": "Device",
          "align": "auto",
          "colors": [
            "rgba(245, 54, 54, 0.9)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(50, 172, 45, 0.97)"
          ],
          "dateFormat": "YYYY-MM-DD HH:mm:ss",
          "decimals": 2,
          "link": false,
          "mappingType": 1,
          "pattern": "device",
          "preserveFormat": false,
          "sanitize": false,
          "thresholds": [],
          "type": "string",
          "unit": "short"
        },
        {
          "$$hashKey": "object:313",
          "alias": "",
          "align": "auto",
          "colors": [
            "rgba(245, 54, 54, 0.9)",
            "rgba(237, 129, 40, 0.89)",
            "rgba(50, 172, 45, 0.97)"
          ],
          "decimals": 2,
          "pattern": "/.*/",
          "preserveFormat": true,
          "sanitize": false,
          "thresholds": [],
          "type": "hidden",
          "unit": "short"
        }
      ],
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_filesystem_size_bytes{instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint !~\".*pod.*\"}-0",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "总量",
          "refId": "C"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_filesystem_avail_bytes {instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint !~\".*pod.*\"}-0",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "10s",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "(node_filesystem_size_bytes{instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint !~\".*pod.*\"}-node_filesystem_free_bytes{instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint !~\".*pod.*\"}) *100/(node_filesystem_avail_bytes {instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint !~\".*pod.*\"}+(node_filesystem_size_bytes{instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint !~\".*pod.*\"}-node_filesystem_free_bytes{instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint !~\".*pod.*\"}))",
          "format": "table",
          "hide": false,
          "instant": true,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "B"
        }
      ],
      "title": "【$show_hostname】：Disk Space Used Basic(EXT?/XFS)",
      "transform": "table",
      "type": "table-old"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "decimals": 2,
          "mappings": [
            {
              "options": {
                "match": "null",
                "result": {
                  "text": "N/A"
                }
              },
              "type": "special"
            }
          ],
          "nullValueMode": "connected",
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "rgba(50, 172, 45, 0.97)"
              },
              {
                "color": "rgba(237, 129, 40, 0.89)",
                "value": 20
              },
              {
                "color": "#d44a3a",
                "value": 50
              }
            ]
          },
          "unit": "percent"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 2,
        "w": 2,
        "x": 15,
        "y": 16
      },
      "id": 20,
      "links": [],
      "maxDataPoints": 100,
      "options": {
        "colorMode": "value",
        "graphMode": "area",
        "justifyMode": "auto",
        "orientation": "horizontal",
        "reduceOptions": {
          "calcs": [
            "last"
          ],
          "fields": "",
          "values": false
        },
        "textMode": "auto"
      },
      "pluginVersion": "7.2.0",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "avg(rate(node_cpu_seconds_total{instance=~\"$node\",mode=\"iowait\"}[$interval])) * 100",
          "format": "time_series",
          "hide": false,
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A",
          "step": 20
        }
      ],
      "title": "CPU iowait",
      "type": "stat"
    },
    {
      "aliasColors": {
        "cn-shenzhen.i-wz9cq1dcb6zwc39ehw59_cni0_in": "light-red",
        "cn-shenzhen.i-wz9cq1dcb6zwc39ehw59_cni0_in下载": "green",
        "cn-shenzhen.i-wz9cq1dcb6zwc39ehw59_cni0_out上传": "yellow",
        "cn-shenzhen.i-wz9cq1dcb6zwc39ehw59_eth0_in下载": "purple",
        "cn-shenzhen.i-wz9cq1dcb6zwc39ehw59_eth0_out": "purple",
        "cn-shenzhen.i-wz9cq1dcb6zwc39ehw59_eth0_out上传": "blue"
      },
      "bars": true,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "editable": true,
      "error": false,
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "links": []
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 0,
      "grid": {},
      "gridPos": {
        "h": 6,
        "w": 7,
        "x": 17,
        "y": 16
      },
      "hiddenSeries": false,
      "id": 183,
      "legend": {
        "alignAsTable": true,
        "avg": true,
        "current": true,
        "hideEmpty": true,
        "hideZero": true,
        "max": true,
        "min": false,
        "show": false,
        "sort": "current",
        "sortDesc": true,
        "total": true,
        "values": true
      },
      "lines": false,
      "linewidth": 2,
      "links": [],
      "nullPointMode": "null as zero",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.2.0",
      "pointradius": 1,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [
        {
          "$$hashKey": "object:2970",
          "alias": "/.*_transmit$/",
          "transform": "negative-Y"
        }
      ],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "increase(node_network_receive_bytes_total{instance=~\"$node\",device=~\"$device\"}[60m])",
          "interval": "60m",
          "intervalFactor": 1,
          "legendFormat": "{{device}}_receive",
          "metric": "",
          "refId": "A",
          "step": 600,
          "target": ""
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "increase(node_network_transmit_bytes_total{instance=~\"$node\",device=~\"$device\"}[60m])",
          "hide": false,
          "interval": "60m",
          "intervalFactor": 1,
          "legendFormat": "{{device}}_transmit",
          "refId": "B",
          "step": 600
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "Internet traffic per hour $device",
      "tooltip": {
        "msResolution": false,
        "shared": true,
        "sort": 0,
        "value_type": "cumulative"
      },
      "type": "graph",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "$$hashKey": "object:2977",
          "format": "bytes",
          "label": "transmit（-）/receive（+）",
          "logBase": 1,
          "show": true
        },
        {
          "$$hashKey": "object:2978",
          "format": "short",
          "logBase": 1,
          "show": false
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "mappings": [
            {
              "options": {
                "match": "null",
                "result": {
                  "text": "N/A"
                }
              },
              "type": "special"
            }
          ],
          "nullValueMode": "null",
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "rgba(245, 54, 54, 0.9)"
              },
              {
                "color": "rgba(237, 129, 40, 0.89)",
                "value": 1
              },
              {
                "color": "rgba(50, 172, 45, 0.97)",
                "value": 2
              }
            ]
          },
          "unit": "short"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 2,
        "w": 2,
        "x": 0,
        "y": 18
      },
      "id": 14,
      "links": [],
      "maxDataPoints": 100,
      "options": {
        "colorMode": "value",
        "graphMode": "none",
        "justifyMode": "auto",
        "orientation": "horizontal",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "",
          "values": false
        },
        "textMode": "value"
      },
      "pluginVersion": "7.2.0",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "count(node_cpu_seconds_total{instance=~\"$node\", mode='system'})",
          "format": "time_series",
          "instant": true,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A",
          "step": 20
        }
      ],
      "title": "CPU Cores",
      "type": "stat"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "mappings": [
            {
              "options": {
                "match": "null",
                "result": {
                  "text": "N/A"
                }
              },
              "type": "special"
            }
          ],
          "nullValueMode": "null",
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "rgba(245, 54, 54, 0.9)"
              },
              {
                "color": "rgba(237, 129, 40, 0.89)",
                "value": 100000
              },
              {
                "color": "rgba(50, 172, 45, 0.97)",
                "value": 1000000
              }
            ]
          },
          "unit": "short"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 2,
        "w": 2,
        "x": 15,
        "y": 18
      },
      "id": 179,
      "links": [],
      "maxDataPoints": 100,
      "options": {
        "colorMode": "value",
        "graphMode": "none",
        "justifyMode": "auto",
        "orientation": "horizontal",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "",
          "values": false
        },
        "textMode": "auto"
      },
      "pluginVersion": "7.2.0",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "avg(node_filesystem_files_free{instance=~\"$node\",mountpoint=\"$maxmount\",fstype=~\"ext.?|xfs\"})",
          "format": "time_series",
          "instant": true,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A",
          "step": 20
        }
      ],
      "title": "Free inodes:$maxmount ",
      "type": "stat"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "decimals": 0,
          "mappings": [
            {
              "options": {
                "match": "null",
                "result": {
                  "text": "N/A"
                }
              },
              "type": "special"
            }
          ],
          "nullValueMode": "null",
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "rgba(245, 54, 54, 0.9)"
              },
              {
                "color": "rgba(237, 129, 40, 0.89)",
                "value": 2
              },
              {
                "color": "rgba(50, 172, 45, 0.97)",
                "value": 3
              }
            ]
          },
          "unit": "bytes"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 2,
        "w": 2,
        "x": 0,
        "y": 20
      },
      "id": 75,
      "links": [],
      "maxDataPoints": 100,
      "options": {
        "colorMode": "value",
        "graphMode": "none",
        "justifyMode": "auto",
        "orientation": "horizontal",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "",
          "values": false
        },
        "textMode": "auto"
      },
      "pluginVersion": "7.2.0",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "sum(node_memory_MemTotal_bytes{instance=~\"$node\"})",
          "format": "time_series",
          "instant": true,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{instance}}",
          "refId": "A",
          "step": 20
        }
      ],
      "title": "Total RAM",
      "type": "stat"
    },
    {
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "mappings": [
            {
              "options": {
                "match": "null",
                "result": {
                  "text": "N/A"
                }
              },
              "type": "special"
            }
          ],
          "nullValueMode": "null",
          "thresholds": {
            "mode": "absolute",
            "steps": [
              {
                "color": "rgba(245, 54, 54, 0.9)"
              },
              {
                "color": "rgba(237, 129, 40, 0.89)",
                "value": 1024
              },
              {
                "color": "rgba(50, 172, 45, 0.97)",
                "value": 10000
              }
            ]
          },
          "unit": "locale"
        },
        "overrides": []
      },
      "gridPos": {
        "h": 2,
        "w": 2,
        "x": 15,
        "y": 20
      },
      "id": 178,
      "links": [],
      "maxDataPoints": 100,
      "options": {
        "colorMode": "value",
        "graphMode": "none",
        "justifyMode": "auto",
        "orientation": "horizontal",
        "reduceOptions": {
          "calcs": [
            "lastNotNull"
          ],
          "fields": "",
          "values": false
        },
        "textMode": "auto"
      },
      "pluginVersion": "7.2.0",
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "avg(node_filefd_maximum{instance=~\"$node\"})",
          "format": "time_series",
          "instant": true,
          "intervalFactor": 1,
          "legendFormat": "",
          "refId": "A",
          "step": 20
        }
      ],
      "title": "Total filefd",
      "type": "stat"
    },
    {
      "aliasColors": {
        "192.168.200.241:9100_Total": "dark-red",
        "Idle - Waiting for something to happen": "#052B51",
        "guest": "#9AC48A",
        "idle": "#052B51",
        "iowait": "#EAB839",
        "irq": "#BF1B00",
        "nice": "#C15C17",
        "sdb_每秒I/O操作%": "#d683ce",
        "softirq": "#E24D42",
        "steal": "#FCE2DE",
        "system": "#508642",
        "user": "#5195CE",
        "磁盘花费在I/O操作占比": "#ba43a9"
      },
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "decimals": 2,
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "links": []
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 8,
        "w": 8,
        "x": 0,
        "y": 22
      },
      "hiddenSeries": false,
      "id": 7,
      "legend": {
        "alignAsTable": true,
        "avg": true,
        "current": true,
        "hideEmpty": true,
        "hideZero": true,
        "max": true,
        "min": true,
        "rightSide": false,
        "show": true,
        "sort": "current",
        "sortDesc": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 2,
      "links": [],
      "maxPerRow": 6,
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.2.0",
      "pointradius": 5,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [
        {
          "$$hashKey": "object:3051",
          "alias": "/.*Total/",
          "color": "#C4162A",
          "fill": 0
        }
      ],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "avg(rate(node_cpu_seconds_total{instance=~\"$node\",mode=\"system\"}[$interval])) by (instance) *100",
          "format": "time_series",
          "hide": false,
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "System",
          "refId": "A",
          "step": 20
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "avg(rate(node_cpu_seconds_total{instance=~\"$node\",mode=\"user\"}[$interval])) by (instance) *100",
          "format": "time_series",
          "hide": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "User",
          "refId": "B",
          "step": 240
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "avg(rate(node_cpu_seconds_total{instance=~\"$node\",mode=\"iowait\"}[$interval])) by (instance) *100",
          "format": "time_series",
          "hide": false,
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "Iowait",
          "refId": "D",
          "step": 240
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "(1 - avg(rate(node_cpu_seconds_total{instance=~\"$node\",mode=\"idle\"}[$interval])) by (instance))*100",
          "format": "time_series",
          "hide": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "Total",
          "refId": "F",
          "step": 240
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "CPU% Basic",
      "tooltip": {
        "shared": true,
        "sort": 2,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "$$hashKey": "object:11294",
          "decimals": 0,
          "format": "percent",
          "label": "",
          "logBase": 1,
          "show": true
        },
        {
          "$$hashKey": "object:11295",
          "format": "short",
          "logBase": 1,
          "show": false
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "aliasColors": {
        "192.168.200.241:9100_总内存": "dark-red",
        "使用率": "yellow",
        "内存_Avaliable": "#6ED0E0",
        "内存_Cached": "#EF843C",
        "内存_Free": "#629E51",
        "内存_Total": "#6d1f62",
        "内存_Used": "#eab839",
        "可用": "#9ac48a",
        "总内存": "#bf1b00"
      },
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "decimals": 2,
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "links": []
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 8,
        "w": 8,
        "x": 8,
        "y": 22
      },
      "height": "300",
      "hiddenSeries": false,
      "id": 156,
      "legend": {
        "alignAsTable": true,
        "avg": true,
        "current": true,
        "hideEmpty": true,
        "hideZero": true,
        "max": true,
        "min": true,
        "rightSide": false,
        "show": true,
        "sort": "current",
        "sortDesc": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 2,
      "links": [],
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.2.0",
      "pointradius": 5,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [
        {
          "$$hashKey": "object:3234",
          "alias": "Total",
          "color": "#C4162A",
          "fill": 0
        },
        {
          "$$hashKey": "object:3235",
          "alias": "Used%",
          "color": "rgb(0, 209, 255)",
          "lines": false,
          "pointradius": 1,
          "points": true,
          "yaxis": 2
        }
      ],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_memory_MemTotal_bytes{instance=~\"$node\"}",
          "format": "time_series",
          "hide": false,
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "Total",
          "refId": "A",
          "step": 4
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_memory_MemTotal_bytes{instance=~\"$node\"} - node_memory_MemAvailable_bytes{instance=~\"$node\"}",
          "format": "time_series",
          "hide": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "Used",
          "refId": "B",
          "step": 4
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_memory_MemAvailable_bytes{instance=~\"$node\"}",
          "format": "time_series",
          "hide": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "Avaliable",
          "refId": "F",
          "step": 4
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_memory_Buffers_bytes{instance=~\"$node\"}",
          "format": "time_series",
          "hide": true,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "内存_Buffers",
          "refId": "D",
          "step": 4
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_memory_MemFree_bytes{instance=~\"$node\"}",
          "format": "time_series",
          "hide": true,
          "intervalFactor": 1,
          "legendFormat": "内存_Free",
          "refId": "C",
          "step": 4
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_memory_Cached_bytes{instance=~\"$node\"}",
          "format": "time_series",
          "hide": true,
          "intervalFactor": 1,
          "legendFormat": "内存_Cached",
          "refId": "E",
          "step": 4
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_memory_MemTotal_bytes{instance=~\"$node\"} - (node_memory_Cached_bytes{instance=~\"$node\"} + node_memory_Buffers_bytes{instance=~\"$node\"} + node_memory_MemFree_bytes{instance=~\"$node\"})",
          "format": "time_series",
          "hide": true,
          "intervalFactor": 1,
          "refId": "G"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "(1 - (node_memory_MemAvailable_bytes{instance=~\"$node\"} / (node_memory_MemTotal_bytes{instance=~\"$node\"})))* 100",
          "format": "time_series",
          "hide": false,
          "interval": "30m",
          "intervalFactor": 10,
          "legendFormat": "Used%",
          "refId": "H"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "Memory Basic",
      "tooltip": {
        "shared": true,
        "sort": 2,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "$$hashKey": "object:3130",
          "format": "bytes",
          "logBase": 1,
          "min": "0",
          "show": true
        },
        {
          "$$hashKey": "object:3131",
          "format": "percent",
          "label": "Utilization%",
          "logBase": 1,
          "max": "100",
          "min": "0",
          "show": true
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "aliasColors": {
        "192.168.10.227:9100_em1_in下载": "super-light-green",
        "192.168.10.227:9100_em1_out上传": "dark-blue"
      },
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "decimals": 2,
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "links": []
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 8,
        "w": 8,
        "x": 16,
        "y": 22
      },
      "height": "300",
      "hiddenSeries": false,
      "id": 157,
      "legend": {
        "alignAsTable": true,
        "avg": true,
        "current": true,
        "hideEmpty": true,
        "hideZero": true,
        "max": true,
        "min": true,
        "rightSide": false,
        "show": true,
        "sort": "current",
        "sortDesc": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 1,
      "links": [],
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.2.0",
      "pointradius": 2,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [
        {
          "$$hashKey": "object:3308",
          "alias": "/.*_transmit$/",
          "transform": "negative-Y"
        }
      ],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_network_receive_bytes_total{instance=~'$node',device=~\"$device\"}[$interval])*8",
          "format": "time_series",
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{device}}_receive",
          "refId": "A",
          "step": 4
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_network_transmit_bytes_total{instance=~'$node',device=~\"$device\"}[$interval])*8",
          "format": "time_series",
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{device}}_transmit",
          "refId": "B",
          "step": 4
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "Network bandwidth usage per second $device",
      "tooltip": {
        "shared": true,
        "sort": 2,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "$$hashKey": "object:3315",
          "format": "bps",
          "label": "transmit（-）/receive（+）",
          "logBase": 1,
          "show": true
        },
        {
          "$$hashKey": "object:3316",
          "format": "short",
          "logBase": 1,
          "show": false
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "aliasColors": {
        "15分钟": "#6ED0E0",
        "1分钟": "#BF1B00",
        "5分钟": "#CCA300"
      },
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "decimals": 2,
      "editable": true,
      "error": false,
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "links": []
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 1,
      "grid": {},
      "gridPos": {
        "h": 8,
        "w": 8,
        "x": 0,
        "y": 30
      },
      "height": "300",
      "hiddenSeries": false,
      "id": 13,
      "legend": {
        "alignAsTable": true,
        "avg": true,
        "current": true,
        "hideEmpty": true,
        "hideZero": true,
        "max": true,
        "min": true,
        "rightSide": false,
        "show": true,
        "sort": "current",
        "sortDesc": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 2,
      "links": [],
      "maxPerRow": 6,
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.2.0",
      "pointradius": 5,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [
        {
          "$$hashKey": "object:3389",
          "alias": "/.*CPU cores/",
          "color": "#C4162A"
        }
      ],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_load1{instance=~\"$node\"}",
          "format": "time_series",
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "1m",
          "metric": "",
          "refId": "A",
          "step": 20,
          "target": ""
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_load5{instance=~\"$node\"}",
          "format": "time_series",
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "5m",
          "refId": "B",
          "step": 20
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_load15{instance=~\"$node\"}",
          "format": "time_series",
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "15m",
          "refId": "C",
          "step": 20
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": " sum(count(node_cpu_seconds_total{instance=~\"$node\", mode='system'}) by (cpu,instance)) by(instance)",
          "format": "time_series",
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "CPU cores",
          "refId": "D",
          "step": 20
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "System Load",
      "tooltip": {
        "msResolution": false,
        "shared": true,
        "sort": 2,
        "value_type": "cumulative"
      },
      "type": "graph",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "$$hashKey": "object:3396",
          "format": "short",
          "logBase": 1,
          "show": true
        },
        {
          "$$hashKey": "object:3397",
          "format": "short",
          "logBase": 1,
          "show": true
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "aliasColors": {
        "vda_write": "#6ED0E0"
      },
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "decimals": 2,
      "description": "Per second read / write bytes ",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "links": []
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 1,
      "gridPos": {
        "h": 8,
        "w": 8,
        "x": 8,
        "y": 30
      },
      "height": "300",
      "hiddenSeries": false,
      "id": 168,
      "legend": {
        "alignAsTable": true,
        "avg": true,
        "current": true,
        "hideEmpty": true,
        "hideZero": true,
        "max": true,
        "min": true,
        "show": true,
        "sort": "current",
        "sortDesc": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 2,
      "links": [],
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.2.0",
      "pointradius": 5,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [
        {
          "$$hashKey": "object:3474",
          "alias": "/.*_Read bytes$/",
          "transform": "negative-Y"
        }
      ],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_disk_read_bytes_total{instance=~\"$node\"}[$interval])",
          "format": "time_series",
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{device}}_Read bytes",
          "refId": "A",
          "step": 10
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_disk_written_bytes_total{instance=~\"$node\"}[$interval])",
          "format": "time_series",
          "hide": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{device}}_Written bytes",
          "refId": "B",
          "step": 10
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "Disk R/W Data",
      "tooltip": {
        "shared": true,
        "sort": 2,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "$$hashKey": "object:3481",
          "format": "Bps",
          "label": "Bytes read (-) / write (+)",
          "logBase": 1,
          "show": true
        },
        {
          "$$hashKey": "object:3482",
          "format": "short",
          "logBase": 1,
          "show": false
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "aliasColors": {},
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "decimals": 1,
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "links": []
        },
        "overrides": []
      },
      "fill": 0,
      "fillGradient": 0,
      "gridPos": {
        "h": 8,
        "w": 8,
        "x": 16,
        "y": 30
      },
      "hiddenSeries": false,
      "id": 174,
      "legend": {
        "alignAsTable": true,
        "avg": true,
        "current": true,
        "hideEmpty": true,
        "hideZero": true,
        "max": true,
        "min": true,
        "rightSide": false,
        "show": true,
        "sort": "current",
        "sortDesc": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 2,
      "links": [],
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.2.0",
      "pointradius": 5,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [
        {
          "$$hashKey": "object:3554",
          "alias": "/Inodes.*/",
          "yaxis": 2
        }
      ],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "(node_filesystem_size_bytes{instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint !~\".*pod.*\"}-node_filesystem_free_bytes{instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint !~\".*pod.*\"}) *100/(node_filesystem_avail_bytes {instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint !~\".*pod.*\"}+(node_filesystem_size_bytes{instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint !~\".*pod.*\"}-node_filesystem_free_bytes{instance=~'$node',fstype=~\"ext.*|xfs\",mountpoint !~\".*pod.*\"}))",
          "format": "time_series",
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{mountpoint}}",
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_filesystem_files_free{instance=~'$node',fstype=~\"ext.?|xfs\"} / node_filesystem_files{instance=~'$node',fstype=~\"ext.?|xfs\"}",
          "hide": true,
          "interval": "",
          "legendFormat": "Inodes：{{instance}}：{{mountpoint}}",
          "refId": "B"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "Disk Space Used% Basic",
      "tooltip": {
        "shared": true,
        "sort": 2,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "$$hashKey": "object:3561",
          "format": "percent",
          "label": "",
          "logBase": 1,
          "max": "100",
          "min": "0",
          "show": true
        },
        {
          "$$hashKey": "object:3562",
          "decimals": 2,
          "format": "percentunit",
          "logBase": 1,
          "max": "1",
          "show": false
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "aliasColors": {
        "vda_write": "#6ED0E0"
      },
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "decimals": 2,
      "description": "Read/write completions per second\n\nWrites completed: 每个磁盘分区每秒写完成次数\n\nIO now 每个磁盘分区每秒正在处理的输入/输出请求数",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "links": []
        },
        "overrides": []
      },
      "fill": 0,
      "fillGradient": 0,
      "gridPos": {
        "h": 9,
        "w": 8,
        "x": 0,
        "y": 38
      },
      "height": "300",
      "hiddenSeries": false,
      "id": 161,
      "legend": {
        "alignAsTable": true,
        "avg": true,
        "current": true,
        "hideEmpty": true,
        "hideZero": true,
        "max": true,
        "min": true,
        "show": true,
        "sort": "current",
        "sortDesc": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 1,
      "links": [],
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.2.0",
      "pointradius": 5,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [
        {
          "$$hashKey": "object:3711",
          "alias": "/.*_Reads completed$/",
          "transform": "negative-Y"
        }
      ],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_disk_reads_completed_total{instance=~\"$node\"}[$interval])",
          "format": "time_series",
          "hide": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{device}}_Reads completed",
          "refId": "A",
          "step": 10
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_disk_writes_completed_total{instance=~\"$node\"}[$interval])",
          "format": "time_series",
          "hide": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{device}}_Writes completed",
          "refId": "B",
          "step": 10
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_disk_io_now{instance=~\"$node\"}",
          "format": "time_series",
          "hide": true,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{device}}",
          "refId": "C"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "Disk IOps Completed（IOPS）",
      "tooltip": {
        "shared": true,
        "sort": 2,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "$$hashKey": "object:3718",
          "format": "iops",
          "label": "IO read (-) / write (+)",
          "logBase": 1,
          "show": true
        },
        {
          "$$hashKey": "object:3719",
          "format": "short",
          "logBase": 1,
          "show": true
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "aliasColors": {
        "Idle - Waiting for something to happen": "#052B51",
        "guest": "#9AC48A",
        "idle": "#052B51",
        "iowait": "#EAB839",
        "irq": "#BF1B00",
        "nice": "#C15C17",
        "sdb_每秒I/O操作%": "#d683ce",
        "softirq": "#E24D42",
        "steal": "#FCE2DE",
        "system": "#508642",
        "user": "#5195CE",
        "磁盘花费在I/O操作占比": "#ba43a9"
      },
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "description": "The time spent on I/O in the natural time of each second.（wall-clock time）",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "links": []
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 0,
      "gridPos": {
        "h": 9,
        "w": 8,
        "x": 8,
        "y": 38
      },
      "hiddenSeries": false,
      "id": 175,
      "legend": {
        "alignAsTable": true,
        "avg": true,
        "current": true,
        "hideEmpty": true,
        "hideZero": true,
        "max": true,
        "min": false,
        "rightSide": false,
        "show": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 1,
      "links": [],
      "maxPerRow": 6,
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.2.0",
      "pointradius": 5,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_disk_io_time_seconds_total{instance=~\"$node\"}[$interval])",
          "format": "time_series",
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{device}}_ IO time",
          "refId": "C"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "Time Spent Doing I/Os",
      "tooltip": {
        "shared": true,
        "sort": 2,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "$$hashKey": "object:3796",
          "format": "percentunit",
          "label": "",
          "logBase": 1,
          "show": true
        },
        {
          "$$hashKey": "object:3797",
          "format": "short",
          "logBase": 1,
          "show": false
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "aliasColors": {
        "vda": "#6ED0E0"
      },
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "decimals": 2,
      "description": "Time spent on each read/write operation",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "links": []
        },
        "overrides": []
      },
      "fill": 1,
      "fillGradient": 1,
      "gridPos": {
        "h": 9,
        "w": 8,
        "x": 16,
        "y": 38
      },
      "height": "300",
      "hiddenSeries": false,
      "id": 160,
      "legend": {
        "alignAsTable": true,
        "avg": true,
        "current": true,
        "hideEmpty": true,
        "hideZero": true,
        "max": true,
        "min": true,
        "show": true,
        "sort": "current",
        "sortDesc": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 2,
      "links": [],
      "nullPointMode": "null as zero",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.2.0",
      "pointradius": 5,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [
        {
          "$$hashKey": "object:4023",
          "alias": "/,*_Read time$/",
          "transform": "negative-Y"
        }
      ],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_disk_read_time_seconds_total{instance=~\"$node\"}[$interval]) / rate(node_disk_reads_completed_total{instance=~\"$node\"}[$interval])",
          "format": "time_series",
          "hide": false,
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{device}}_Read time",
          "refId": "B"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_disk_write_time_seconds_total{instance=~\"$node\"}[$interval]) / rate(node_disk_writes_completed_total{instance=~\"$node\"}[$interval])",
          "format": "time_series",
          "hide": false,
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{device}}_Write time",
          "refId": "C"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_disk_io_time_seconds_total{instance=~\"$node\"}[$interval])",
          "format": "time_series",
          "hide": true,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{device}}",
          "refId": "A",
          "step": 10
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_disk_io_time_weighted_seconds_total{instance=~\"$node\"}[$interval])",
          "format": "time_series",
          "hide": true,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "{{device}}_加权",
          "refId": "D"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "Disk R/W Time(Reference: less than 100ms)(beta)",
      "tooltip": {
        "shared": true,
        "sort": 2,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "$$hashKey": "object:4030",
          "format": "s",
          "label": "Time read (-) / write (+)",
          "logBase": 1,
          "show": true
        },
        {
          "$$hashKey": "object:4031",
          "format": "short",
          "logBase": 1,
          "show": false
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "aliasColors": {
        "192.168.200.241:9100_TCP_alloc": "semi-dark-blue",
        "TCP": "#6ED0E0",
        "TCP_alloc": "blue"
      },
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "decimals": 2,
      "description": "Sockets_used - Sockets currently in use\n\nCurrEstab - TCP connections for which the current state is either ESTABLISHED or CLOSE- WAIT\n\nTCP_alloc - Allocated sockets\n\nTCP_tw - Sockets wating close\n\nUDP_inuse - Udp sockets currently in use\n\nRetransSegs - TCP retransmission packets\n\nOutSegs - Number of packets sent by TCP\n\nInSegs - Number of packets received by TCP",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "links": []
        },
        "overrides": []
      },
      "fill": 0,
      "fillGradient": 0,
      "gridPos": {
        "h": 8,
        "w": 16,
        "x": 0,
        "y": 47
      },
      "height": "300",
      "hiddenSeries": false,
      "id": 158,
      "interval": "",
      "legend": {
        "alignAsTable": true,
        "avg": false,
        "current": true,
        "hideEmpty": true,
        "hideZero": true,
        "max": true,
        "min": false,
        "rightSide": true,
        "show": true,
        "sort": "current",
        "sortDesc": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 1,
      "links": [],
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.2.0",
      "pointradius": 5,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [
        {
          "$$hashKey": "object:4103",
          "alias": "/.*Sockets_used/",
          "color": "#E02F44",
          "lines": false,
          "pointradius": 1,
          "points": true,
          "yaxis": 2
        }
      ],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_netstat_Tcp_CurrEstab{instance=~'$node'}",
          "format": "time_series",
          "hide": false,
          "instant": false,
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "CurrEstab",
          "refId": "A",
          "step": 20
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_sockstat_TCP_tw{instance=~'$node'}",
          "format": "time_series",
          "interval": "",
          "intervalFactor": 1,
          "legendFormat": "TCP_tw",
          "refId": "D"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_sockstat_sockets_used{instance=~'$node'}",
          "hide": false,
          "interval": "30m",
          "intervalFactor": 1,
          "legendFormat": "Sockets_used",
          "refId": "B"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_sockstat_UDP_inuse{instance=~'$node'}",
          "interval": "",
          "legendFormat": "UDP_inuse",
          "refId": "C"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_sockstat_TCP_alloc{instance=~'$node'}",
          "interval": "",
          "legendFormat": "TCP_alloc",
          "refId": "E"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_netstat_Tcp_PassiveOpens{instance=~'$node'}[$interval])",
          "hide": true,
          "interval": "",
          "legendFormat": "{{instance}}_Tcp_PassiveOpens",
          "refId": "G"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_netstat_Tcp_ActiveOpens{instance=~'$node'}[$interval])",
          "hide": true,
          "interval": "",
          "legendFormat": "{{instance}}_Tcp_ActiveOpens",
          "refId": "F"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_netstat_Tcp_InSegs{instance=~'$node'}[$interval])",
          "interval": "",
          "legendFormat": "Tcp_InSegs",
          "refId": "H"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_netstat_Tcp_OutSegs{instance=~'$node'}[$interval])",
          "interval": "",
          "legendFormat": "Tcp_OutSegs",
          "refId": "I"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_netstat_Tcp_RetransSegs{instance=~'$node'}[$interval])",
          "hide": false,
          "interval": "",
          "legendFormat": "Tcp_RetransSegs",
          "refId": "J"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_netstat_TcpExt_ListenDrops{instance=~'$node'}[$interval])",
          "hide": true,
          "interval": "",
          "legendFormat": "",
          "refId": "K"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "Network Sockstat",
      "tooltip": {
        "shared": true,
        "sort": 2,
        "value_type": "individual"
      },
      "transformations": [],
      "type": "graph",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "$$hashKey": "object:4118",
          "format": "short",
          "logBase": 1,
          "show": true
        },
        {
          "$$hashKey": "object:4119",
          "format": "short",
          "label": "Total_Sockets_used",
          "logBase": 1,
          "show": true
        }
      ],
      "yaxis": {
        "align": false
      }
    },
    {
      "aliasColors": {
        "filefd_192.168.200.241:9100": "super-light-green",
        "switches_192.168.200.241:9100": "semi-dark-red",
        "使用的文件描述符_10.118.72.128:9100": "red",
        "每秒上下文切换次数_10.118.71.245:9100": "yellow",
        "每秒上下文切换次数_10.118.72.128:9100": "yellow"
      },
      "bars": false,
      "dashLength": 10,
      "dashes": false,
      "datasource": {
        "type": "prometheus",
        "uid": "PBFA97CFB590B2093"
      },
      "description": "",
      "fieldConfig": {
        "defaults": {
          "custom": {},
          "links": []
        },
        "overrides": []
      },
      "fill": 0,
      "fillGradient": 1,
      "gridPos": {
        "h": 8,
        "w": 8,
        "x": 16,
        "y": 47
      },
      "hiddenSeries": false,
      "hideTimeOverride": false,
      "id": 16,
      "legend": {
        "alignAsTable": false,
        "avg": false,
        "current": true,
        "max": false,
        "min": false,
        "rightSide": false,
        "show": true,
        "total": false,
        "values": true
      },
      "lines": true,
      "linewidth": 2,
      "links": [],
      "nullPointMode": "null",
      "options": {
        "alertThreshold": true
      },
      "percentage": false,
      "pluginVersion": "7.2.0",
      "pointradius": 1,
      "points": false,
      "renderer": "flot",
      "seriesOverrides": [
        {
          "$$hashKey": "object:4197",
          "alias": "switches",
          "color": "#FADE2A",
          "lines": false,
          "pointradius": 1,
          "points": true,
          "yaxis": 2
        },
        {
          "$$hashKey": "object:4198",
          "alias": "used filefd",
          "color": "#F2495C"
        }
      ],
      "spaceLength": 10,
      "stack": false,
      "steppedLine": false,
      "targets": [
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "node_filefd_allocated{instance=~\"$node\"}",
          "format": "time_series",
          "instant": false,
          "interval": "",
          "intervalFactor": 5,
          "legendFormat": "used filefd",
          "refId": "B"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "rate(node_context_switches_total{instance=~\"$node\"}[$interval])",
          "interval": "",
          "intervalFactor": 5,
          "legendFormat": "switches",
          "refId": "A"
        },
        {
          "datasource": {
            "type": "prometheus",
            "uid": "PBFA97CFB590B2093"
          },
          "expr": "  (node_filefd_allocated{instance=~\"$node\"}/node_filefd_maximum{instance=~\"$node\"}) *100",
          "format": "time_series",
          "hide": true,
          "instant": false,
          "interval": "",
          "intervalFactor": 5,
          "legendFormat": "使用的文件描述符占比_{{instance}}",
          "refId": "C"
        }
      ],
      "thresholds": [],
      "timeRegions": [],
      "title": "Open  File Descriptor(left)/Context switches(right)",
      "tooltip": {
        "shared": true,
        "sort": 2,
        "value_type": "individual"
      },
      "type": "graph",
      "xaxis": {
        "mode": "time",
        "show": true,
        "values": []
      },
      "yaxes": [
        {
          "$$hashKey": "object:4219",
          "format": "short",
          "label": "used filefd",
          "logBase": 1,
          "show": true
        },
        {
          "$$hashKey": "object:4220",
          "format": "short",
          "label": "context_switches",
          "logBase": 1,
          "show": true
        }
      ],
      "yaxis": {
        "align": false
      }
    }
  ],
  "refresh": "",
  "schemaVersion": 39,
  "tags": [
    "Prometheus",
    "node_exporter",
    "StarsL.cn"
  ],
  "templating": {
    "list": [
      {
        "allValue": "",
        "current": {
          "isNone": true,
          "selected": false,
          "text": "None",
          "value": ""
        },
        "datasource": {
          "type": "prometheus",
          "uid": "PBFA97CFB590B2093"
        },
        "definition": "label_values(origin_prometheus)",
        "hide": 0,
        "includeAll": false,
        "label": "Origin_prom",
        "multi": false,
        "name": "origin_prometheus",
        "options": [],
        "query": "label_values(origin_prometheus)",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 5,
        "tagValuesQuery": "",
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      },
      {
        "current": {
          "selected": false,
          "text": "node_exporter",
          "value": "node_exporter"
        },
        "datasource": {
          "type": "prometheus",
          "uid": "PBFA97CFB590B2093"
        },
        "definition": "label_values(node_uname_info{origin_prometheus=~\"$origin_prometheus\"}, job)",
        "hide": 0,
        "includeAll": false,
        "label": "JOB",
        "multi": false,
        "name": "job",
        "options": [],
        "query": "label_values(node_uname_info{origin_prometheus=~\"$origin_prometheus\"}, job)",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 5,
        "tagValuesQuery": "",
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      },
      {
        "current": {
          "selected": false,
          "text": "All",
          "value": "$__all"
        },
        "datasource": {
          "type": "prometheus",
          "uid": "PBFA97CFB590B2093"
        },
        "definition": "label_values(node_uname_info{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"}, nodename)",
        "hide": 0,
        "includeAll": true,
        "label": "Host",
        "multi": false,
        "name": "hostname",
        "options": [],
        "query": "label_values(node_uname_info{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"}, nodename)",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 5,
        "tagValuesQuery": "",
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      },
      {
        "allFormat": "glob",
        "current": {
          "selected": false,
          "text": "node_exporter:9100",
          "value": "node_exporter:9100"
        },
        "datasource": {
          "type": "prometheus",
          "uid": "PBFA97CFB590B2093"
        },
        "definition": "label_values(node_uname_info{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",nodename=~\"$hostname\"},instance)",
        "hide": 0,
        "includeAll": false,
        "label": "Instance",
        "multi": true,
        "multiFormat": "regex values",
        "name": "node",
        "options": [],
        "query": "label_values(node_uname_info{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",nodename=~\"$hostname\"},instance)",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 5,
        "tagValuesQuery": "",
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      },
      {
        "allFormat": "glob",
        "current": {
          "selected": false,
          "text": "All",
          "value": "$__all"
        },
        "datasource": {
          "type": "prometheus",
          "uid": "PBFA97CFB590B2093"
        },
        "definition": "label_values(node_network_info{origin_prometheus=~\"$origin_prometheus\",device!~'tap.*|veth.*|br.*|docker.*|virbr.*|lo.*|cni.*'},device)",
        "hide": 0,
        "includeAll": true,
        "label": "NIC",
        "multi": true,
        "multiFormat": "regex values",
        "name": "device",
        "options": [],
        "query": "label_values(node_network_info{origin_prometheus=~\"$origin_prometheus\",device!~'tap.*|veth.*|br.*|docker.*|virbr.*|lo.*|cni.*'},device)",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 1,
        "tagValuesQuery": "",
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      },
      {
        "auto": false,
        "auto_count": 100,
        "auto_min": "10s",
        "current": {
          "selected": false,
          "text": "2m",
          "value": "2m"
        },
        "hide": 0,
        "label": "Interval",
        "name": "interval",
        "options": [
          {
            "selected": false,
            "text": "30s",
            "value": "30s"
          },
          {
            "selected": false,
            "text": "1m",
            "value": "1m"
          },
          {
            "selected": true,
            "text": "2m",
            "value": "2m"
          },
          {
            "selected": false,
            "text": "3m",
            "value": "3m"
          },
          {
            "selected": false,
            "text": "5m",
            "value": "5m"
          },
          {
            "selected": false,
            "text": "10m",
            "value": "10m"
          },
          {
            "selected": false,
            "text": "30m",
            "value": "30m"
          }
        ],
        "query": "30s,1m,2m,3m,5m,10m,30m",
        "queryValue": "",
        "refresh": 2,
        "skipUrlSync": false,
        "type": "interval"
      },
      {
        "current": {
          "selected": false,
          "text": "/",
          "value": "/"
        },
        "datasource": {
          "type": "prometheus",
          "uid": "PBFA97CFB590B2093"
        },
        "definition": "query_result(topk(1,sort_desc (max(node_filesystem_size_bytes{origin_prometheus=~\"$origin_prometheus\",instance=~'$node',fstype=~\"ext.?|xfs\",mountpoint!~\".*pods.*\"}) by (mountpoint))))",
        "hide": 2,
        "includeAll": false,
        "label": "maxmount",
        "multi": false,
        "name": "maxmount",
        "options": [],
        "query": "query_result(topk(1,sort_desc (max(node_filesystem_size_bytes{origin_prometheus=~\"$origin_prometheus\",instance=~'$node',fstype=~\"ext.?|xfs\",mountpoint!~\".*pods.*\"}) by (mountpoint))))",
        "refresh": 2,
        "regex": "/.*\\\"(.*)\\\".*/",
        "skipUrlSync": false,
        "sort": 5,
        "tagValuesQuery": "",
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      },
      {
        "current": {
          "selected": false,
          "text": "032a780e2675",
          "value": "032a780e2675"
        },
        "datasource": {
          "type": "prometheus",
          "uid": "PBFA97CFB590B2093"
        },
        "definition": "label_values(node_uname_info{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",instance=~\"$node\"}, nodename)",
        "hide": 2,
        "includeAll": false,
        "label": "show_hostname",
        "multi": false,
        "name": "show_hostname",
        "options": [],
        "query": "label_values(node_uname_info{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\",instance=~\"$node\"}, nodename)",
        "refresh": 1,
        "regex": "",
        "skipUrlSync": false,
        "sort": 5,
        "tagValuesQuery": "",
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      },
      {
        "current": {
          "selected": false,
          "text": "1",
          "value": "1"
        },
        "datasource": {
          "type": "prometheus",
          "uid": "PBFA97CFB590B2093"
        },
        "definition": "query_result(count(node_uname_info{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"}))",
        "hide": 2,
        "includeAll": false,
        "label": "total_servers",
        "multi": false,
        "name": "total",
        "options": [],
        "query": "query_result(count(node_uname_info{origin_prometheus=~\"$origin_prometheus\",job=~\"$job\"}))",
        "refresh": 1,
        "regex": "/{} (.*) .*/",
        "skipUrlSync": false,
        "sort": 0,
        "tagValuesQuery": "",
        "tagsQuery": "",
        "type": "query",
        "useTags": false
      }
    ]
  },
  "time": {
    "from": "now-12h",
    "to": "now"
  },
  "timeRangeUpdatedDuringEditOrView": false,
  "timepicker": {
    "hidden": false,
    "now": true,
    "refresh_intervals": [
      "15s",
      "30s",
      "1m",
      "5m",
      "15m",
      "30m"
    ],
    "time_options": [
      "5m",
      "15m",
      "1h",
      "6h",
      "12h",
      "24h",
      "2d",
      "7d",
      "30d"
    ]
  },
  "timezone": "browser",
  "title": "Node Exporter Dashboard EN",
  "uid": "xfpJB9FGz",
  "version": 2,
  "weekStart": ""
}
EOF

# JSON for loki dashboards
cat <<EOF > dashboards/log-dashboard.json
{
  "annotations": {
    "list": [
      {
        "builtIn": 1,
        "datasource": {
          "type": "grafana",
          "uid": "-- Grafana --"
        },
        "enable": true,
        "hide": true,
        "iconColor": "rgba(0, 211, 255, 1)",
        "name": "Annotations & Alerts",
        "type": "dashboard"
      }
    ]
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 0,
  "links": [],
  "liveNow": false,
  "panels": [
    {
      "datasource": {
        "type": "loki",
        "uid": "P8E80F9AEF21F6940"
      },
      "gridPos": {
        "h": 16,
        "w": 24,
        "x": 0,
        "y": 0
      },
      "id": 1,
      "options": {
        "dedupStrategy": "none",
        "enableLogDetails": true,
        "prettifyLogMessage": false,
        "showCommonLabels": false,
        "showLabels": false,
        "showTime": false,
        "sortOrder": "Descending",
        "wrapLogMessage": false
      },
      "pluginVersion": "7.5.7",
      "targets": [
        {
          "datasource": {
            "type": "loki",
            "uid": "P8E80F9AEF21F6940"
          },
          "expr": "{job=\"varlogs\"}",
          "refId": "A"
        }
      ],
      "title": "Logs",
      "type": "logs"
    }
  ],
  "refresh": "5s",
  "schemaVersion": 39,
  "tags": [],
  "templating": {
    "list": []
  },
  "time": {
    "from": "now-1h",
    "to": "now"
  },
  "timeRangeUpdatedDuringEditOrView": false,
  "timepicker": {},
  "timezone": "",
  "title": "Log Dashboard",
  "uid": "log-dashboard",
  "version": 1,
  "weekStart": ""
}
EOF

# chmod +x setup_grafana_datasources.sh

# cat <<EOF > Dockerfile.grafana
# FROM grafana/grafana:10.3.7-ubuntu
# USER root
# RUN apt-get update && apt-get install curl
# USER grafana
# COPY . .
# EOF

# Створення docker-compose.yml
cat <<EOF > docker-compose.yml
version: '3.8'

services:
  grafana:
    image: grafana/grafana:10.3.7-ubuntu
#    build:
#      context: .
#      dockerfile: Dockerfile.grafana
    container_name: grafana
    volumes:
      - grafana-data:/var/lib/grafana
      - ./datasources.yml:/etc/grafana/provisioning/datasources/datasources.yaml
      - ./dashboards:/var/lib/grafana/dashboards
      - ./dashboard-config.yml:/etc/grafana/provisioning/dashboards/dashboard-config.yaml
    env_file:
      - .env
    ports:
      - "${GF_SERVER_HTTP_PORT}:3000"
    depends_on:
      - alertmanager
    # entrypoint: ["/bin/sh", "-c", "/setup_grafana_datasources.sh"]
    networks:
      - monitor_network

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    ports:
      - "${ALERTMANAGER_PORT}:9093"
    volumes:
      - ./alertmanager.yml:/etc/alertmanager/alertmanager.yml
    env_file:
      - .env
    networks:
      - monitor_network

volumes:
  grafana-data:

networks:
  monitor_network:
    driver: bridge
EOF

# Запуск docker-compose
docker-compose up --build -d
