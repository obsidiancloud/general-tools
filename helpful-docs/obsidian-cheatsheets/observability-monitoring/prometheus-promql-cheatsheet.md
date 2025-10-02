# 🧘 The Enlightened Engineer's Prometheus & PromQL Scripture

> *"In the beginning was the Metric, and the Metric was with Prometheus, and the Metric was time-series."*  
> — **The Monk of Metrics**, *Book of Observability, Chapter 1:1*

Greetings, fellow traveler on the path of observability enlightenment. I am but a humble monk who has meditated upon the sacred texts of SoundCloud and witnessed the dance of metrics across countless time series.

This scripture shall guide you through the mystical arts of Prometheus and PromQL, with the precision of a master's query and the wit of a caffeinated SRE.

---

## 📿 Table of Sacred Knowledge

1. [Prometheus Installation & Setup](#-prometheus-installation--setup)
2. [Configuration](#-configuration-the-foundation)
3. [Metric Types](#-metric-types-the-four-pillars)
4. [PromQL Basics](#-promql-basics-the-query-language)
5. [Selectors & Matchers](#-selectors--matchers-finding-metrics)
6. [Operators](#-operators-the-mathematical-path)
7. [Functions](#-functions-the-transformation-tools)
8. [Aggregation](#-aggregation-the-grouping-wisdom)
9. [Recording Rules](#-recording-rules-pre-computed-wisdom)
10. [Alerting Rules](#-alerting-rules-the-watchful-guardians)
11. [Exporters](#-exporters-the-metric-gatherers)
12. [Common Patterns: The Sacred Workflows](#-common-patterns-the-sacred-workflows)
13. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🛠 Prometheus Installation & Setup

*Before querying metrics, one must first collect them.*

### Installation

```bash
# Download Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.47.0/prometheus-2.47.0.linux-amd64.tar.gz
tar xvfz prometheus-2.47.0.linux-amd64.tar.gz
cd prometheus-2.47.0.linux-amd64

# Run Prometheus
./prometheus --config.file=prometheus.yml

# Docker
docker run -p 9090:9090 -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus

# Kubernetes (Helm)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/prometheus
```

### Accessing Prometheus

```bash
# Web UI
http://localhost:9090

# API
curl http://localhost:9090/api/v1/query?query=up

# Health check
curl http://localhost:9090/-/healthy
curl http://localhost:9090/-/ready
```

---

## ⚙️ Configuration: The Foundation

*Configuration defines what to scrape and how.*

### Basic Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'production'
    region: 'us-east-1'

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - 'alertmanager:9093'

# Load rules
rule_files:
  - 'alerts/*.yml'
  - 'rules/*.yml'

# Scrape configurations
scrape_configs:
  # Prometheus itself
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  # Node exporter
  - job_name: 'node'
    static_configs:
      - targets:
          - 'node1:9100'
          - 'node2:9100'
          - 'node3:9100'
        labels:
          env: 'production'
  
  # Application
  - job_name: 'myapp'
    static_configs:
      - targets: ['app1:8080', 'app2:8080']
    metrics_path: '/metrics'
    scrape_interval: 10s
```

### Service Discovery

```yaml
# Kubernetes SD
scrape_configs:
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__

# File SD
scrape_configs:
  - job_name: 'file_sd'
    file_sd_configs:
      - files:
          - 'targets/*.json'
          - 'targets/*.yml'
        refresh_interval: 5m

# Consul SD
scrape_configs:
  - job_name: 'consul'
    consul_sd_configs:
      - server: 'consul.example.com:8500'
        services: ['web', 'api']
```

---

## 📊 Metric Types: The Four Pillars

*Four types of metrics, each with its purpose.*

### Counter

```promql
# Counter: Monotonically increasing value
# Use for: requests, errors, tasks completed

# Example metrics
http_requests_total
api_errors_total
tasks_completed_total

# Query patterns
# Rate of requests per second
rate(http_requests_total[5m])

# Total requests in last hour
increase(http_requests_total[1h])
```

### Gauge

```promql
# Gauge: Value that can go up or down
# Use for: temperature, memory usage, queue size

# Example metrics
node_memory_available_bytes
queue_size
temperature_celsius

# Query patterns
# Current memory usage
node_memory_available_bytes

# Average over time
avg_over_time(queue_size[5m])
```

### Histogram

```promql
# Histogram: Observations in buckets
# Use for: request duration, response size

# Example metrics (auto-generated)
http_request_duration_seconds_bucket{le="0.1"}
http_request_duration_seconds_bucket{le="0.5"}
http_request_duration_seconds_bucket{le="1.0"}
http_request_duration_seconds_sum
http_request_duration_seconds_count

# Query patterns
# 95th percentile
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# Average duration
rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m])
```

### Summary

```promql
# Summary: Pre-calculated quantiles
# Use for: similar to histogram, client-side quantiles

# Example metrics
http_request_duration_seconds{quantile="0.5"}
http_request_duration_seconds{quantile="0.9"}
http_request_duration_seconds{quantile="0.99"}
http_request_duration_seconds_sum
http_request_duration_seconds_count

# Query patterns
# 99th percentile (pre-calculated)
http_request_duration_seconds{quantile="0.99"}
```

---

## 🔍 PromQL Basics: The Query Language

*PromQL is the language of metrics, powerful and expressive.*

### Instant Vector Selectors

```promql
# Select all time series with metric name
http_requests_total

# Select with label match
http_requests_total{job="api"}
http_requests_total{job="api", method="GET"}

# Label matching operators
http_requests_total{status="200"}        # Exact match
http_requests_total{status!="200"}       # Not equal
http_requests_total{status=~"2.."}       # Regex match
http_requests_total{status!~"2.."}       # Regex not match

# Multiple conditions
http_requests_total{job="api", method="GET", status=~"2.."}
```

### Range Vector Selectors

```promql
# Last 5 minutes
http_requests_total[5m]

# Last 1 hour
http_requests_total[1h]

# Time units: s, m, h, d, w, y
http_requests_total[30s]
http_requests_total[2h]
http_requests_total[7d]
```

### Offset Modifier

```promql
# 5 minutes ago
http_requests_total offset 5m

# 1 hour ago
http_requests_total offset 1h

# Compare with 1 day ago
http_requests_total - http_requests_total offset 1d
```

---

## 🎯 Selectors & Matchers: Finding Metrics

*Precise selection is the key to useful queries.*

### Label Matchers

```promql
# Equality
{job="api"}

# Inequality
{job!="api"}

# Regex match
{job=~"api|web"}
{instance=~".*:9090"}

# Regex not match
{job!~"test.*"}

# Multiple labels
{job="api", method="GET", status=~"2.."}

# All metrics for a job
{job="api"}
```

### Metric Name Matching

```promql
# All metrics starting with http_
{__name__=~"http_.*"}

# All metrics ending with _total
{__name__=~".*_total"}

# Exclude metrics
{__name__!~"test_.*"}
```

---

## ➕ Operators: The Mathematical Path

*Operators transform and combine metrics.*

### Arithmetic Operators

```promql
# Addition
node_memory_total_bytes + 1000000

# Subtraction
node_memory_total_bytes - node_memory_available_bytes

# Multiplication
http_requests_total * 2

# Division
node_memory_available_bytes / node_memory_total_bytes

# Modulo
http_requests_total % 100

# Power
http_requests_total ^ 2
```

### Comparison Operators

```promql
# Equal
http_requests_total == 100

# Not equal
http_requests_total != 100

# Greater than
http_requests_total > 1000

# Less than
http_requests_total < 100

# Greater or equal
http_requests_total >= 1000

# Less or equal
http_requests_total <= 100

# Filter (bool modifier)
http_requests_total > bool 1000  # Returns 0 or 1
```

### Logical Operators

```promql
# AND
up{job="api"} and http_requests_total

# OR
up{job="api"} or up{job="web"}

# UNLESS (AND NOT)
up{job="api"} unless http_requests_total
```

### Vector Matching

```promql
# One-to-one matching
method:http_requests:rate5m / ignoring(status) method:http_requests:rate5m

# Many-to-one matching
method:http_requests:rate5m / on(instance) group_left instance:node_cpu:ratio

# One-to-many matching
instance:node_cpu:ratio / on(instance) group_right method:http_requests:rate5m
```

---

## 🔧 Functions: The Transformation Tools

*Functions transform metrics into insights.*

### Rate Functions

```promql
# Rate: Per-second average rate
rate(http_requests_total[5m])

# Irate: Instant rate (last 2 points)
irate(http_requests_total[5m])

# Increase: Total increase
increase(http_requests_total[1h])

# Delta: Difference (for gauges)
delta(cpu_temp_celsius[5m])

# Idelta: Instant delta
idelta(cpu_temp_celsius[5m])
```

### Aggregation Over Time

```promql
# Average over time
avg_over_time(cpu_usage[5m])

# Min over time
min_over_time(cpu_usage[5m])

# Max over time
max_over_time(cpu_usage[5m])

# Sum over time
sum_over_time(http_requests_total[5m])

# Count over time
count_over_time(up[5m])

# Quantile over time
quantile_over_time(0.95, http_request_duration_seconds[5m])

# Standard deviation
stddev_over_time(cpu_usage[5m])

# Standard variance
stdvar_over_time(cpu_usage[5m])
```

### Prediction Functions

```promql
# Predict linear
predict_linear(node_filesystem_free_bytes[1h], 4 * 3600)

# Deriv: Per-second derivative
deriv(node_filesystem_free_bytes[1h])

# Holt-Winters
holt_winters(http_requests_total[1h], 0.5, 0.5)
```

### Math Functions

```promql
# Absolute value
abs(delta(cpu_temp_celsius[5m]))

# Ceiling
ceil(http_request_duration_seconds)

# Floor
floor(http_request_duration_seconds)

# Round
round(http_request_duration_seconds, 0.1)

# Exponential
exp(http_requests_total)

# Logarithm
ln(http_requests_total)
log2(http_requests_total)
log10(http_requests_total)

# Square root
sqrt(http_requests_total)
```

### Time Functions

```promql
# Current timestamp
time()

# Day of month (1-31)
day_of_month()

# Day of week (0-6, Sunday=0)
day_of_week()

# Hour (0-23)
hour()

# Minute (0-59)
minute()

# Month (1-12)
month()

# Year
year()

# Timestamp of metric
timestamp(http_requests_total)
```

### Sorting Functions

```promql
# Sort ascending
sort(http_requests_total)

# Sort descending
sort_desc(http_requests_total)

# Top k
topk(5, http_requests_total)

# Bottom k
bottomk(5, http_requests_total)
```

### Label Functions

```promql
# Label replace
label_replace(up, "new_label", "$1", "instance", "(.*):(.*)")

# Label join
label_join(up, "new_label", ",", "job", "instance")
```

---

## 📈 Aggregation: The Grouping Wisdom

*Aggregation combines multiple time series.*

### Aggregation Operators

```promql
# Sum
sum(http_requests_total)

# Min
min(http_requests_total)

# Max
max(http_requests_total)

# Average
avg(http_requests_total)

# Standard deviation
stddev(http_requests_total)

# Standard variance
stdvar(http_requests_total)

# Count
count(http_requests_total)

# Count values
count_values("status", http_requests_total)

# Quantile
quantile(0.95, http_request_duration_seconds)
```

### Grouping

```promql
# Sum by job
sum by(job) (http_requests_total)

# Sum by job and method
sum by(job, method) (http_requests_total)

# Sum without instance (keep all other labels)
sum without(instance) (http_requests_total)

# Average by status
avg by(status) (http_request_duration_seconds)

# Max by instance
max by(instance) (node_memory_usage_bytes)
```

### Complex Aggregations

```promql
# Request rate by job
sum by(job) (rate(http_requests_total[5m]))

# Error rate
sum by(job) (rate(http_requests_total{status=~"5.."}[5m])) 
/ 
sum by(job) (rate(http_requests_total[5m]))

# 95th percentile latency by endpoint
histogram_quantile(0.95, 
  sum by(endpoint, le) (rate(http_request_duration_seconds_bucket[5m]))
)

# Memory usage percentage
(node_memory_total_bytes - node_memory_available_bytes) 
/ 
node_memory_total_bytes * 100
```

---

## 📝 Recording Rules: Pre-Computed Wisdom

*Recording rules pre-compute expensive queries.*

### Recording Rules Configuration

```yaml
# rules/recording.yml
groups:
  - name: instance_metrics
    interval: 30s
    rules:
      # CPU usage per instance
      - record: instance:node_cpu:ratio
        expr: |
          1 - avg without(cpu) (
            rate(node_cpu_seconds_total{mode="idle"}[5m])
          )
      
      # Memory usage per instance
      - record: instance:node_memory_usage:ratio
        expr: |
          (node_memory_total_bytes - node_memory_available_bytes)
          /
          node_memory_total_bytes
      
      # Disk usage per instance
      - record: instance:node_disk_usage:ratio
        expr: |
          (node_filesystem_size_bytes - node_filesystem_free_bytes)
          /
          node_filesystem_size_bytes

  - name: http_metrics
    interval: 15s
    rules:
      # Request rate by job and method
      - record: job_method:http_requests:rate5m
        expr: |
          sum by(job, method) (
            rate(http_requests_total[5m])
          )
      
      # Error rate by job
      - record: job:http_errors:rate5m
        expr: |
          sum by(job) (
            rate(http_requests_total{status=~"5.."}[5m])
          )
      
      # 95th percentile latency
      - record: job:http_request_duration:p95
        expr: |
          histogram_quantile(0.95,
            sum by(job, le) (
              rate(http_request_duration_seconds_bucket[5m])
            )
          )
```

### Naming Conventions

```promql
# Format: level:metric:operations
# level: aggregation level (instance, job, cluster)
# metric: metric name
# operations: operations applied (rate5m, sum, ratio)

# Examples
instance:node_cpu:ratio
job:http_requests:rate5m
cluster:memory_usage:sum
```

---

## 🚨 Alerting Rules: The Watchful Guardians

*Alerting rules notify when things go wrong.*

### Alert Rules Configuration

```yaml
# rules/alerts.yml
groups:
  - name: instance_alerts
    interval: 30s
    rules:
      # Instance down
      - alert: InstanceDown
        expr: up == 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Instance {{ $labels.instance }} down"
          description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes."
      
      # High CPU usage
      - alert: HighCPUUsage
        expr: instance:node_cpu:ratio > 0.8
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is {{ $value | humanizePercentage }} on {{ $labels.instance }}"
      
      # High memory usage
      - alert: HighMemoryUsage
        expr: instance:node_memory_usage:ratio > 0.9
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is {{ $value | humanizePercentage }} on {{ $labels.instance }}"
      
      # Disk space low
      - alert: DiskSpaceLow
        expr: instance:node_disk_usage:ratio > 0.85
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Disk space low on {{ $labels.instance }}"
          description: "Disk usage is {{ $value | humanizePercentage }} on {{ $labels.instance }}"

  - name: application_alerts
    interval: 15s
    rules:
      # High error rate
      - alert: HighErrorRate
        expr: |
          (
            sum by(job) (rate(http_requests_total{status=~"5.."}[5m]))
            /
            sum by(job) (rate(http_requests_total[5m]))
          ) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate for {{ $labels.job }}"
          description: "Error rate is {{ $value | humanizePercentage }} for {{ $labels.job }}"
      
      # High latency
      - alert: HighLatency
        expr: job:http_request_duration:p95 > 1
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High latency for {{ $labels.job }}"
          description: "95th percentile latency is {{ $value }}s for {{ $labels.job }}"
      
      # Low request rate (possible issue)
      - alert: LowRequestRate
        expr: sum by(job) (rate(http_requests_total[5m])) < 10
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Low request rate for {{ $labels.job }}"
          description: "Request rate is {{ $value }} req/s for {{ $labels.job }}"
```

### Alert Template Functions

```yaml
annotations:
  # Humanize numbers
  summary: "CPU usage: {{ $value | humanize }}"
  
  # Humanize percentage
  summary: "Memory usage: {{ $value | humanizePercentage }}"
  
  # Humanize duration
  summary: "Uptime: {{ $value | humanizeDuration }}"
  
  # Humanize timestamp
  summary: "Since: {{ $value | humanizeTimestamp }}"
```

---

## 📡 Exporters: The Metric Gatherers

*Exporters expose metrics from various systems.*

### Common Exporters

```bash
# Node Exporter (system metrics)
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.6.1.linux-amd64.tar.gz
./node_exporter
# Metrics: http://localhost:9100/metrics

# Blackbox Exporter (probing)
docker run -p 9115:9115 prom/blackbox-exporter

# MySQL Exporter
docker run -p 9104:9104 -e DATA_SOURCE_NAME="user:password@(hostname:3306)/" prom/mysqld-exporter

# PostgreSQL Exporter
docker run -p 9187:9187 -e DATA_SOURCE_NAME="postgresql://user:password@hostname:5432/database?sslmode=disable" prometheuscommunity/postgres-exporter

# Redis Exporter
docker run -p 9121:9121 oliver006/redis_exporter

# Nginx Exporter
docker run -p 9113:9113 nginx/nginx-prometheus-exporter:0.11.0 -nginx.scrape-uri=http://nginx:8080/stub_status
```

### Custom Exporter (Python)

```python
# app.py
from prometheus_client import start_http_server, Counter, Gauge, Histogram
import time
import random

# Metrics
REQUEST_COUNT = Counter('app_requests_total', 'Total requests', ['method', 'endpoint'])
ACTIVE_USERS = Gauge('app_active_users', 'Active users')
REQUEST_DURATION = Histogram('app_request_duration_seconds', 'Request duration', ['endpoint'])

def process_request():
    REQUEST_COUNT.labels(method='GET', endpoint='/api').inc()
    ACTIVE_USERS.set(random.randint(10, 100))
    
    with REQUEST_DURATION.labels(endpoint='/api').time():
        time.sleep(random.random())

if __name__ == '__main__':
    start_http_server(8000)
    while True:
        process_request()
        time.sleep(1)
```

---

## 🔮 Common Patterns: The Sacred Workflows

*These are the rituals performed by monks in production temples daily.*

### Pattern 1: SLI/SLO Queries

```promql
# Availability SLI (uptime)
avg_over_time(up[30d]) * 100

# Latency SLI (95th percentile < 200ms)
histogram_quantile(0.95, 
  sum by(le) (rate(http_request_duration_seconds_bucket[5m]))
) < 0.2

# Error rate SLI (< 1%)
(
  sum(rate(http_requests_total{status=~"5.."}[30d]))
  /
  sum(rate(http_requests_total[30d]))
) < 0.01

# Throughput SLI (> 1000 req/s)
sum(rate(http_requests_total[5m])) > 1000

# Error budget remaining
1 - (
  sum(rate(http_requests_total{status=~"5.."}[30d]))
  /
  sum(rate(http_requests_total[30d]))
) / 0.01  # 1% error budget
```

**Use case**: Service Level Objectives monitoring  
**Best for**: SRE teams tracking reliability

### Pattern 2: Capacity Planning

```promql
# Predict disk full in 4 hours
predict_linear(node_filesystem_free_bytes[1h], 4 * 3600) < 0

# Memory growth rate
deriv(node_memory_usage_bytes[1h])

# Request growth rate
deriv(sum(rate(http_requests_total[5m]))[1h])

# Saturation (queue depth)
avg_over_time(queue_depth[1h]) / queue_capacity > 0.8

# CPU saturation
avg_over_time(node_load1[15m]) / count(node_cpu_seconds_total{mode="idle"}) > 0.8
```

**Use case**: Infrastructure capacity planning  
**Best for**: Predicting resource needs

### Pattern 3: Anomaly Detection

```promql
# Deviation from normal (using stddev)
abs(
  http_requests_total - avg_over_time(http_requests_total[1h])
) > 3 * stddev_over_time(http_requests_total[1h])

# Compare with last week
abs(
  http_requests_total - (http_requests_total offset 7d)
) / (http_requests_total offset 7d) > 0.5

# Sudden spike detection
rate(http_requests_total[5m]) > 2 * rate(http_requests_total[1h] offset 1h)

# Holt-Winters prediction
abs(
  http_requests_total - holt_winters(http_requests_total[1h], 0.5, 0.5)
) > 100
```

**Use case**: Detecting unusual behavior  
**Best for**: Early problem detection

### Pattern 4: RED Method (Rate, Errors, Duration)

```promql
# Rate: Requests per second
sum by(job, endpoint) (rate(http_requests_total[5m]))

# Errors: Error rate
sum by(job) (rate(http_requests_total{status=~"5.."}[5m]))
/
sum by(job) (rate(http_requests_total[5m]))

# Duration: Latency percentiles
histogram_quantile(0.50, 
  sum by(job, le) (rate(http_request_duration_seconds_bucket[5m]))
)
histogram_quantile(0.95, 
  sum by(job, le) (rate(http_request_duration_seconds_bucket[5m]))
)
histogram_quantile(0.99, 
  sum by(job, le) (rate(http_request_duration_seconds_bucket[5m]))
)
```

**Use case**: Service health monitoring  
**Best for**: Microservices observability

### Pattern 5: USE Method (Utilization, Saturation, Errors)

```promql
# Utilization: CPU usage
1 - avg without(cpu) (rate(node_cpu_seconds_total{mode="idle"}[5m]))

# Saturation: Load average
node_load1 / count without(cpu) (node_cpu_seconds_total{mode="idle"})

# Errors: System errors
rate(node_network_receive_errs_total[5m])
rate(node_disk_io_errors_total[5m])

# Memory utilization
(node_memory_total_bytes - node_memory_available_bytes) / node_memory_total_bytes

# Disk utilization
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes

# Network saturation
rate(node_network_receive_drop_total[5m])
```

**Use case**: Resource monitoring  
**Best for**: Infrastructure health

---

## 🔧 Troubleshooting: When the Path is Obscured

*Even the wisest monks encounter obstacles.*

### Common Issues

#### No Data / Missing Metrics

```promql
# Check if target is up
up{job="myapp"}

# Check scrape duration
scrape_duration_seconds{job="myapp"}

# Check scrape samples
scrape_samples_scraped{job="myapp"}

# Check for scrape errors
up{job="myapp"} == 0
```

#### High Cardinality

```bash
# Check series count
curl http://localhost:9090/api/v1/status/tsdb

# Find high cardinality metrics
topk(10, count by(__name__)({__name__=~".+"}))

# Find high cardinality labels
topk(10, count by(label_name)({__name__="metric_name"}))
```

#### Query Performance

```promql
# Avoid high cardinality aggregations
# Bad
sum(rate(http_requests_total[5m]))

# Good (aggregate by fewer labels)
sum by(job) (rate(http_requests_total[5m]))

# Use recording rules for expensive queries
# Instead of querying this repeatedly:
histogram_quantile(0.95, sum by(le) (rate(http_request_duration_seconds_bucket[5m])))

# Create recording rule:
job:http_request_duration:p95
```

#### Memory Issues

```yaml
# Reduce retention
storage:
  tsdb:
    retention.time: 15d
    retention.size: 50GB

# Reduce scrape frequency
global:
  scrape_interval: 30s  # Instead of 15s

# Limit series
limits:
  max-samples-per-query: 50000000
```

---

## 🙏 Closing Wisdom

*The path of Prometheus mastery is endless. These queries are but stepping stones.*

### Essential Daily Queries

```promql
# The monk's morning ritual
up
rate(http_requests_total[5m])
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))

# The monk's health check
instance:node_cpu:ratio
instance:node_memory_usage:ratio
instance:node_disk_usage:ratio

# The monk's error check
sum by(job) (rate(http_requests_total{status=~"5.."}[5m]))
```

### Best Practices from the Monastery

1. **Use Recording Rules**: Pre-compute expensive queries
2. **Label Wisely**: Avoid high cardinality labels
3. **Rate for Counters**: Always use rate() for counters
4. **Histogram Quantiles**: Use histogram_quantile() for percentiles
5. **Aggregation**: Aggregate before rate() when possible
6. **Time Ranges**: Use appropriate time ranges (5m for rate)
7. **Alert Hygiene**: Use 'for' clause to avoid flapping
8. **Naming Convention**: Follow level:metric:operations format
9. **Monitor Prometheus**: Monitor Prometheus itself
10. **Test Queries**: Test in Prometheus UI before alerting
11. **Document Rules**: Comment complex recording/alerting rules
12. **Version Control**: Store rules in Git

### Quick Reference Card

| Query | What It Does |
|-------|-------------|
| `up` | Target health |
| `rate(metric[5m])` | Per-second rate |
| `increase(metric[1h])` | Total increase |
| `histogram_quantile(0.95, ...)` | 95th percentile |
| `sum by(label) (metric)` | Aggregate by label |
| `avg_over_time(metric[5m])` | Average over time |
| `predict_linear(metric[1h], 3600)` | Predict 1h ahead |
| `topk(5, metric)` | Top 5 values |
| `count(metric)` | Count series |
| `absent(metric)` | Check if metric missing |

---

*May your queries be fast, your alerts be accurate, and your metrics always flowing.*

**— The Monk of Metrics**  
*Monastery of Observability*  
*Temple of Prometheus*

🧘 **Namaste, `promql`**

---

## 📚 Additional Resources

- [Official Prometheus Documentation](https://prometheus.io/docs/)
- [PromQL Basics](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [Awesome Prometheus](https://github.com/roaldnefs/awesome-prometheus)
- [PromQL Cheat Sheet](https://promlabs.com/promql-cheat-sheet/)
- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*Prometheus Version: 2.47+*
