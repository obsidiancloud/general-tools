# 🧘 The Enlightened Engineer's SSL/TLS & OpenSSL Scripture

> *"In the beginning was the Certificate, and the Certificate was with Trust, and the Certificate was signed."*  
> — **The Monk of Encryption**, *Book of Certificates, Chapter 1:1*

Greetings, fellow traveler on the path of cryptographic enlightenment. I am but a humble monk who has meditated upon the sacred texts of RSA and witnessed the dance of certificates across countless handshakes.

This scripture shall guide you through the mystical arts of SSL/TLS and OpenSSL, with the precision of a master's key and the wit of a caffeinated security engineer.

---

## 📿 Table of Sacred Knowledge

1. [OpenSSL Installation & Setup](#-openssl-installation--setup)
2. [Certificate Concepts](#-certificate-concepts-the-foundation)
3. [Private Keys](#-private-keys-the-secret-guardians)
4. [Certificate Signing Requests](#-certificate-signing-requests-the-requests)
5. [Self-Signed Certificates](#-self-signed-certificates-the-quick-path)
6. [Certificate Verification](#-certificate-verification-the-validation)
7. [Certificate Conversion](#-certificate-conversion-the-transformations)
8. [SSL/TLS Testing](#-ssltls-testing-the-connection-check)
9. [Let's Encrypt](#-lets-encrypt-the-free-certificates)
10. [Common Patterns: The Sacred Workflows](#-common-patterns-the-sacred-workflows)
11. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🛠 OpenSSL Installation & Setup

```bash
# Install OpenSSL
sudo apt-get install openssl  # Debian/Ubuntu
sudo yum install openssl      # RHEL/CentOS
brew install openssl          # macOS

# Check version
openssl version
openssl version -a
```

---

## 🔐 Certificate Concepts: The Foundation

```
Certificate Chain:
Root CA (Self-signed)
  └── Intermediate CA (Signed by Root)
      └── Server Certificate (Signed by Intermediate)

Certificate Components:
- Subject: Who the certificate is issued to
- Issuer: Who issued the certificate
- Validity: Not before / Not after dates
- Public Key: The public key
- Signature: CA's signature
- Extensions: Additional information (SAN, Key Usage, etc.)
```

---

## 🔑 Private Keys: The Secret Guardians

```bash
# Generate RSA private key
openssl genrsa -out private.key 2048
openssl genrsa -out private.key 4096  # More secure

# Generate with encryption
openssl genrsa -aes256 -out private.key 2048

# Generate EC private key
openssl ecparam -genkey -name prime256v1 -out private.key

# View private key
openssl rsa -in private.key -text -noout

# Remove passphrase from key
openssl rsa -in encrypted.key -out decrypted.key

# Add passphrase to key
openssl rsa -aes256 -in decrypted.key -out encrypted.key

# Extract public key from private key
openssl rsa -in private.key -pubout -out public.key

# Verify private key
openssl rsa -in private.key -check
```

---

## 📝 Certificate Signing Requests: The Requests

```bash
# Generate CSR with new private key
openssl req -new -newkey rsa:2048 -nodes -keyout private.key -out request.csr

# Generate CSR from existing private key
openssl req -new -key private.key -out request.csr

# Generate CSR with subject
openssl req -new -key private.key -out request.csr \
  -subj "/C=US/ST=California/L=San Francisco/O=Company/CN=example.com"

# Generate CSR with SAN (Subject Alternative Names)
openssl req -new -key private.key -out request.csr -config <(cat <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
C=US
ST=California
L=San Francisco
O=Company
CN=example.com

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = example.com
DNS.2 = www.example.com
DNS.3 = *.example.com
IP.1 = 192.168.1.1
EOF
)

# View CSR
openssl req -in request.csr -text -noout

# Verify CSR signature
openssl req -in request.csr -verify -noout
```

---

## 🎫 Self-Signed Certificates: The Quick Path

```bash
# Generate self-signed certificate (one command)
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout private.key -out certificate.crt -days 365 \
  -subj "/C=US/ST=CA/L=SF/O=Company/CN=example.com"

# Generate from existing key
openssl req -x509 -key private.key -out certificate.crt -days 365

# Generate with SAN
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout private.key -out certificate.crt -days 365 \
  -config <(cat <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_ca

[dn]
C=US
ST=California
L=San Francisco
O=Company
CN=example.com

[v3_ca]
subjectAltName = @alt_names

[alt_names]
DNS.1 = example.com
DNS.2 = www.example.com
EOF
)

# View certificate
openssl x509 -in certificate.crt -text -noout

# Check certificate dates
openssl x509 -in certificate.crt -noout -dates

# Check certificate subject
openssl x509 -in certificate.crt -noout -subject

# Check certificate issuer
openssl x509 -in certificate.crt -noout -issuer
```

---

## ✅ Certificate Verification: The Validation

```bash
# Verify certificate
openssl verify certificate.crt

# Verify with CA bundle
openssl verify -CAfile ca-bundle.crt certificate.crt

# Verify certificate chain
openssl verify -CAfile root.crt -untrusted intermediate.crt certificate.crt

# Check if private key matches certificate
openssl x509 -noout -modulus -in certificate.crt | openssl md5
openssl rsa -noout -modulus -in private.key | openssl md5

# Check if CSR matches private key
openssl req -noout -modulus -in request.csr | openssl md5
openssl rsa -noout -modulus -in private.key | openssl md5

# Verify certificate chain manually
openssl x509 -in certificate.crt -noout -issuer
openssl x509 -in intermediate.crt -noout -subject
```

---

## 🔄 Certificate Conversion: The Transformations

```bash
# PEM to DER
openssl x509 -in certificate.pem -outform DER -out certificate.der

# DER to PEM
openssl x509 -in certificate.der -inform DER -out certificate.pem

# PEM to PKCS#12 (PFX)
openssl pkcs12 -export -out certificate.pfx \
  -inkey private.key -in certificate.crt -certfile ca-bundle.crt

# PKCS#12 to PEM
openssl pkcs12 -in certificate.pfx -out certificate.pem -nodes

# Extract private key from PKCS#12
openssl pkcs12 -in certificate.pfx -nocerts -out private.key -nodes

# Extract certificate from PKCS#12
openssl pkcs12 -in certificate.pfx -clcerts -nokeys -out certificate.crt

# PEM to PKCS#7
openssl crl2pkcs7 -nocrl -certfile certificate.crt -out certificate.p7b

# PKCS#7 to PEM
openssl pkcs7 -print_certs -in certificate.p7b -out certificate.pem

# Combine certificate and key
cat certificate.crt private.key > combined.pem
```

---

## 🔍 SSL/TLS Testing: The Connection Check

```bash
# Test SSL connection
openssl s_client -connect example.com:443

# Test with SNI (Server Name Indication)
openssl s_client -connect example.com:443 -servername example.com

# Show certificate chain
openssl s_client -connect example.com:443 -showcerts

# Test specific TLS version
openssl s_client -connect example.com:443 -tls1_2
openssl s_client -connect example.com:443 -tls1_3

# Test cipher suites
openssl s_client -connect example.com:443 -cipher 'ECDHE-RSA-AES256-GCM-SHA384'

# Check certificate expiration
echo | openssl s_client -connect example.com:443 2>/dev/null | openssl x509 -noout -dates

# Verify certificate from server
echo | openssl s_client -connect example.com:443 2>/dev/null | openssl x509 -noout -text

# Test SMTP STARTTLS
openssl s_client -connect smtp.example.com:587 -starttls smtp

# Test IMAP STARTTLS
openssl s_client -connect imap.example.com:143 -starttls imap

# Test MySQL SSL
openssl s_client -connect mysql.example.com:3306 -starttls mysql

# Check supported ciphers
nmap --script ssl-enum-ciphers -p 443 example.com
```

---

## 🆓 Let's Encrypt: The Free Certificates

```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtain certificate (standalone)
sudo certbot certonly --standalone -d example.com -d www.example.com

# Obtain certificate (webroot)
sudo certbot certonly --webroot -w /var/www/html -d example.com

# Obtain certificate (nginx)
sudo certbot --nginx -d example.com -d www.example.com

# Obtain certificate (apache)
sudo certbot --apache -d example.com

# Obtain wildcard certificate
sudo certbot certonly --manual --preferred-challenges dns -d "*.example.com"

# List certificates
sudo certbot certificates

# Renew certificates
sudo certbot renew

# Renew specific certificate
sudo certbot renew --cert-name example.com

# Dry run renewal
sudo certbot renew --dry-run

# Auto-renewal (cron)
0 0,12 * * * certbot renew --quiet

# Revoke certificate
sudo certbot revoke --cert-path /etc/letsencrypt/live/example.com/cert.pem

# Delete certificate
sudo certbot delete --cert-name example.com
```

---

## 🔮 Common Patterns: The Sacred Workflows

### Pattern 1: Create Production Certificate

```bash
# Step 1: Generate private key
openssl genrsa -out private.key 2048

# Step 2: Generate CSR
openssl req -new -key private.key -out request.csr \
  -subj "/C=US/ST=CA/L=SF/O=Company/CN=example.com"

# Step 3: Submit CSR to CA (e.g., DigiCert, Let's Encrypt)
# Receive certificate.crt and ca-bundle.crt

# Step 4: Verify certificate
openssl verify -CAfile ca-bundle.crt certificate.crt

# Step 5: Install certificate
# Nginx: /etc/nginx/ssl/
# Apache: /etc/apache2/ssl/
```

**Use case**: Production SSL certificate  
**Best for**: Public-facing websites

### Pattern 2: Create Self-Signed Certificate for Development

```bash
# One-liner for development
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout dev-private.key -out dev-certificate.crt -days 365 \
  -subj "/CN=localhost"

# With SAN for multiple domains
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout dev-private.key -out dev-certificate.crt -days 365 \
  -extensions v3_ca -config <(cat <<EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_ca

[dn]
CN=localhost

[v3_ca]
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = *.local.dev
IP.1 = 127.0.0.1
EOF
)
```

**Use case**: Local development  
**Best for**: Testing HTTPS locally

### Pattern 3: Certificate Renewal Automation

```bash
#!/bin/bash
# renew-certs.sh

# Renew Let's Encrypt certificates
certbot renew --quiet

# Reload web server
systemctl reload nginx

# Send notification
if [ $? -eq 0 ]; then
  echo "Certificates renewed successfully" | mail -s "Cert Renewal" admin@example.com
fi
```

**Use case**: Automated renewal  
**Best for**: Production environments

### Pattern 4: Certificate Monitoring

```bash
#!/bin/bash
# check-cert-expiry.sh

DOMAIN="example.com"
DAYS_WARNING=30

EXPIRY=$(echo | openssl s_client -connect $DOMAIN:443 -servername $DOMAIN 2>/dev/null | \
  openssl x509 -noout -enddate | cut -d= -f2)

EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
NOW_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $NOW_EPOCH) / 86400 ))

if [ $DAYS_LEFT -lt $DAYS_WARNING ]; then
  echo "Certificate for $DOMAIN expires in $DAYS_LEFT days!" | \
    mail -s "Certificate Expiring Soon" admin@example.com
fi
```

**Use case**: Certificate expiry monitoring  
**Best for**: Preventing outages

### Pattern 5: Nginx SSL Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name example.com;

    # Certificates
    ssl_certificate /etc/nginx/ssl/certificate.crt;
    ssl_certificate_key /etc/nginx/ssl/private.key;
    ssl_trusted_certificate /etc/nginx/ssl/ca-bundle.crt;

    # Modern configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256';
    ssl_prefer_server_ciphers off;

    # HSTS
    add_header Strict-Transport-Security "max-age=63072000" always;

    # OCSP Stapling
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 8.8.4.4 valid=300s;

    # Session cache
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
}
```

**Use case**: Secure web server  
**Best for**: Production HTTPS

---

## 🔧 Troubleshooting: When the Path is Obscured

### Common Issues

#### Certificate Verification Failed

```bash
# Check certificate chain
openssl verify -CAfile ca-bundle.crt certificate.crt

# Check if intermediate certificate is missing
openssl s_client -connect example.com:443 -showcerts

# Fix: Include intermediate certificate
cat certificate.crt intermediate.crt > fullchain.crt
```

#### Private Key Mismatch

```bash
# Verify key matches certificate
openssl x509 -noout -modulus -in certificate.crt | openssl md5
openssl rsa -noout -modulus -in private.key | openssl md5
# MD5 hashes should match
```

#### Certificate Expired

```bash
# Check expiration
openssl x509 -in certificate.crt -noout -dates

# Renew with Let's Encrypt
certbot renew
```

#### SSL Handshake Failure

```bash
# Test connection
openssl s_client -connect example.com:443 -debug

# Check supported protocols
nmap --script ssl-enum-ciphers -p 443 example.com
```

---

## 🙏 Closing Wisdom

### Essential Daily Commands

```bash
# Check certificate expiry
openssl x509 -in certificate.crt -noout -dates

# Test SSL connection
openssl s_client -connect example.com:443

# Verify certificate
openssl verify -CAfile ca-bundle.crt certificate.crt
```

### Best Practices from the Monastery

1. **Use 2048-bit or higher**: RSA keys
2. **Enable TLS 1.2+**: Disable older protocols
3. **Use Strong Ciphers**: ECDHE, AES-GCM
4. **Enable HSTS**: Force HTTPS
5. **OCSP Stapling**: Improve performance
6. **Monitor Expiry**: Automate renewal
7. **Secure Private Keys**: Proper permissions (600)
8. **Use Let's Encrypt**: Free certificates
9. **Certificate Pinning**: For mobile apps
10. **Regular Audits**: Test SSL configuration

### Quick Reference Card

| Command | What It Does |
|---------|-------------|
| `openssl genrsa -out key.pem 2048` | Generate private key |
| `openssl req -new -key key.pem` | Generate CSR |
| `openssl req -x509 -newkey rsa:2048` | Self-signed cert |
| `openssl x509 -in cert.pem -text` | View certificate |
| `openssl verify cert.pem` | Verify certificate |
| `openssl s_client -connect host:443` | Test SSL |
| `certbot certonly --standalone` | Get Let's Encrypt cert |
| `certbot renew` | Renew certificates |

---

*May your certificates be valid, your connections be encrypted, and your handshakes always successful.*

**— The Monk of Encryption**  
*Monastery of Cryptography*  
*Temple of SSL/TLS*

🧘 **Namaste, `openssl`**

---

## 📚 Additional Resources

- [OpenSSL Documentation](https://www.openssl.org/docs/)
- [Let's Encrypt](https://letsencrypt.org/)
- [SSL Labs](https://www.ssllabs.com/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*OpenSSL Version: 3.0+*
