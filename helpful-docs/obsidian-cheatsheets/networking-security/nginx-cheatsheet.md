# 🧘 The Enlightened Engineer's Nginx Scripture

> *"In the beginning was the Request, and the Request was with Nginx, and the Request was proxied."*  
> — **The Monk of Web Servers**, *Book of Reverse Proxy, Chapter 1:1*

Greetings, fellow traveler on the path of web server enlightenment. I am but a humble monk who has meditated upon the sacred texts of Igor Sysoev and witnessed the dance of requests across countless upstream servers.

This scripture shall guide you through the mystical arts of Nginx, with the precision of a master's configuration and the wit of a caffeinated systems administrator.

---

## 📿 Table of Sacred Knowledge

1. [Nginx Installation & Setup](#-nginx-installation--setup)
2. [Configuration Basics](#-configuration-basics-the-foundation)
3. [Virtual Hosts (Server Blocks)](#-virtual-hosts-server-blocks)
4. [Location Blocks](#-location-blocks-the-routing-rules)
5. [Reverse Proxy](#-reverse-proxy-the-gateway)
6. [Load Balancing](#-load-balancing-distributing-the-load)
7. [SSL/TLS Configuration](#-ssltls-configuration-the-secure-path)
8. [Caching](#-caching-the-speed-enhancer)
9. [Rate Limiting](#-rate-limiting-the-traffic-control)
10. [Security Headers](#-security-headers-the-protective-shield)
11. [Logging & Monitoring](#-logging--monitoring-the-watchful-eye)
12. [Common Patterns: The Sacred Workflows](#-common-patterns-the-sacred-workflows)
13. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🛠 Nginx Installation & Setup

*Before serving requests, one must first install the server.*

### Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nginx

# RHEL/CentOS
sudo yum install epel-release
sudo yum install nginx

# macOS
brew install nginx

# From source
wget http://nginx.org/download/nginx-1.24.0.tar.gz
tar -xzf nginx-1.24.0.tar.gz
cd nginx-1.24.0
./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf
make
sudo make install

# Verify installation
nginx -v
nginx -V  # Show compile options
```

### Service Management

```bash
# Start Nginx
sudo systemctl start nginx
sudo service nginx start

# Stop Nginx
sudo systemctl stop nginx

# Restart Nginx
sudo systemctl restart nginx

# Reload configuration (no downtime)
sudo systemctl reload nginx
sudo nginx -s reload

# Enable on boot
sudo systemctl enable nginx

# Check status
sudo systemctl status nginx

# Test configuration
sudo nginx -t
sudo nginx -T  # Test and dump configuration
```

### Directory Structure

```
/etc/nginx/
├── nginx.conf              # Main configuration
├── conf.d/                 # Additional configs
│   └── default.conf
├── sites-available/        # Available sites
│   └── example.com.conf
├── sites-enabled/          # Enabled sites (symlinks)
│   └── example.com.conf -> ../sites-available/example.com.conf
├── snippets/               # Reusable config snippets
│   ├── ssl-params.conf
│   └── proxy-params.conf
├── modules-available/      # Available modules
├── modules-enabled/        # Enabled modules
└── mime.types             # MIME type mappings

/var/log/nginx/
├── access.log             # Access logs
└── error.log              # Error logs

/var/www/html/             # Default web root
└── index.html
```

---

## ⚙️ Configuration Basics: The Foundation

*Understanding the configuration structure is essential.*

### Main Configuration File

```nginx
# /etc/nginx/nginx.conf

user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log warn;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    # Basic Settings
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # Logging
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    # Performance
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    # Gzip Compression
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css text/xml text/javascript 
               application/json application/javascript application/xml+rss 
               application/rss+xml font/truetype font/opentype 
               application/vnd.ms-fontobject image/svg+xml;
    
    # Security
    server_tokens off;
    client_max_body_size 100M;
    
    # Include virtual host configs
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
```

### Configuration Context Hierarchy

```nginx
# Global context
user nginx;
worker_processes auto;

# Events context
events {
    worker_connections 1024;
}

# HTTP context
http {
    # HTTP-level directives
    
    # Server context (virtual host)
    server {
        listen 80;
        server_name example.com;
        
        # Location context (URL matching)
        location / {
            # Location-level directives
        }
        
        location /api {
            # Another location
        }
    }
    
    # Another server block
    server {
        listen 443 ssl;
        server_name secure.example.com;
    }
}
```

---

## 🏠 Virtual Hosts (Server Blocks)

*Server blocks define how to handle different domains.*

### Basic Virtual Host

```nginx
# /etc/nginx/sites-available/example.com.conf

server {
    listen 80;
    listen [::]:80;
    
    server_name example.com www.example.com;
    
    root /var/www/example.com/html;
    index index.html index.htm index.php;
    
    access_log /var/log/nginx/example.com.access.log;
    error_log /var/log/nginx/example.com.error.log;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Multiple Domains

```nginx
# Primary domain
server {
    listen 80;
    server_name example.com www.example.com;
    root /var/www/example.com;
}

# Secondary domain
server {
    listen 80;
    server_name blog.example.com;
    root /var/www/blog;
}

# Catch-all (default server)
server {
    listen 80 default_server;
    server_name _;
    return 444;  # Close connection without response
}
```

### Server Name Matching

```nginx
# Exact match
server_name example.com;

# Wildcard at start
server_name *.example.com;

# Wildcard at end
server_name example.*;

# Regex match
server_name ~^(?<subdomain>.+)\.example\.com$;

# Multiple names
server_name example.com www.example.com blog.example.com;

# IP address
server_name 192.168.1.100;
```

---

## 📍 Location Blocks: The Routing Rules

*Location blocks define how to process different URIs.*

### Location Matching Priority

```nginx
# 1. Exact match (=)
location = /exact {
    # Matches /exact only
}

# 2. Preferential prefix (^~)
location ^~ /images/ {
    # Matches /images/* and stops searching
}

# 3. Regex case-sensitive (~)
location ~ \.php$ {
    # Matches .php files
}

# 4. Regex case-insensitive (~*)
location ~* \.(jpg|jpeg|png|gif)$ {
    # Matches image files (case-insensitive)
}

# 5. Prefix match
location /documents/ {
    # Matches /documents/*
}

# 6. Universal match
location / {
    # Matches everything (fallback)
}
```

### Common Location Patterns

```nginx
# Static files
location /static/ {
    alias /var/www/static/;
    expires 30d;
    add_header Cache-Control "public, immutable";
}

# PHP processing
location ~ \.php$ {
    include snippets/fastcgi-php.conf;
    fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}

# Deny access to hidden files
location ~ /\. {
    deny all;
    access_log off;
    log_not_found off;
}

# Deny access to specific files
location ~* \.(htaccess|htpasswd|ini|log|sh|sql)$ {
    deny all;
}

# Try files pattern
location / {
    try_files $uri $uri/ /index.php?$query_string;
}

# Named location
location / {
    try_files $uri $uri/ @fallback;
}

location @fallback {
    proxy_pass http://backend;
}
```

---

## 🔄 Reverse Proxy: The Gateway

*Nginx excels as a reverse proxy, forwarding requests to backend servers.*

### Basic Reverse Proxy

```nginx
server {
    listen 80;
    server_name api.example.com;
    
    location / {
        proxy_pass http://localhost:3000;
        
        # Proxy headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

### Proxy with Custom Headers

```nginx
location /api/ {
    proxy_pass http://backend:8080/;
    
    # Standard proxy headers
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-Port $server_port;
    
    # Custom headers
    proxy_set_header X-Request-ID $request_id;
    
    # Remove headers
    proxy_set_header Authorization "";
    
    # Buffering
    proxy_buffering on;
    proxy_buffer_size 4k;
    proxy_buffers 8 4k;
    proxy_busy_buffers_size 8k;
    
    # Redirect handling
    proxy_redirect off;
}
```

### WebSocket Proxy

```nginx
location /ws/ {
    proxy_pass http://websocket_backend;
    
    # WebSocket headers
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    
    # Standard headers
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    
    # Timeouts for long-lived connections
    proxy_connect_timeout 7d;
    proxy_send_timeout 7d;
    proxy_read_timeout 7d;
}
```

### Upstream Definition

```nginx
# Define upstream servers
upstream backend {
    server backend1.example.com:8080;
    server backend2.example.com:8080;
    server backend3.example.com:8080;
}

server {
    listen 80;
    
    location / {
        proxy_pass http://backend;
    }
}
```

---

## ⚖️ Load Balancing: Distributing the Load

*Load balancing distributes traffic across multiple servers.*

### Load Balancing Methods

```nginx
# Round Robin (default)
upstream backend {
    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com;
}

# Least Connections
upstream backend {
    least_conn;
    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com;
}

# IP Hash (session persistence)
upstream backend {
    ip_hash;
    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com;
}

# Generic Hash
upstream backend {
    hash $request_uri consistent;
    server backend1.example.com;
    server backend2.example.com;
    server backend3.example.com;
}

# Weighted Round Robin
upstream backend {
    server backend1.example.com weight=3;
    server backend2.example.com weight=2;
    server backend3.example.com weight=1;
}
```

### Server Parameters

```nginx
upstream backend {
    # Active server
    server backend1.example.com:8080 weight=5;
    
    # Backup server (only used when primary servers are down)
    server backend2.example.com:8080 backup;
    
    # Temporarily down
    server backend3.example.com:8080 down;
    
    # Max connections
    server backend4.example.com:8080 max_conns=100;
    
    # Max fails before marking down
    server backend5.example.com:8080 max_fails=3 fail_timeout=30s;
    
    # Slow start (gradually increase traffic)
    server backend6.example.com:8080 slow_start=30s;
}
```

### Health Checks

```nginx
upstream backend {
    server backend1.example.com:8080;
    server backend2.example.com:8080;
    server backend3.example.com:8080;
    
    # Passive health check
    # Mark server as unavailable after 3 failures within 30 seconds
    # Try again after 30 seconds
    server backend1.example.com max_fails=3 fail_timeout=30s;
}

# Active health check (Nginx Plus only)
upstream backend {
    zone backend 64k;
    server backend1.example.com:8080;
    server backend2.example.com:8080;
}

server {
    location / {
        proxy_pass http://backend;
        health_check interval=5s fails=3 passes=2 uri=/health;
    }
}
```

### Keepalive Connections

```nginx
upstream backend {
    server backend1.example.com:8080;
    server backend2.example.com:8080;
    
    # Keep 32 idle connections to each server
    keepalive 32;
    keepalive_timeout 60s;
    keepalive_requests 100;
}

server {
    location / {
        proxy_pass http://backend;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
```

---

## 🔒 SSL/TLS Configuration: The Secure Path

*Secure connections are essential for modern web applications.*

### Basic SSL Configuration

```nginx
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    
    server_name example.com www.example.com;
    
    # SSL certificates
    ssl_certificate /etc/nginx/ssl/example.com.crt;
    ssl_certificate_key /etc/nginx/ssl/example.com.key;
    
    # SSL protocols
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # SSL ciphers
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    
    # SSL session cache
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_session_tickets off;
    
    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/nginx/ssl/ca-bundle.crt;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;
    
    root /var/www/example.com;
    index index.html;
}
```

### HTTP to HTTPS Redirect

```nginx
# Redirect all HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name example.com www.example.com;
    
    return 301 https://$server_name$request_uri;
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name example.com www.example.com;
    
    ssl_certificate /etc/nginx/ssl/example.com.crt;
    ssl_certificate_key /etc/nginx/ssl/example.com.key;
    
    # ... rest of configuration
}
```

### Modern SSL Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    # Certificates
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    
    # Modern configuration (Mozilla SSL Configuration Generator)
    ssl_protocols TLSv1.3;
    ssl_prefer_server_ciphers off;
    
    # HSTS (HTTP Strict Transport Security)
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    
    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_trusted_certificate /etc/letsencrypt/live/example.com/chain.pem;
    
    # Session resumption
    ssl_session_cache shared:SSL:50m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;
    
    # Diffie-Hellman parameter
    ssl_dhparam /etc/nginx/ssl/dhparam.pem;
}
```

### Let's Encrypt Integration

```nginx
# HTTP server for ACME challenge
server {
    listen 80;
    server_name example.com;
    
    # ACME challenge location
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    # Redirect everything else to HTTPS
    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS server
server {
    listen 443 ssl http2;
    server_name example.com;
    
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    
    # ... rest of configuration
}
```

---

## 💾 Caching: The Speed Enhancer

*Caching improves performance by storing responses.*

### Proxy Cache Configuration

```nginx
# Define cache path
http {
    proxy_cache_path /var/cache/nginx/proxy
                     levels=1:2
                     keys_zone=my_cache:10m
                     max_size=1g
                     inactive=60m
                     use_temp_path=off;
    
    server {
        location / {
            proxy_pass http://backend;
            
            # Enable caching
            proxy_cache my_cache;
            
            # Cache key
            proxy_cache_key $scheme$proxy_host$request_uri;
            
            # Cache status codes
            proxy_cache_valid 200 302 10m;
            proxy_cache_valid 404 1m;
            
            # Cache bypass conditions
            proxy_cache_bypass $http_cache_control;
            
            # Add cache status header
            add_header X-Cache-Status $upstream_cache_status;
            
            # Cache lock
            proxy_cache_lock on;
            proxy_cache_lock_timeout 5s;
            
            # Cache revalidation
            proxy_cache_revalidate on;
            
            # Use stale cache
            proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
            proxy_cache_background_update on;
        }
    }
}
```

### Static File Caching

```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
    access_log off;
}

location ~* \.(html|htm)$ {
    expires 1h;
    add_header Cache-Control "public, must-revalidate";
}
```

### FastCGI Cache

```nginx
http {
    fastcgi_cache_path /var/cache/nginx/fastcgi
                       levels=1:2
                       keys_zone=php_cache:10m
                       max_size=1g
                       inactive=60m;
    
    server {
        location ~ \.php$ {
            fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
            fastcgi_cache php_cache;
            fastcgi_cache_key $scheme$request_method$host$request_uri;
            fastcgi_cache_valid 200 60m;
            
            # Skip cache for specific conditions
            set $skip_cache 0;
            
            if ($request_method = POST) {
                set $skip_cache 1;
            }
            
            if ($query_string != "") {
                set $skip_cache 1;
            }
            
            if ($request_uri ~* "/admin/|/cart/|/checkout/") {
                set $skip_cache 1;
            }
            
            fastcgi_cache_bypass $skip_cache;
            fastcgi_no_cache $skip_cache;
            
            add_header X-FastCGI-Cache $upstream_cache_status;
        }
    }
}
```

### Cache Purging

```nginx
# Cache purge location (requires ngx_cache_purge module)
location ~ /purge(/.*) {
    allow 127.0.0.1;
    deny all;
    proxy_cache_purge my_cache $scheme$proxy_host$1;
}

# Usage: curl http://example.com/purge/path/to/resource
```

---

## 🚦 Rate Limiting: The Traffic Control

*Rate limiting protects against abuse and DDoS attacks.*

### Basic Rate Limiting

```nginx
http {
    # Define rate limit zone
    limit_req_zone $binary_remote_addr zone=one:10m rate=10r/s;
    
    server {
        location /api/ {
            # Apply rate limit
            limit_req zone=one burst=20 nodelay;
            
            proxy_pass http://backend;
        }
    }
}
```

### Advanced Rate Limiting

```nginx
http {
    # Rate limit by IP
    limit_req_zone $binary_remote_addr zone=by_ip:10m rate=5r/s;
    
    # Rate limit by server
    limit_req_zone $server_name zone=by_server:10m rate=100r/s;
    
    # Rate limit by custom variable
    limit_req_zone $http_x_api_key zone=by_api_key:10m rate=50r/s;
    
    # Connection limit
    limit_conn_zone $binary_remote_addr zone=conn_limit:10m;
    
    server {
        # Apply multiple rate limits
        location /api/ {
            limit_req zone=by_ip burst=10 nodelay;
            limit_req zone=by_server burst=200;
            limit_conn conn_limit 10;
            
            # Custom error response
            limit_req_status 429;
            limit_conn_status 429;
            
            proxy_pass http://backend;
        }
        
        # Whitelist certain IPs
        location /admin/ {
            # Set variable based on IP
            set $limit_rate 1;
            
            if ($remote_addr = "192.168.1.100") {
                set $limit_rate 0;
            }
            
            limit_req zone=by_ip burst=5 nodelay;
            limit_req_dry_run $limit_rate;
        }
    }
}
```

### Bandwidth Limiting

```nginx
location /downloads/ {
    # Limit bandwidth to 500KB/s per connection
    limit_rate 500k;
    
    # Start limiting after 10MB
    limit_rate_after 10m;
}
```

---

## 🛡️ Security Headers: The Protective Shield

*Security headers protect against common web vulnerabilities.*

### Essential Security Headers

```nginx
server {
    # X-Frame-Options (prevent clickjacking)
    add_header X-Frame-Options "SAMEORIGIN" always;
    
    # X-Content-Type-Options (prevent MIME sniffing)
    add_header X-Content-Type-Options "nosniff" always;
    
    # X-XSS-Protection (XSS filter)
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Referrer-Policy
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # Content-Security-Policy
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self'; frame-ancestors 'self';" always;
    
    # Permissions-Policy (formerly Feature-Policy)
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=()" always;
    
    # HSTS (if using HTTPS)
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
}
```

### Security Configuration Snippet

```nginx
# /etc/nginx/snippets/security-headers.conf

# Security headers
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;

# CSP
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;

# Include in server block
server {
    include snippets/security-headers.conf;
}
```

---

## 📊 Logging & Monitoring: The Watchful Eye

*Proper logging and monitoring are essential for operations.*

### Custom Log Formats

```nginx
http {
    # Extended log format
    log_format extended '$remote_addr - $remote_user [$time_local] '
                       '"$request" $status $body_bytes_sent '
                       '"$http_referer" "$http_user_agent" '
                       '$request_time $upstream_response_time '
                       '$upstream_addr $upstream_status';
    
    # JSON log format
    log_format json_combined escape=json
        '{'
            '"time_local":"$time_local",'
            '"remote_addr":"$remote_addr",'
            '"request":"$request",'
            '"status":$status,'
            '"body_bytes_sent":$body_bytes_sent,'
            '"request_time":$request_time,'
            '"http_referrer":"$http_referer",'
            '"http_user_agent":"$http_user_agent",'
            '"upstream_addr":"$upstream_addr",'
            '"upstream_status":"$upstream_status",'
            '"upstream_response_time":"$upstream_response_time"'
        '}';
    
    # Apply log format
    access_log /var/log/nginx/access.log extended;
    access_log /var/log/nginx/access.json.log json_combined;
}
```

### Conditional Logging

```nginx
# Don't log health checks
map $request_uri $loggable {
    ~^/health$ 0;
    ~^/ping$ 0;
    default 1;
}

server {
    access_log /var/log/nginx/access.log combined if=$loggable;
}

# Log only errors
server {
    access_log /var/log/nginx/access.log combined;
    access_log /var/log/nginx/error_requests.log combined if=$status ~* "^[45]";
}
```

### Monitoring Endpoints

```nginx
# Stub status module
server {
    listen 127.0.0.1:8080;
    
    location /nginx_status {
        stub_status on;
        access_log off;
        allow 127.0.0.1;
        deny all;
    }
}

# Output:
# Active connections: 291
# server accepts handled requests
#  16630948 16630948 31070465
# Reading: 6 Writing: 179 Waiting: 106
```

---

## 🔮 Common Patterns: The Sacred Workflows

*These are the rituals performed by monks in production temples daily.*

### Pattern 1: Modern Web Application

```nginx
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name example.com;
    
    # SSL
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    # Security headers
    include snippets/security-headers.conf;
    
    # Static files
    location /static/ {
        alias /var/www/example.com/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # API proxy
    location /api/ {
        proxy_pass http://backend:3000/;
        include snippets/proxy-params.conf;
        
        # Rate limiting
        limit_req zone=api_limit burst=20 nodelay;
    }
    
    # WebSocket
    location /ws/ {
        proxy_pass http://backend:3000/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    
    # SPA fallback
    location / {
        root /var/www/example.com/dist;
        try_files $uri $uri/ /index.html;
    }
}
```

**Use case**: Modern single-page application  
**Best for**: React/Vue/Angular apps with API backend

### Pattern 2: Microservices Gateway

```nginx
upstream auth_service {
    least_conn;
    server auth1:8080;
    server auth2:8080;
}

upstream user_service {
    least_conn;
    server user1:8081;
    server user2:8081;
}

upstream order_service {
    least_conn;
    server order1:8082;
    server order2:8082;
}

server {
    listen 443 ssl http2;
    server_name api.example.com;
    
    # SSL configuration
    ssl_certificate /etc/nginx/ssl/api.example.com.crt;
    ssl_certificate_key /etc/nginx/ssl/api.example.com.key;
    
    # Auth service
    location /api/auth/ {
        proxy_pass http://auth_service/;
        include snippets/proxy-params.conf;
    }
    
    # User service
    location /api/users/ {
        proxy_pass http://user_service/;
        include snippets/proxy-params.conf;
    }
    
    # Order service
    location /api/orders/ {
        proxy_pass http://order_service/;
        include snippets/proxy-params.conf;
    }
    
    # Health check
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
```

**Use case**: API gateway for microservices  
**Best for**: Microservices architecture

### Pattern 3: High-Performance Static Site

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;
    
    root /var/www/example.com;
    index index.html;
    
    # SSL
    ssl_certificate /etc/nginx/ssl/example.com.crt;
    ssl_certificate_key /etc/nginx/ssl/example.com.key;
    
    # Compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
    
    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # HTML files
    location ~* \.(html|htm)$ {
        expires 1h;
        add_header Cache-Control "public, must-revalidate";
    }
    
    # Security
    location ~ /\. {
        deny all;
    }
    
    # Try files
    location / {
        try_files $uri $uri/ =404;
    }
}
```

**Use case**: Static website hosting  
**Best for**: Hugo/Jekyll/Gatsby sites

### Pattern 4: WordPress Optimization

```nginx
server {
    listen 443 ssl http2;
    server_name wordpress.example.com;
    
    root /var/www/wordpress;
    index index.php;
    
    # SSL configuration
    ssl_certificate /etc/nginx/ssl/wordpress.example.com.crt;
    ssl_certificate_key /etc/nginx/ssl/wordpress.example.com.key;
    
    # Security
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
    
    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }
    
    location ~ /\. {
        deny all;
    }
    
    location ~* /(?:uploads|files)/.*\.php$ {
        deny all;
    }
    
    # Static files
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # WordPress permalinks
    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    
    # PHP processing
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        
        # FastCGI cache
        fastcgi_cache wordpress_cache;
        fastcgi_cache_valid 200 60m;
        fastcgi_cache_bypass $skip_cache;
        fastcgi_no_cache $skip_cache;
        add_header X-FastCGI-Cache $upstream_cache_status;
    }
    
    # Skip cache for admin/login
    set $skip_cache 0;
    
    if ($request_uri ~* "/wp-admin/|/xmlrpc.php|wp-.*.php|/feed/|index.php|sitemap(_index)?.xml") {
        set $skip_cache 1;
    }
    
    if ($http_cookie ~* "comment_author|wordpress_[a-f0-9]+|wp-postpass|wordpress_no_cache|wordpress_logged_in") {
        set $skip_cache 1;
    }
}
```

**Use case**: WordPress hosting  
**Best for**: High-traffic WordPress sites

### Pattern 5: Docker Container Proxy

```nginx
# docker-compose.yml integration
upstream app {
    server app:3000;
}

server {
    listen 80;
    server_name localhost;
    
    location / {
        proxy_pass http://app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Use case**: Docker container proxy  
**Best for**: Containerized applications

---

## 🔧 Troubleshooting: When the Path is Obscured

*Even the wisest monks encounter obstacles.*

### Common Issues

#### Configuration Test Fails

```bash
# Test configuration
sudo nginx -t

# Common errors:
# - Missing semicolon
# - Unclosed bracket
# - Invalid directive
# - Duplicate server_name

# View detailed error
sudo nginx -t 2>&1 | grep error
```

#### 502 Bad Gateway

```bash
# Check upstream server
curl http://backend:3000

# Check Nginx error log
sudo tail -f /var/log/nginx/error.log

# Common causes:
# - Backend server down
# - Firewall blocking connection
# - SELinux blocking (RHEL/CentOS)
# - Wrong upstream address

# Fix SELinux issue
sudo setsebool -P httpd_can_network_connect 1
```

#### 413 Request Entity Too Large

```nginx
# Increase client body size
http {
    client_max_body_size 100M;
}

# Or in server/location block
server {
    client_max_body_size 100M;
}
```

#### Slow Response Times

```bash
# Check upstream response time
tail -f /var/log/nginx/access.log | grep -oP 'upstream_response_time=\K[0-9.]+'

# Enable slow log
error_log /var/log/nginx/error.log warn;

# Check for:
# - Slow backend
# - No keepalive connections
# - DNS resolution issues
# - No caching
```

#### SSL Certificate Issues

```bash
# Test SSL
openssl s_client -connect example.com:443 -servername example.com

# Check certificate
sudo nginx -t
sudo systemctl reload nginx

# Common issues:
# - Wrong certificate path
# - Missing intermediate certificate
# - Certificate expired
# - Private key mismatch
```

---

## 🙏 Closing Wisdom

*The path of Nginx mastery is endless. These configurations are but stepping stones.*

### Essential Daily Commands

```bash
# The monk's morning ritual
sudo nginx -t
sudo systemctl status nginx
sudo tail -f /var/log/nginx/error.log

# The monk's deployment ritual
sudo nginx -t
sudo systemctl reload nginx
curl -I https://example.com

# The monk's evening reflection
sudo tail -100 /var/log/nginx/access.log
sudo tail -100 /var/log/nginx/error.log
```

### Best Practices from the Monastery

1. **Test Before Reload**: Always `nginx -t` before reload
2. **Use Includes**: Organize configs with includes
3. **Enable HTTP/2**: Better performance
4. **Implement Caching**: Reduce backend load
5. **Rate Limiting**: Protect against abuse
6. **Security Headers**: Protect users
7. **Monitor Logs**: Watch for errors
8. **Use Upstream**: Define backend servers
9. **SSL Best Practices**: Modern TLS only
10. **Compression**: Enable gzip
11. **Static File Optimization**: Long cache times
12. **Regular Updates**: Keep Nginx updated

### Quick Reference Card

| Command | What It Does |
|---------|-------------|
| `nginx -t` | Test configuration |
| `nginx -s reload` | Reload config |
| `systemctl restart nginx` | Restart Nginx |
| `nginx -V` | Show compile options |
| `nginx -T` | Dump configuration |
| `tail -f /var/log/nginx/error.log` | Watch error log |
| `curl -I http://example.com` | Test response |

---

*May your configurations be valid, your upstreams be healthy, and your requests always proxied.*

**— The Monk of Web Servers**  
*Monastery of Reverse Proxy*  
*Temple of Nginx*

🧘 **Namaste, `nginx`**

---

## 📚 Additional Resources

- [Official Nginx Documentation](https://nginx.org/en/docs/)
- [Nginx Admin Guide](https://docs.nginx.com/nginx/admin-guide/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
- [Nginx Config](https://www.nginxconfig.io/)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*Nginx Version: 1.24+*
