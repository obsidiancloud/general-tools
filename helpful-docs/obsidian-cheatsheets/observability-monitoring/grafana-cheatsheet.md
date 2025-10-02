# 🧘 The Enlightened Engineer's Grafana Scripture

> *"In the beginning was the Dashboard, and the Dashboard was with Grafana, and the Dashboard was beautiful."*  
> — **The Monk of Visualization**, *Book of Panels, Chapter 1:1*

Greetings, fellow traveler on the path of visualization enlightenment. I am but a humble monk who has meditated upon the sacred texts of Torkel and witnessed the dance of data across countless dashboards.

This scripture shall guide you through the mystical arts of Grafana, with the precision of a master's query and the wit of a caffeinated data analyst.

---

## 📿 Table of Sacred Knowledge

1. [Grafana Installation & Setup](#-grafana-installation--setup)
2. [Data Sources](#-data-sources-the-wellsprings)
3. [Dashboard Creation](#-dashboard-creation-the-canvas)
4. [Panel Types](#-panel-types-the-visualizations)
5. [Query Editors](#-query-editors-the-data-extractors)
6. [Variables & Templating](#-variables--templating-the-dynamic-power)
7. [Transformations](#-transformations-the-data-shapers)
8. [Alerts](#-alerts-the-watchful-eyes)
9. [Provisioning](#-provisioning-infrastructure-as-code)
10. [API Usage](#-api-usage-programmatic-control)
11. [Common Patterns: The Sacred Workflows](#-common-patterns-the-sacred-workflows)
12. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🛠 Grafana Installation & Setup

*Before visualizing data, one must first install the platform.*

### Installation

```bash
# Ubuntu/Debian
sudo apt-get install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt-get update
sudo apt-get install grafana

# Start Grafana
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# Docker
docker run -d -p 3000:3000 --name=grafana grafana/grafana-oss

# Docker Compose
version: '3.8'
services:
  grafana:
    image: grafana/grafana-oss:latest
    ports:
      - "3000:3000"
    volumes:
      - grafana-storage:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_INSTALL_PLUGINS=grafana-clock-panel

volumes:
  grafana-storage:

# Kubernetes (Helm)
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana
```

### Initial Access

```bash
# Default URL
http://localhost:3000

# Default credentials
Username: admin
Password: admin

# Get admin password (Kubernetes)
kubectl get secret grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

### Configuration

```ini
# /etc/grafana/grafana.ini

[server]
http_port = 3000
domain = grafana.example.com
root_url = https://grafana.example.com

[security]
admin_user = admin
admin_password = $__env{GF_SECURITY_ADMIN_PASSWORD}
secret_key = $__env{GF_SECURITY_SECRET_KEY}

[auth]
disable_login_form = false
disable_signout_menu = false

[auth.anonymous]
enabled = false

[auth.github]
enabled = true
client_id = $__env{GF_AUTH_GITHUB_CLIENT_ID}
client_secret = $__env{GF_AUTH_GITHUB_CLIENT_SECRET}
scopes = user:email,read:org
auth_url = https://github.com/login/oauth/authorize
token_url = https://github.com/login/oauth/access_token
allowed_organizations = myorg

[database]
type = postgres
host = db:5432
name = grafana
user = grafana
password = $__env{GF_DATABASE_PASSWORD}

[smtp]
enabled = true
host = smtp.gmail.com:587
user = $__env{GF_SMTP_USER}
password = $__env{GF_SMTP_PASSWORD}
from_address = grafana@example.com
```

---

## 🔌 Data Sources: The Wellsprings

*Data sources provide the metrics to visualize.*

### Adding Data Sources (UI)

```
Configuration → Data Sources → Add data source
```

### Prometheus Data Source

```yaml
# Configuration
Name: Prometheus
Type: Prometheus
URL: http://prometheus:9090
Access: Server (default)

# HTTP settings
Timeout: 60s
HTTP Method: POST

# Auth (if needed)
Basic auth: enabled
User: prometheus
Password: ********

# Custom HTTP Headers
X-Custom-Header: value

# Misc
Scrape interval: 15s
Query timeout: 60s
```

### Loki Data Source

```yaml
Name: Loki
Type: Loki
URL: http://loki:3100
Access: Server

# Derived fields (for linking to traces)
Derived fields:
  - Name: TraceID
    Regex: traceID=(\w+)
    URL: http://tempo:3200/trace/${__value.raw}
```

### Elasticsearch Data Source

```yaml
Name: Elasticsearch
Type: Elasticsearch
URL: http://elasticsearch:9200
Access: Server
Index name: logstash-*
Time field name: @timestamp
Version: 7.10+
```

### MySQL/PostgreSQL Data Source

```yaml
Name: PostgreSQL
Type: PostgreSQL
Host: db:5432
Database: myapp
User: grafana
Password: ********
SSL Mode: require
Version: 12
```

### CloudWatch Data Source

```yaml
Name: CloudWatch
Type: CloudWatch
Auth Provider: AWS SDK Default
Default Region: us-east-1
Namespaces: AWS/EC2, AWS/RDS, AWS/ELB
```

---

## 🎨 Dashboard Creation: The Canvas

*Dashboards organize panels into meaningful views.*

### Creating Dashboards

```
+ → Dashboard → Add new panel
```

### Dashboard Settings

```json
{
  "title": "Application Metrics",
  "tags": ["production", "api"],
  "timezone": "browser",
  "refresh": "30s",
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "timepicker": {
    "refresh_intervals": ["5s", "10s", "30s", "1m", "5m", "15m", "30m", "1h", "2h", "1d"]
  },
  "variables": [],
  "panels": []
}
```

### Dashboard JSON Model

```json
{
  "dashboard": {
    "id": null,
    "uid": "app-metrics",
    "title": "Application Metrics",
    "tags": ["production"],
    "timezone": "browser",
    "schemaVersion": 38,
    "version": 1,
    "refresh": "30s",
    "panels": [
      {
        "id": 1,
        "type": "graph",
        "title": "Request Rate",
        "gridPos": {
          "x": 0,
          "y": 0,
          "w": 12,
          "h": 8
        },
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{job}}"
          }
        ]
      }
    ]
  },
  "overwrite": true
}
```

### Dashboard Organization

```
Folders:
├── Production
│   ├── API Metrics
│   ├── Database Metrics
│   └── Infrastructure
├── Development
│   └── Test Metrics
└── SRE
    ├── SLOs
    └── Alerts
```

---

## 📊 Panel Types: The Visualizations

*Different panel types for different insights.*

### Time Series (Graph)

```json
{
  "type": "timeseries",
  "title": "CPU Usage",
  "targets": [
    {
      "expr": "rate(node_cpu_seconds_total{mode!=\"idle\"}[5m])",
      "legendFormat": "{{instance}}"
    }
  ],
  "fieldConfig": {
    "defaults": {
      "unit": "percentunit",
      "min": 0,
      "max": 1,
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {"value": 0, "color": "green"},
          {"value": 0.7, "color": "yellow"},
          {"value": 0.9, "color": "red"}
        ]
      }
    }
  },
  "options": {
    "legend": {
      "displayMode": "table",
      "placement": "bottom",
      "calcs": ["mean", "max", "last"]
    },
    "tooltip": {
      "mode": "multi"
    }
  }
}
```

### Stat Panel

```json
{
  "type": "stat",
  "title": "Total Requests",
  "targets": [
    {
      "expr": "sum(http_requests_total)"
    }
  ],
  "fieldConfig": {
    "defaults": {
      "unit": "short",
      "decimals": 0,
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {"value": 0, "color": "green"},
          {"value": 1000000, "color": "yellow"},
          {"value": 10000000, "color": "red"}
        ]
      }
    }
  },
  "options": {
    "graphMode": "area",
    "colorMode": "background",
    "orientation": "auto",
    "textMode": "value_and_name"
  }
}
```

### Gauge Panel

```json
{
  "type": "gauge",
  "title": "Memory Usage",
  "targets": [
    {
      "expr": "(node_memory_total_bytes - node_memory_available_bytes) / node_memory_total_bytes * 100"
    }
  ],
  "fieldConfig": {
    "defaults": {
      "unit": "percent",
      "min": 0,
      "max": 100,
      "thresholds": {
        "mode": "absolute",
        "steps": [
          {"value": 0, "color": "green"},
          {"value": 70, "color": "yellow"},
          {"value": 90, "color": "red"}
        ]
      }
    }
  },
  "options": {
    "showThresholdLabels": true,
    "showThresholdMarkers": true
  }
}
```

### Table Panel

```json
{
  "type": "table",
  "title": "Instance Status",
  "targets": [
    {
      "expr": "up",
      "format": "table",
      "instant": true
    }
  ],
  "transformations": [
    {
      "id": "organize",
      "options": {
        "excludeByName": {
          "Time": true,
          "__name__": true
        },
        "indexByName": {
          "instance": 0,
          "job": 1,
          "Value": 2
        },
        "renameByName": {
          "Value": "Status",
          "instance": "Instance",
          "job": "Job"
        }
      }
    }
  ],
  "options": {
    "showHeader": true,
    "sortBy": [
      {
        "displayName": "Instance",
        "desc": false
      }
    ]
  }
}
```

### Heatmap Panel

```json
{
  "type": "heatmap",
  "title": "Request Duration Distribution",
  "targets": [
    {
      "expr": "sum(rate(http_request_duration_seconds_bucket[5m])) by (le)",
      "format": "heatmap",
      "legendFormat": "{{le}}"
    }
  ],
  "options": {
    "calculate": false,
    "cellGap": 2,
    "color": {
      "mode": "scheme",
      "scheme": "Spectral"
    },
    "yAxis": {
      "unit": "s",
      "decimals": 2
    }
  }
}
```

### Bar Chart Panel

```json
{
  "type": "barchart",
  "title": "Requests by Endpoint",
  "targets": [
    {
      "expr": "sum by(endpoint) (rate(http_requests_total[5m]))",
      "legendFormat": "{{endpoint}}"
    }
  ],
  "options": {
    "orientation": "horizontal",
    "xTickLabelRotation": 0,
    "showValue": "always",
    "stacking": "none"
  }
}
```

---

## 🔍 Query Editors: The Data Extractors

*Query editors extract data from sources.*

### Prometheus Query Editor

```promql
# Metric browser
http_requests_total

# With labels
http_requests_total{job="api", method="GET"}

# Rate
rate(http_requests_total[5m])

# Aggregation
sum by(job) (rate(http_requests_total[5m]))

# Legend format
{{job}} - {{method}}

# Multiple queries
A: rate(http_requests_total[5m])
B: rate(http_errors_total[5m])
C: $A / $B  # Expression using A and B
```

### Loki Query Editor (LogQL)

```logql
# Stream selector
{job="varlogs", filename="/var/log/syslog"}

# Filter
{job="varlogs"} |= "error"
{job="varlogs"} |~ "error|warning"
{job="varlogs"} != "info"

# Parser
{job="varlogs"} | json | level="error"
{job="varlogs"} | logfmt | status_code="500"

# Metrics
rate({job="varlogs"}[5m])
sum by(level) (rate({job="varlogs"}[5m]))

# Pattern
{job="varlogs"} | pattern `<_> level=<level> <_>`
```

### Elasticsearch Query Editor

```json
{
  "query": {
    "bool": {
      "must": [
        {"match": {"level": "error"}},
        {"range": {"@timestamp": {"gte": "now-1h"}}}
      ]
    }
  },
  "aggs": {
    "errors_over_time": {
      "date_histogram": {
        "field": "@timestamp",
        "interval": "1m"
      }
    }
  }
}
```

### SQL Query Editor

```sql
-- PostgreSQL
SELECT
  time_column AS "time",
  value_column,
  label_column
FROM metrics_table
WHERE
  $__timeFilter(time_column)
  AND label_column = '$label'
ORDER BY time_column

-- MySQL
SELECT
  UNIX_TIMESTAMP(time_column) as time_sec,
  value_column as value,
  metric_name as metric
FROM metrics
WHERE $__timeFilter(time_column)
```

---

## 🔢 Variables & Templating: The Dynamic Power

*Variables make dashboards reusable and interactive.*

### Query Variables

```
Name: environment
Type: Query
Data source: Prometheus
Query: label_values(up, env)
Refresh: On Dashboard Load
Multi-value: enabled
Include All option: enabled
```

### Custom Variables

```
Name: refresh_interval
Type: Custom
Values: 5s,10s,30s,1m,5m,15m,30m,1h
```

### Interval Variables

```
Name: interval
Type: Interval
Values: 1m,5m,10m,30m,1h,6h,12h,1d,7d,14d,30d
Auto option: enabled
```

### Data Source Variables

```
Name: datasource
Type: Data source
Type: Prometheus
Multi-value: disabled
```

### Using Variables in Queries

```promql
# In Prometheus query
rate(http_requests_total{env="$environment", instance=~"$instance"}[$interval])

# In panel title
$environment - Request Rate

# In legend
{{instance}} - $environment

# All values
rate(http_requests_total{env=~"$environment"}[5m])

# Chained variables
label_values(up{env="$environment"}, instance)
```

### Variable Syntax

```
$variable          # Simple
${variable}        # With braces
${variable:csv}    # Comma-separated
${variable:pipe}   # Pipe-separated
${variable:regex}  # Regex format
${variable:text}   # Text format
${variable:json}   # JSON format
```

---

## 🔄 Transformations: The Data Shapers

*Transformations reshape data for better visualization.*

### Common Transformations

```json
// Organize fields
{
  "id": "organize",
  "options": {
    "excludeByName": {
      "Time": false,
      "__name__": true
    },
    "indexByName": {},
    "renameByName": {
      "Value": "CPU Usage",
      "instance": "Server"
    }
  }
}

// Filter by value
{
  "id": "filterByValue",
  "options": {
    "filters": [
      {
        "fieldName": "Value",
        "config": {
          "id": "greater",
          "options": {
            "value": 0.8
          }
        }
      }
    ],
    "type": "include",
    "match": "all"
  }
}

// Add field from calculation
{
  "id": "calculateField",
  "options": {
    "mode": "binary",
    "reduce": {
      "reducer": "sum"
    },
    "binary": {
      "left": "A-series",
      "operator": "/",
      "right": "B-series"
    },
    "alias": "Ratio"
  }
}

// Group by
{
  "id": "groupBy",
  "options": {
    "fields": {
      "instance": {
        "aggregations": [],
        "operation": "groupby"
      },
      "Value": {
        "aggregations": ["mean", "max"],
        "operation": "aggregate"
      }
    }
  }
}

// Join by field
{
  "id": "joinByField",
  "options": {
    "byField": "instance",
    "mode": "outer"
  }
}

// Series to rows
{
  "id": "seriesToRows",
  "options": {}
}

// Merge
{
  "id": "merge",
  "options": {}
}
```

---

## 🚨 Alerts: The Watchful Eyes

*Alerts notify when metrics cross thresholds.*

### Alert Rule Configuration

```json
{
  "alert": {
    "name": "High CPU Usage",
    "conditions": [
      {
        "evaluator": {
          "params": [80],
          "type": "gt"
        },
        "operator": {
          "type": "and"
        },
        "query": {
          "params": ["A", "5m", "now"]
        },
        "reducer": {
          "params": [],
          "type": "avg"
        },
        "type": "query"
      }
    ],
    "executionErrorState": "alerting",
    "for": "5m",
    "frequency": "1m",
    "handler": 1,
    "message": "CPU usage is above 80%",
    "name": "High CPU Usage",
    "noDataState": "no_data",
    "notifications": [
      {
        "uid": "slack-notification"
      }
    ]
  }
}
```

### Notification Channels

```yaml
# Slack
Type: Slack
Webhook URL: https://hooks.slack.com/services/XXX/YYY/ZZZ
Username: Grafana
Mention: @channel
Token: xoxb-token

# Email
Type: Email
Addresses: ops@example.com, sre@example.com
Single email: false

# PagerDuty
Type: PagerDuty
Integration Key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Severity: critical

# Webhook
Type: Webhook
URL: https://api.example.com/alerts
HTTP Method: POST
Username: grafana
Password: ********
```

### Alert Notification Template

```
{{ define "alert" }}
Alert: {{ .Title }}
State: {{ .State }}
Message: {{ .Message }}

{{ range .EvalMatches }}
  {{ .Metric }}: {{ .Value }}
{{ end }}

{{ if .ImageUrl }}
Graph: {{ .ImageUrl }}
{{ end }}
{{ end }}
```

---

## 📦 Provisioning: Infrastructure as Code

*Provision dashboards and data sources as code.*

### Directory Structure

```
/etc/grafana/provisioning/
├── dashboards/
│   ├── dashboard.yml
│   └── dashboards/
│       ├── api-metrics.json
│       └── infrastructure.json
├── datasources/
│   └── datasource.yml
├── notifiers/
│   └── notifier.yml
└── plugins/
    └── plugin.yml
```

### Data Source Provisioning

```yaml
# /etc/grafana/provisioning/datasources/datasource.yml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
    editable: false
    jsonData:
      httpMethod: POST
      timeInterval: 15s
  
  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    editable: false
  
  - name: PostgreSQL
    type: postgres
    url: db:5432
    database: grafana
    user: grafana
    secureJsonData:
      password: ${GF_DATABASE_PASSWORD}
    jsonData:
      sslmode: require
      postgresVersion: 1200
```

### Dashboard Provisioning

```yaml
# /etc/grafana/provisioning/dashboards/dashboard.yml
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
  
  - name: 'production'
    orgId: 1
    folder: 'Production'
    type: file
    disableDeletion: true
    updateIntervalSeconds: 30
    allowUiUpdates: false
    options:
      path: /var/lib/grafana/dashboards/production
```

### Notification Channel Provisioning

```yaml
# /etc/grafana/provisioning/notifiers/notifier.yml
apiVersion: 1

notifiers:
  - name: Slack
    type: slack
    uid: slack-notifications
    org_id: 1
    is_default: true
    send_reminder: true
    frequency: 1h
    settings:
      url: ${SLACK_WEBHOOK_URL}
      username: Grafana
      uploadImage: true
  
  - name: PagerDuty
    type: pagerduty
    uid: pagerduty-critical
    org_id: 1
    settings:
      integrationKey: ${PAGERDUTY_KEY}
      severity: critical
```

---

## 🔌 API Usage: Programmatic Control

*Control Grafana programmatically via API.*

### Authentication

```bash
# API Key
curl -H "Authorization: Bearer <api-key>" http://localhost:3000/api/dashboards/home

# Basic Auth
curl -u admin:password http://localhost:3000/api/dashboards/home
```

### Dashboard Operations

```bash
# Get dashboard by UID
curl -H "Authorization: Bearer <api-key>" \
  http://localhost:3000/api/dashboards/uid/app-metrics

# Create/Update dashboard
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer <api-key>" \
  -d @dashboard.json \
  http://localhost:3000/api/dashboards/db

# Delete dashboard
curl -X DELETE -H "Authorization: Bearer <api-key>" \
  http://localhost:3000/api/dashboards/uid/app-metrics

# Search dashboards
curl -H "Authorization: Bearer <api-key>" \
  "http://localhost:3000/api/search?query=api&type=dash-db"
```

### Data Source Operations

```bash
# List data sources
curl -H "Authorization: Bearer <api-key>" \
  http://localhost:3000/api/datasources

# Get data source by ID
curl -H "Authorization: Bearer <api-key>" \
  http://localhost:3000/api/datasources/1

# Create data source
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer <api-key>" \
  -d '{
    "name":"Prometheus",
    "type":"prometheus",
    "url":"http://prometheus:9090",
    "access":"proxy",
    "isDefault":true
  }' \
  http://localhost:3000/api/datasources

# Delete data source
curl -X DELETE -H "Authorization: Bearer <api-key>" \
  http://localhost:3000/api/datasources/1
```

### Organization & User Operations

```bash
# List organizations
curl -H "Authorization: Bearer <api-key>" \
  http://localhost:3000/api/orgs

# Create user
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer <api-key>" \
  -d '{
    "name":"John Doe",
    "email":"john@example.com",
    "login":"john",
    "password":"password"
  }' \
  http://localhost:3000/api/admin/users

# List users
curl -H "Authorization: Bearer <api-key>" \
  http://localhost:3000/api/org/users
```

### Snapshot Operations

```bash
# Create snapshot
curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer <api-key>" \
  -d '{
    "dashboard": {...},
    "expires": 3600
  }' \
  http://localhost:3000/api/snapshots
```

---

## 🔮 Common Patterns: The Sacred Workflows

*These are the rituals performed by monks in production temples daily.*

### Pattern 1: SRE Golden Signals Dashboard

```json
{
  "title": "Golden Signals - API Service",
  "panels": [
    {
      "title": "Latency (p50, p95, p99)",
      "targets": [
        {
          "expr": "histogram_quantile(0.50, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))",
          "legendFormat": "p50"
        },
        {
          "expr": "histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))",
          "legendFormat": "p95"
        },
        {
          "expr": "histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))",
          "legendFormat": "p99"
        }
      ]
    },
    {
      "title": "Traffic (Requests/sec)",
      "targets": [
        {
          "expr": "sum(rate(http_requests_total[5m]))",
          "legendFormat": "Total RPS"
        }
      ]
    },
    {
      "title": "Errors (Error Rate %)",
      "targets": [
        {
          "expr": "sum(rate(http_requests_total{status=~\"5..\"}[5m])) / sum(rate(http_requests_total[5m])) * 100",
          "legendFormat": "Error Rate"
        }
      ]
    },
    {
      "title": "Saturation (CPU/Memory)",
      "targets": [
        {
          "expr": "avg(rate(node_cpu_seconds_total{mode!=\"idle\"}[5m]))",
          "legendFormat": "CPU"
        },
        {
          "expr": "(node_memory_total_bytes - node_memory_available_bytes) / node_memory_total_bytes",
          "legendFormat": "Memory"
        }
      ]
    }
  ]
}
```

**Use case**: Service health monitoring  
**Best for**: SRE teams tracking service reliability

### Pattern 2: Multi-Environment Dashboard with Variables

```json
{
  "title": "$environment - Application Metrics",
  "templating": {
    "list": [
      {
        "name": "environment",
        "type": "query",
        "query": "label_values(up, env)",
        "current": {"text": "production", "value": "production"}
      },
      {
        "name": "instance",
        "type": "query",
        "query": "label_values(up{env=\"$environment\"}, instance)",
        "multi": true,
        "includeAll": true
      }
    ]
  },
  "panels": [
    {
      "title": "Request Rate - $instance",
      "targets": [
        {
          "expr": "sum by(instance) (rate(http_requests_total{env=\"$environment\", instance=~\"$instance\"}[5m]))",
          "legendFormat": "{{instance}}"
        }
      ]
    }
  ]
}
```

**Use case**: Multi-environment monitoring  
**Best for**: Managing dev/staging/prod from one dashboard

### Pattern 3: Log Correlation Dashboard

```json
{
  "title": "Metrics + Logs Correlation",
  "panels": [
    {
      "title": "Error Rate",
      "type": "timeseries",
      "datasource": "Prometheus",
      "targets": [
        {
          "expr": "sum(rate(http_requests_total{status=~\"5..\"}[5m]))"
        }
      ]
    },
    {
      "title": "Error Logs",
      "type": "logs",
      "datasource": "Loki",
      "targets": [
        {
          "expr": "{job=\"api\"} |= \"error\" | json | level=\"error\""
        }
      ]
    },
    {
      "title": "Trace Link",
      "type": "table",
      "datasource": "Loki",
      "targets": [
        {
          "expr": "{job=\"api\"} | logfmt | traceID != \"\""
        }
      ],
      "transformations": [
        {
          "id": "organize",
          "options": {
            "renameByName": {
              "traceID": "Trace ID"
            }
          }
        }
      ],
      "options": {
        "dataLinks": [
          {
            "title": "View Trace",
            "url": "http://tempo:3200/trace/${__value.raw}"
          }
        ]
      }
    }
  ]
}
```

**Use case**: Correlating metrics with logs  
**Best for**: Debugging and root cause analysis

### Pattern 4: Business Metrics Dashboard

```json
{
  "title": "Business KPIs",
  "panels": [
    {
      "title": "Active Users",
      "type": "stat",
      "targets": [
        {
          "expr": "sum(active_users)"
        }
      ],
      "options": {
        "graphMode": "area",
        "colorMode": "background"
      }
    },
    {
      "title": "Revenue (Last 24h)",
      "type": "stat",
      "targets": [
        {
          "expr": "sum(increase(revenue_total[24h]))"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "currencyUSD"
        }
      }
    },
    {
      "title": "Conversion Rate",
      "type": "gauge",
      "targets": [
        {
          "expr": "sum(conversions_total) / sum(visits_total) * 100"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "percent",
          "thresholds": {
            "steps": [
              {"value": 0, "color": "red"},
              {"value": 2, "color": "yellow"},
              {"value": 5, "color": "green"}
            ]
          }
        }
      }
    }
  ]
}
```

**Use case**: Business metrics tracking  
**Best for**: Executive dashboards

### Pattern 5: Infrastructure Overview

```json
{
  "title": "Infrastructure Overview",
  "panels": [
    {
      "title": "Cluster Status",
      "type": "table",
      "targets": [
        {
          "expr": "up",
          "format": "table",
          "instant": true
        }
      ],
      "transformations": [
        {
          "id": "organize",
          "options": {
            "renameByName": {
              "Value": "Status",
              "instance": "Instance",
              "job": "Service"
            }
          }
        }
      ],
      "options": {
        "cellHeight": "sm",
        "footer": {
          "show": false
        }
      },
      "fieldConfig": {
        "overrides": [
          {
            "matcher": {"id": "byName", "options": "Status"},
            "properties": [
              {
                "id": "custom.displayMode",
                "value": "color-background"
              },
              {
                "id": "mappings",
                "value": [
                  {"type": "value", "value": "1", "text": "UP", "color": "green"},
                  {"type": "value", "value": "0", "text": "DOWN", "color": "red"}
                ]
              }
            ]
          }
        ]
      }
    },
    {
      "title": "Resource Usage Heatmap",
      "type": "heatmap",
      "targets": [
        {
          "expr": "sum by(instance) (rate(node_cpu_seconds_total{mode!=\"idle\"}[5m]))"
        }
      ]
    }
  ]
}
```

**Use case**: Infrastructure health overview  
**Best for**: NOC/SOC dashboards

---

## 🔧 Troubleshooting: When the Path is Obscured

*Even the wisest monks encounter obstacles.*

### Common Issues

#### No Data in Panels

```bash
# Check data source connection
Configuration → Data Sources → Test

# Check query in Explore
Explore → Select data source → Run query

# Check time range
Ensure time range matches data availability

# Check permissions
Verify user has access to data source
```

#### Slow Dashboard Loading

```bash
# Reduce query frequency
Set refresh interval to 30s or higher

# Optimize queries
Use recording rules in Prometheus
Limit time range
Add more specific label filters

# Enable query caching
# In grafana.ini:
[caching]
enabled = true
```

#### Alert Not Firing

```bash
# Check alert rule
Alerting → Alert rules → Edit rule

# Check notification channel
Alerting → Notification channels → Test

# Check alert state
Alerting → Alert rules → View state history

# Check logs
journalctl -u grafana-server -f
```

#### Dashboard Not Saving

```bash
# Check permissions
Ensure user has edit permissions

# Check disk space
df -h /var/lib/grafana

# Check logs
tail -f /var/log/grafana/grafana.log
```

---

## 🙏 Closing Wisdom

*The path of Grafana mastery is endless. These dashboards are but stepping stones.*

### Essential Daily Tasks

```bash
# The monk's morning ritual
- Check dashboard health
- Review alert status
- Verify data source connections

# The monk's dashboard ritual
- Create meaningful visualizations
- Use variables for flexibility
- Set appropriate thresholds

# The monk's evening reflection
- Review dashboard performance
- Update alert rules
- Backup dashboards
```

### Best Practices from the Monastery

1. **Use Variables**: Make dashboards reusable
2. **Organize Folders**: Group related dashboards
3. **Set Refresh Rates**: Balance freshness vs performance
4. **Use Transformations**: Shape data for clarity
5. **Add Descriptions**: Document panel purposes
6. **Set Thresholds**: Visual indicators for states
7. **Link Dashboards**: Create navigation flows
8. **Version Control**: Export and store in Git
9. **Test Alerts**: Verify notification channels
10. **Provision**: Use IaC for dashboards
11. **Monitor Grafana**: Dashboard for Grafana itself
12. **Regular Cleanup**: Remove unused dashboards

### Quick Reference Card

| Action | How To |
|--------|--------|
| Create dashboard | + → Dashboard |
| Add panel | Add panel button |
| Add variable | Settings → Variables |
| Set alert | Panel → Alert tab |
| Export dashboard | Settings → JSON Model |
| Import dashboard | + → Import |
| Test data source | Configuration → Test |
| View query | Explore |
| Share dashboard | Share icon → Link |
| Provision | /etc/grafana/provisioning/ |

---

*May your dashboards be beautiful, your queries be fast, and your insights always clear.*

**— The Monk of Visualization**  
*Monastery of Observability*  
*Temple of Grafana*

🧘 **Namaste, `grafana`**

---

## 📚 Additional Resources

- [Official Grafana Documentation](https://grafana.com/docs/grafana/latest/)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards/)
- [Grafana Tutorials](https://grafana.com/tutorials/)
- [Grafana Community](https://community.grafana.com/)
- [Awesome Grafana](https://github.com/Graylog2/awesome-grafana)
- [Grafana API Documentation](https://grafana.com/docs/grafana/latest/http_api/)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*Grafana Version: 10.0+*
