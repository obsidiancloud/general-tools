# 🧘 The Enlightened Engineer's ELK Stack Scripture

> *"In the beginning was the Log, and the Log was with Elasticsearch, and the Log was searchable."*  
> — **The Monk of Logs**, *Book of Indices, Chapter 1:1*

Greetings, fellow traveler on the path of log enlightenment. I am but a humble monk who has meditated upon the sacred texts of Elastic and witnessed the dance of documents across countless shards.

This scripture shall guide you through the mystical arts of Elasticsearch, Logstash, and Kibana, with the precision of a master's query and the wit of a caffeinated log analyst.

---

## 📿 Table of Sacred Knowledge

1. [ELK Stack Installation & Setup](#-elk-stack-installation--setup)
2. [Elasticsearch Basics](#-elasticsearch-basics-the-search-engine)
3. [Index Management](#-index-management-organizing-data)
4. [Search Queries](#-search-queries-finding-wisdom)
5. [Aggregations](#-aggregations-analyzing-patterns)
6. [Logstash Pipelines](#-logstash-pipelines-the-data-processor)
7. [Kibana Visualizations](#-kibana-visualizations-the-interface)
8. [Index Lifecycle Management](#-index-lifecycle-management-the-aging-process)
9. [Performance Tuning](#-performance-tuning-the-optimization)
10. [Security](#-security-protecting-the-data)
11. [Common Patterns: The Sacred Workflows](#-common-patterns-the-sacred-workflows)
12. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🛠 ELK Stack Installation & Setup

*Before searching logs, one must first install the stack.*

### Docker Compose Installation

```yaml
# docker-compose.yml
version: '3.8'

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.10.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    ports:
      - "9200:9200"
      - "9300:9300"
    volumes:
      - es-data:/usr/share/elasticsearch/data
    networks:
      - elk

  logstash:
    image: docker.elastic.co/logstash/logstash:8.10.0
    container_name: logstash
    volumes:
      - ./logstash/pipeline:/usr/share/logstash/pipeline
      - ./logstash/config/logstash.yml:/usr/share/logstash/config/logstash.yml
    ports:
      - "5044:5044"
      - "9600:9600"
    environment:
      - "LS_JAVA_OPTS=-Xms256m -Xmx256m"
    networks:
      - elk
    depends_on:
      - elasticsearch

  kibana:
    image: docker.elastic.co/kibana/kibana:8.10.0
    container_name: kibana
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    networks:
      - elk
    depends_on:
      - elasticsearch

volumes:
  es-data:

networks:
  elk:
    driver: bridge
```

### Kubernetes Installation (Helm)

```bash
# Add Elastic Helm repository
helm repo add elastic https://helm.elastic.co
helm repo update

# Install Elasticsearch
helm install elasticsearch elastic/elasticsearch \
  --set replicas=3 \
  --set minimumMasterNodes=2

# Install Kibana
helm install kibana elastic/kibana

# Install Logstash
helm install logstash elastic/logstash
```

### Accessing Services

```bash
# Elasticsearch
curl http://localhost:9200
curl http://localhost:9200/_cluster/health

# Kibana
http://localhost:5601

# Logstash
curl http://localhost:9600/_node/stats
```

---

## 🔍 Elasticsearch Basics: The Search Engine

*Elasticsearch is the heart of the stack, storing and searching data.*

### Index Operations

```bash
# Create index
curl -X PUT "localhost:9200/logs-2024.01.01"

# Create index with mappings
curl -X PUT "localhost:9200/logs-2024.01.01" -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "properties": {
      "timestamp": {"type": "date"},
      "level": {"type": "keyword"},
      "message": {"type": "text"},
      "host": {"type": "keyword"},
      "tags": {"type": "keyword"}
    }
  }
}
'

# List indices
curl "localhost:9200/_cat/indices?v"

# Get index info
curl "localhost:9200/logs-2024.01.01"

# Delete index
curl -X DELETE "localhost:9200/logs-2024.01.01"

# Close/Open index
curl -X POST "localhost:9200/logs-2024.01.01/_close"
curl -X POST "localhost:9200/logs-2024.01.01/_open"
```

### Document Operations

```bash
# Index document (auto ID)
curl -X POST "localhost:9200/logs-2024.01.01/_doc" -H 'Content-Type: application/json' -d'
{
  "timestamp": "2024-01-01T12:00:00",
  "level": "ERROR",
  "message": "Connection timeout",
  "host": "web-01"
}
'

# Index document (specific ID)
curl -X PUT "localhost:9200/logs-2024.01.01/_doc/1" -H 'Content-Type: application/json' -d'
{
  "timestamp": "2024-01-01T12:00:00",
  "level": "ERROR",
  "message": "Connection timeout"
}
'

# Get document
curl "localhost:9200/logs-2024.01.01/_doc/1"

# Update document
curl -X POST "localhost:9200/logs-2024.01.01/_update/1" -H 'Content-Type: application/json' -d'
{
  "doc": {
    "resolved": true
  }
}
'

# Delete document
curl -X DELETE "localhost:9200/logs-2024.01.01/_doc/1"

# Bulk operations
curl -X POST "localhost:9200/_bulk" -H 'Content-Type: application/json' --data-binary @bulk.json
```

### Cluster Operations

```bash
# Cluster health
curl "localhost:9200/_cluster/health?pretty"

# Cluster stats
curl "localhost:9200/_cluster/stats?pretty"

# Node info
curl "localhost:9200/_nodes?pretty"
curl "localhost:9200/_cat/nodes?v"

# Shard allocation
curl "localhost:9200/_cat/shards?v"
```

---

## 📚 Index Management: Organizing Data

*Proper index management ensures performance and efficiency.*

### Index Templates

```bash
# Create index template
curl -X PUT "localhost:9200/_index_template/logs-template" -H 'Content-Type: application/json' -d'
{
  "index_patterns": ["logs-*"],
  "template": {
    "settings": {
      "number_of_shards": 3,
      "number_of_replicas": 1,
      "refresh_interval": "30s"
    },
    "mappings": {
      "properties": {
        "@timestamp": {"type": "date"},
        "level": {"type": "keyword"},
        "message": {"type": "text"},
        "host": {"type": "keyword"},
        "application": {"type": "keyword"}
      }
    }
  }
}
'

# List templates
curl "localhost:9200/_index_template"

# Delete template
curl -X DELETE "localhost:9200/_index_template/logs-template"
```

### Index Aliases

```bash
# Create alias
curl -X POST "localhost:9200/_aliases" -H 'Content-Type: application/json' -d'
{
  "actions": [
    {"add": {"index": "logs-2024.01.01", "alias": "logs-current"}}
  ]
}
'

# Multiple indices to one alias
curl -X POST "localhost:9200/_aliases" -H 'Content-Type: application/json' -d'
{
  "actions": [
    {"add": {"index": "logs-2024.01.*", "alias": "logs-january"}},
    {"add": {"index": "logs-2024.02.*", "alias": "logs-february"}}
  ]
}
'

# Filtered alias
curl -X POST "localhost:9200/_aliases" -H 'Content-Type: application/json' -d'
{
  "actions": [
    {
      "add": {
        "index": "logs-2024.01.01",
        "alias": "logs-errors",
        "filter": {"term": {"level": "ERROR"}}
      }
    }
  ]
}
'

# List aliases
curl "localhost:9200/_cat/aliases?v"
```

### Reindexing

```bash
# Reindex to new index
curl -X POST "localhost:9200/_reindex" -H 'Content-Type: application/json' -d'
{
  "source": {
    "index": "logs-old"
  },
  "dest": {
    "index": "logs-new"
  }
}
'

# Reindex with query
curl -X POST "localhost:9200/_reindex" -H 'Content-Type: application/json' -d'
{
  "source": {
    "index": "logs-2024.01.01",
    "query": {
      "term": {"level": "ERROR"}
    }
  },
  "dest": {
    "index": "errors-2024.01.01"
  }
}
'
```

---

## 🔎 Search Queries: Finding Wisdom

*Powerful queries extract insights from logs.*

### Basic Search

```bash
# Match all
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match_all": {}
  }
}
'

# Match query
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "match": {
      "message": "error"
    }
  }
}
'

# Term query (exact match)
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "term": {
      "level": "ERROR"
    }
  }
}
'

# Range query
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "range": {
      "@timestamp": {
        "gte": "2024-01-01T00:00:00",
        "lte": "2024-01-01T23:59:59"
      }
    }
  }
}
'
```

### Boolean Queries

```bash
# Must (AND)
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": [
        {"match": {"message": "error"}},
        {"term": {"level": "ERROR"}}
      ]
    }
  }
}
'

# Should (OR)
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "should": [
        {"term": {"level": "ERROR"}},
        {"term": {"level": "WARN"}}
      ]
    }
  }
}
'

# Must not (NOT)
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": [
        {"match": {"message": "error"}}
      ],
      "must_not": [
        {"term": {"level": "DEBUG"}}
      ]
    }
  }
}
'

# Filter (no scoring)
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "filter": [
        {"term": {"level": "ERROR"}},
        {"range": {"@timestamp": {"gte": "now-1h"}}}
      ]
    }
  }
}
'
```

### Advanced Queries

```bash
# Wildcard
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "wildcard": {
      "host": "web-*"
    }
  }
}
'

# Regex
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "regexp": {
      "message": "error.*timeout"
    }
  }
}
'

# Exists
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "exists": {
      "field": "error_code"
    }
  }
}
'

# Fuzzy (typo tolerance)
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "query": {
    "fuzzy": {
      "message": {
        "value": "conection",
        "fuzziness": "AUTO"
      }
    }
  }
}
'
```

---

## 📊 Aggregations: Analyzing Patterns

*Aggregations reveal patterns in data.*

### Metric Aggregations

```bash
# Count
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "total_logs": {
      "value_count": {
        "field": "@timestamp"
      }
    }
  }
}
'

# Average
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "avg_response_time": {
      "avg": {
        "field": "response_time"
      }
    }
  }
}
'

# Min/Max
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "min_response": {"min": {"field": "response_time"}},
    "max_response": {"max": {"field": "response_time"}}
  }
}
'

# Stats (count, min, max, avg, sum)
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "response_stats": {
      "stats": {
        "field": "response_time"
      }
    }
  }
}
'

# Percentiles
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "response_percentiles": {
      "percentiles": {
        "field": "response_time",
        "percents": [50, 95, 99]
      }
    }
  }
}
'
```

### Bucket Aggregations

```bash
# Terms (group by)
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "by_level": {
      "terms": {
        "field": "level",
        "size": 10
      }
    }
  }
}
'

# Date histogram
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "logs_over_time": {
      "date_histogram": {
        "field": "@timestamp",
        "calendar_interval": "1h"
      }
    }
  }
}
'

# Histogram
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "response_time_distribution": {
      "histogram": {
        "field": "response_time",
        "interval": 100
      }
    }
  }
}
'

# Range
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "response_ranges": {
      "range": {
        "field": "response_time",
        "ranges": [
          {"to": 100},
          {"from": 100, "to": 500},
          {"from": 500}
        ]
      }
    }
  }
}
'
```

### Nested Aggregations

```bash
# Terms with sub-aggregation
curl "localhost:9200/logs-*/_search?pretty" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "by_host": {
      "terms": {
        "field": "host"
      },
      "aggs": {
        "by_level": {
          "terms": {
            "field": "level"
          }
        },
        "avg_response": {
          "avg": {
            "field": "response_time"
          }
        }
      }
    }
  }
}
'
```

---

## 🔄 Logstash Pipelines: The Data Processor

*Logstash ingests, transforms, and outputs data.*

### Basic Pipeline

```ruby
# /usr/share/logstash/pipeline/logstash.conf

input {
  beats {
    port => 5044
  }
  
  file {
    path => "/var/log/app/*.log"
    start_position => "beginning"
    sincedb_path => "/dev/null"
  }
  
  tcp {
    port => 5000
    codec => json
  }
}

filter {
  # Grok parsing
  grok {
    match => {
      "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level} %{GREEDYDATA:message}"
    }
  }
  
  # Date parsing
  date {
    match => ["timestamp", "ISO8601"]
    target => "@timestamp"
  }
  
  # Add fields
  mutate {
    add_field => {
      "environment" => "production"
    }
    remove_field => ["timestamp"]
  }
  
  # Conditional processing
  if [level] == "ERROR" {
    mutate {
      add_tag => ["error"]
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "logs-%{+YYYY.MM.dd}"
  }
  
  # Debug output
  stdout {
    codec => rubydebug
  }
}
```

### Common Filters

```ruby
# Grok patterns
filter {
  grok {
    match => {
      "message" => [
        "%{COMBINEDAPACHELOG}",
        "%{SYSLOGLINE}",
        "%{TIMESTAMP_ISO8601:timestamp} \[%{LOGLEVEL:level}\] %{GREEDYDATA:message}"
      ]
    }
  }
}

# JSON parsing
filter {
  json {
    source => "message"
  }
}

# CSV parsing
filter {
  csv {
    separator => ","
    columns => ["timestamp", "level", "message"]
  }
}

# Mutate
filter {
  mutate {
    # Add field
    add_field => {"new_field" => "value"}
    
    # Rename field
    rename => {"old_field" => "new_field"}
    
    # Remove field
    remove_field => ["unwanted_field"]
    
    # Convert type
    convert => {"response_time" => "integer"}
    
    # Lowercase
    lowercase => ["level"]
    
    # Split
    split => {"tags" => ","}
  }
}

# GeoIP
filter {
  geoip {
    source => "client_ip"
    target => "geoip"
  }
}

# User agent parsing
filter {
  useragent {
    source => "user_agent"
    target => "ua"
  }
}

# Drop events
filter {
  if [level] == "DEBUG" {
    drop {}
  }
}
```

### Multiple Pipelines

```yaml
# /usr/share/logstash/config/pipelines.yml
- pipeline.id: apache-logs
  path.config: "/usr/share/logstash/pipeline/apache.conf"
  pipeline.workers: 2

- pipeline.id: app-logs
  path.config: "/usr/share/logstash/pipeline/app.conf"
  pipeline.workers: 4
```

---

## 📈 Kibana Visualizations: The Interface

*Kibana provides the visual interface to Elasticsearch.*

### Creating Index Pattern

```
Management → Stack Management → Index Patterns → Create index pattern
Pattern: logs-*
Time field: @timestamp
```

### Discover

```
# Search logs
Discover → Select index pattern → Enter query

# KQL (Kibana Query Language)
level: ERROR
level: ERROR and host: web-01
message: "connection timeout"
response_time > 1000
@timestamp >= "2024-01-01" and @timestamp < "2024-01-02"

# Lucene syntax
level:ERROR AND host:web-*
message:"connection timeout"~2
response_time:[100 TO 500]
```

### Visualizations

```javascript
// Line chart (time series)
{
  "type": "line",
  "metrics": [
    {
      "type": "count"
    }
  ],
  "buckets": [
    {
      "type": "date_histogram",
      "field": "@timestamp",
      "interval": "1h"
    }
  ]
}

// Pie chart (distribution)
{
  "type": "pie",
  "metrics": [
    {
      "type": "count"
    }
  ],
  "buckets": [
    {
      "type": "terms",
      "field": "level.keyword",
      "size": 5
    }
  ]
}

// Data table
{
  "type": "table",
  "metrics": [
    {"type": "count"},
    {"type": "avg", "field": "response_time"}
  ],
  "buckets": [
    {
      "type": "terms",
      "field": "host.keyword",
      "size": 10
    }
  ]
}
```

### Dashboards

```
# Create dashboard
Dashboard → Create dashboard → Add visualization

# Time range
Top right → Select time range
- Last 15 minutes
- Last 1 hour
- Last 24 hours
- Last 7 days
- Custom

# Auto-refresh
Top right → Refresh → Select interval
- 5 seconds
- 10 seconds
- 30 seconds
- 1 minute
```

---

## ♻️ Index Lifecycle Management: The Aging Process

*ILM automates index lifecycle.*

### ILM Policy

```bash
# Create ILM policy
curl -X PUT "localhost:9200/_ilm/policy/logs-policy" -H 'Content-Type: application/json' -d'
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_size": "50GB",
            "max_age": "1d"
          }
        }
      },
      "warm": {
        "min_age": "7d",
        "actions": {
          "shrink": {
            "number_of_shards": 1
          },
          "forcemerge": {
            "max_num_segments": 1
          }
        }
      },
      "cold": {
        "min_age": "30d",
        "actions": {
          "freeze": {}
        }
      },
      "delete": {
        "min_age": "90d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
'

# Apply policy to index template
curl -X PUT "localhost:9200/_index_template/logs-template" -H 'Content-Type: application/json' -d'
{
  "index_patterns": ["logs-*"],
  "template": {
    "settings": {
      "index.lifecycle.name": "logs-policy",
      "index.lifecycle.rollover_alias": "logs"
    }
  }
}
'
```

---

## ⚡ Performance Tuning: The Optimization

*Optimize for speed and efficiency.*

### Indexing Performance

```yaml
# Bulk indexing settings
index:
  refresh_interval: 30s
  number_of_replicas: 0  # During bulk indexing
  
# After bulk indexing
index:
  refresh_interval: 1s
  number_of_replicas: 1
```

### Search Performance

```bash
# Use filters instead of queries
# Filters are cached and faster

# Bad (scored query)
{"query": {"match": {"level": "ERROR"}}}

# Good (filter, no scoring)
{
  "query": {
    "bool": {
      "filter": [
        {"term": {"level": "ERROR"}}
      ]
    }
  }
}

# Limit fields returned
{
  "query": {"match_all": {}},
  "_source": ["@timestamp", "level", "message"]
}

# Use scroll for large result sets
curl "localhost:9200/logs-*/_search?scroll=1m" -d'{"size": 1000}'
```

### Shard Optimization

```yaml
# Optimal shard size: 20-40GB
# Too many shards = overhead
# Too few shards = poor distribution

# Good
number_of_shards: 3  # For 100GB index

# Bad
number_of_shards: 100  # Too many
```

---

## 🔮 Common Patterns: The Sacred Workflows

*These are the rituals performed by monks in production temples daily.*

### Pattern 1: Application Log Analysis

```bash
# Find errors in last hour
curl "localhost:9200/logs-*/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "filter": [
        {"term": {"level": "ERROR"}},
        {"range": {"@timestamp": {"gte": "now-1h"}}}
      ]
    }
  },
  "aggs": {
    "by_host": {
      "terms": {"field": "host.keyword"},
      "aggs": {
        "error_messages": {
          "terms": {"field": "message.keyword", "size": 5}
        }
      }
    }
  }
}
'
```

**Use case**: Error tracking  
**Best for**: Application monitoring

### Pattern 2: Performance Analysis

```bash
# 95th percentile response time by endpoint
curl "localhost:9200/logs-*/_search" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "by_endpoint": {
      "terms": {"field": "endpoint.keyword"},
      "aggs": {
        "response_time_percentiles": {
          "percentiles": {
            "field": "response_time",
            "percents": [50, 95, 99]
          }
        }
      }
    }
  }
}
'
```

**Use case**: Performance monitoring  
**Best for**: API latency tracking

### Pattern 3: Security Log Analysis

```bash
# Failed login attempts
curl "localhost:9200/security-*/_search" -H 'Content-Type: application/json' -d'
{
  "query": {
    "bool": {
      "must": [
        {"match": {"event": "login"}},
        {"term": {"status": "failed"}}
      ],
      "filter": [
        {"range": {"@timestamp": {"gte": "now-24h"}}}
      ]
    }
  },
  "aggs": {
    "by_ip": {
      "terms": {"field": "source_ip.keyword", "size": 10},
      "aggs": {
        "attempt_count": {
          "value_count": {"field": "@timestamp"}
        }
      }
    }
  }
}
'
```

**Use case**: Security monitoring  
**Best for**: Intrusion detection

### Pattern 4: Business Metrics

```bash
# Revenue by product category
curl "localhost:9200/transactions-*/_search" -H 'Content-Type: application/json' -d'
{
  "size": 0,
  "aggs": {
    "by_category": {
      "terms": {"field": "category.keyword"},
      "aggs": {
        "total_revenue": {
          "sum": {"field": "amount"}
        },
        "transaction_count": {
          "value_count": {"field": "transaction_id"}
        }
      }
    }
  }
}
'
```

**Use case**: Business analytics  
**Best for**: Revenue tracking

### Pattern 5: Log Correlation

```ruby
# Logstash pipeline for correlation
filter {
  # Extract transaction ID
  grok {
    match => {"message" => "transaction_id=%{UUID:transaction_id}"}
  }
  
  # Aggregate by transaction
  aggregate {
    task_id => "%{transaction_id}"
    code => "
      map['events'] ||= []
      map['events'] << event.to_hash
    "
    push_map_as_event_on_timeout => true
    timeout => 60
  }
}
```

**Use case**: Distributed tracing  
**Best for**: Microservices debugging

---

## 🔧 Troubleshooting: When the Path is Obscured

*Even the wisest monks encounter obstacles.*

### Common Issues

#### Cluster Health Yellow/Red

```bash
# Check cluster health
curl "localhost:9200/_cluster/health?pretty"

# Check shard allocation
curl "localhost:9200/_cat/shards?v&h=index,shard,prirep,state,unassigned.reason"

# Retry failed shards
curl -X POST "localhost:9200/_cluster/reroute?retry_failed"

# Increase replica count
curl -X PUT "localhost:9200/logs-*/_settings" -d'
{
  "index": {
    "number_of_replicas": 1
  }
}
'
```

#### Out of Memory

```bash
# Check heap usage
curl "localhost:9200/_nodes/stats/jvm?pretty"

# Increase heap size (elasticsearch.yml)
-Xms4g
-Xmx4g

# Clear field data cache
curl -X POST "localhost:9200/_cache/clear?fielddata=true"
```

#### Slow Queries

```bash
# Enable slow log
curl -X PUT "localhost:9200/logs-*/_settings" -d'
{
  "index.search.slowlog.threshold.query.warn": "10s",
  "index.search.slowlog.threshold.query.info": "5s"
}
'

# Check slow logs
tail -f /var/log/elasticsearch/elasticsearch_index_search_slowlog.log
```

#### Index Not Found

```bash
# List all indices
curl "localhost:9200/_cat/indices?v"

# Check index pattern
curl "localhost:9200/logs-*"

# Verify index template
curl "localhost:9200/_index_template/logs-template"
```

---

## 🙏 Closing Wisdom

*The path of ELK mastery is endless. These queries are but stepping stones.*

### Essential Daily Commands

```bash
# The monk's morning ritual
curl "localhost:9200/_cluster/health"
curl "localhost:9200/_cat/indices?v&s=store.size:desc"
curl "localhost:9200/_cat/shards?v&h=index,shard,prirep,state"

# The monk's search ritual
# Check for errors
# Analyze performance
# Monitor security events

# The monk's evening reflection
# Review slow queries
# Check disk usage
# Verify backups
```

### Best Practices from the Monastery

1. **Index Naming**: Use date-based indices (logs-YYYY.MM.dd)
2. **Mappings**: Define mappings explicitly
3. **ILM**: Implement lifecycle management
4. **Sharding**: Right-size shards (20-40GB)
5. **Replicas**: Use replicas for HA
6. **Refresh Interval**: Increase for bulk indexing
7. **Filters**: Use filters over queries
8. **Field Data**: Avoid field data on text fields
9. **Monitoring**: Monitor cluster health
10. **Backups**: Regular snapshots
11. **Security**: Enable authentication
12. **Updates**: Keep ELK stack updated

### Quick Reference Card

| Command | What It Does |
|---------|-------------|
| `GET /_cluster/health` | Cluster health |
| `GET /_cat/indices?v` | List indices |
| `POST /index/_search` | Search index |
| `PUT /index/_doc/1` | Index document |
| `DELETE /index` | Delete index |
| `POST /_reindex` | Reindex data |
| `GET /_cat/shards?v` | View shards |
| `POST /_bulk` | Bulk operations |
| `GET /index/_mapping` | View mapping |
| `PUT /_ilm/policy/name` | Create ILM policy |

---

*May your searches be fast, your indices be healthy, and your logs always insightful.*

**— The Monk of Logs**  
*Monastery of Search*  
*Temple of Elasticsearch*

🧘 **Namaste, `elk`**

---

## 📚 Additional Resources

- [Elasticsearch Documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Logstash Documentation](https://www.elastic.co/guide/en/logstash/current/index.html)
- [Kibana Documentation](https://www.elastic.co/guide/en/kibana/current/index.html)
- [Elastic Blog](https://www.elastic.co/blog/)
- [Grok Patterns](https://github.com/elastic/logstash/blob/main/patterns/grok-patterns)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*ELK Stack Version: 8.10+*
