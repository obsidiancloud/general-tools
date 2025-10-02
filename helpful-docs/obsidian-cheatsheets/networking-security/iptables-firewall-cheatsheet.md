# 🧘 The Enlightened Engineer's iptables & Firewall Scripture

> *"In the beginning was the Packet, and the Packet was with iptables, and the Packet was filtered."*  
> — **The Monk of Firewalls**, *Book of Rules, Chapter 1:1*

Greetings, fellow traveler on the path of network security enlightenment. I am but a humble monk who has meditated upon the sacred texts of netfilter and witnessed the dance of packets across countless chains.

This scripture shall guide you through the mystical arts of iptables and firewall management, with the precision of a master's rule and the wit of a caffeinated security engineer.

---

## 📿 Table of Sacred Knowledge

1. [iptables Basics](#-iptables-basics-the-foundation)
2. [Tables & Chains](#-tables--chains-the-structure)
3. [Rule Management](#-rule-management-the-commands)
4. [Match Criteria](#-match-criteria-the-selectors)
5. [Target Actions](#-target-actions-the-decisions)
6. [NAT Configuration](#-nat-configuration-address-translation)
7. [Port Forwarding](#-port-forwarding-the-redirection)
8. [Connection Tracking](#-connection-tracking-stateful-filtering)
9. [Logging](#-logging-the-audit-trail)
10. [Persistence](#-persistence-saving-rules)
11. [Common Patterns: The Sacred Workflows](#-common-patterns-the-sacred-workflows)
12. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🛠 iptables Basics: The Foundation

*Understanding iptables is essential for network security.*

### Installation & Setup

```bash
# Install iptables
sudo apt-get install iptables          # Debian/Ubuntu
sudo yum install iptables-services     # RHEL/CentOS

# Check if iptables is running
sudo iptables -L -v -n

# Check version
iptables --version

# Disable firewalld (if using iptables on RHEL/CentOS)
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl enable iptables
```

### Basic Concepts

```
Packet Flow:
┌─────────────────────────────────────────────────────────┐
│                    Network Interface                     │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │   PREROUTING Chain    │  (NAT, Mangle)
              └───────────────────────┘
                          │
                ┌─────────┴─────────┐
                │                   │
                ▼                   ▼
        ┌──────────────┐    ┌──────────────┐
        │   FORWARD    │    │    INPUT     │  (Filter)
        │    Chain     │    │    Chain     │
        └──────────────┘    └──────────────┘
                │                   │
                │                   ▼
                │           ┌──────────────┐
                │           │ Local Process│
                │           └──────────────┘
                │                   │
                │                   ▼
                │           ┌──────────────┐
                │           │   OUTPUT     │  (Filter)
                │           │   Chain      │
                │           └──────────────┘
                │                   │
                └─────────┬─────────┘
                          ▼
              ┌───────────────────────┐
              │  POSTROUTING Chain    │  (NAT, Mangle)
              └───────────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │   Network Interface   │
              └───────────────────────┘
```

---

## 📋 Tables & Chains: The Structure

*iptables organizes rules into tables and chains.*

### Tables

```bash
# Filter table (default) - packet filtering
# Chains: INPUT, FORWARD, OUTPUT

# NAT table - network address translation
# Chains: PREROUTING, POSTROUTING, OUTPUT

# Mangle table - packet alteration
# Chains: PREROUTING, INPUT, FORWARD, OUTPUT, POSTROUTING

# Raw table - connection tracking exemption
# Chains: PREROUTING, OUTPUT

# Security table - SELinux
# Chains: INPUT, FORWARD, OUTPUT
```

### Chains

```bash
# INPUT - packets destined for local system
# OUTPUT - packets originating from local system
# FORWARD - packets routed through the system
# PREROUTING - packets before routing decision
# POSTROUTING - packets after routing decision
```

### Viewing Rules

```bash
# List all rules
sudo iptables -L

# List with line numbers
sudo iptables -L --line-numbers

# List with verbose output
sudo iptables -L -v

# List without resolving names (faster)
sudo iptables -L -n

# List specific table
sudo iptables -t nat -L
sudo iptables -t mangle -L

# List specific chain
sudo iptables -L INPUT
sudo iptables -L OUTPUT

# List with packet/byte counters
sudo iptables -L -v -n

# Show rules as commands
sudo iptables-save
```

---

## 🔧 Rule Management: The Commands

*Managing rules is the core of firewall administration.*

### Adding Rules

```bash
# Append rule to end of chain
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Insert rule at specific position
sudo iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT

# Insert at position 5
sudo iptables -I INPUT 5 -p tcp --dport 80 -j ACCEPT

# Replace rule at position
sudo iptables -R INPUT 1 -p tcp --dport 22 -j ACCEPT
```

### Deleting Rules

```bash
# Delete by specification
sudo iptables -D INPUT -p tcp --dport 22 -j ACCEPT

# Delete by line number
sudo iptables -D INPUT 3

# Delete all rules in chain
sudo iptables -F INPUT

# Delete all rules in all chains
sudo iptables -F

# Delete all rules in specific table
sudo iptables -t nat -F
```

### Chain Management

```bash
# Create custom chain
sudo iptables -N CUSTOM_CHAIN

# Delete custom chain (must be empty)
sudo iptables -X CUSTOM_CHAIN

# Rename chain
sudo iptables -E OLD_CHAIN NEW_CHAIN

# Set default policy
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Zero counters
sudo iptables -Z
sudo iptables -Z INPUT
```

---

## 🎯 Match Criteria: The Selectors

*Match criteria determine which packets a rule applies to.*

### Basic Matches

```bash
# Protocol
-p tcp          # TCP protocol
-p udp          # UDP protocol
-p icmp         # ICMP protocol
-p all          # All protocols

# Source/Destination IP
-s 192.168.1.100              # Source IP
-s 192.168.1.0/24             # Source network
-d 10.0.0.1                   # Destination IP
-d 10.0.0.0/8                 # Destination network

# Interface
-i eth0         # Input interface
-o eth1         # Output interface

# Invert match
! -s 192.168.1.100            # NOT from this IP
! -p tcp                      # NOT TCP
```

### TCP/UDP Matches

```bash
# Port matching
--sport 1024                  # Source port
--dport 80                    # Destination port
--sport 1024:65535            # Source port range
--dport 80,443                # Multiple ports (requires multiport)

# TCP flags
--tcp-flags SYN,ACK SYN       # SYN flag set, ACK not set
--syn                         # Shorthand for new connections

# Multiport module
-m multiport --sports 80,443,8080
-m multiport --dports 22,80,443
```

### Extended Matches

```bash
# State/Connection tracking
-m state --state NEW,ESTABLISHED,RELATED
-m conntrack --ctstate NEW,ESTABLISHED,RELATED

# Limit rate
-m limit --limit 5/min --limit-burst 10

# Recent connections
-m recent --name SSH --rcheck --seconds 60 --hitcount 4

# MAC address
-m mac --mac-source 00:11:22:33:44:55

# Time-based
-m time --timestart 09:00 --timestop 17:00
-m time --weekdays Mon,Tue,Wed,Thu,Fri

# String matching
-m string --algo bm --string "malicious"

# Owner (OUTPUT chain only)
-m owner --uid-owner 1000
-m owner --gid-owner 1000

# Length
-m length --length 0:500      # Packet length 0-500 bytes

# TTL
-m ttl --ttl-eq 64            # TTL equals 64
-m ttl --ttl-gt 64            # TTL greater than 64
```

---

## 🎬 Target Actions: The Decisions

*Targets determine what happens to matched packets.*

### Basic Targets

```bash
# ACCEPT - allow packet
-j ACCEPT

# DROP - silently discard packet
-j DROP

# REJECT - discard and send error
-j REJECT
-j REJECT --reject-with icmp-port-unreachable
-j REJECT --reject-with icmp-net-unreachable
-j REJECT --reject-with tcp-reset

# RETURN - return to calling chain
-j RETURN
```

### Advanced Targets

```bash
# LOG - log packet
-j LOG --log-prefix "FIREWALL: " --log-level 4

# DNAT - destination NAT
-j DNAT --to-destination 192.168.1.100
-j DNAT --to-destination 192.168.1.100:8080

# SNAT - source NAT
-j SNAT --to-source 203.0.113.1

# MASQUERADE - dynamic SNAT
-j MASQUERADE
-j MASQUERADE --to-ports 1024-65535

# REDIRECT - redirect to local port
-j REDIRECT --to-ports 3128

# MARK - mark packet
-j MARK --set-mark 1

# Custom chain
-j CUSTOM_CHAIN
```

---

## 🔀 NAT Configuration: Address Translation

*NAT translates IP addresses for routing.*

### Source NAT (SNAT)

```bash
# Static SNAT
sudo iptables -t nat -A POSTROUTING -o eth0 -s 192.168.1.0/24 -j SNAT --to-source 203.0.113.1

# MASQUERADE (dynamic SNAT for DHCP)
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# MASQUERADE with port range
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE --to-ports 1024-65535

# Enable IP forwarding (required for NAT)
sudo sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
```

### Destination NAT (DNAT)

```bash
# Port forwarding
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.1.100:8080

# Multiple destinations (load balancing)
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -m statistic --mode random --probability 0.5 -j DNAT --to-destination 192.168.1.100
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.1.101

# REDIRECT to local port
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
```

---

## 🔌 Port Forwarding: The Redirection

*Port forwarding redirects traffic to internal hosts.*

### Basic Port Forwarding

```bash
# Forward external port 80 to internal server port 8080
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.100:8080
sudo iptables -A FORWARD -p tcp -d 192.168.1.100 --dport 8080 -j ACCEPT

# Forward SSH to internal server
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 2222 -j DNAT --to-destination 192.168.1.100:22
sudo iptables -A FORWARD -p tcp -d 192.168.1.100 --dport 22 -j ACCEPT
```

### Port Range Forwarding

```bash
# Forward port range
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 5000:5100 -j DNAT --to-destination 192.168.1.100
sudo iptables -A FORWARD -p tcp -d 192.168.1.100 --dport 5000:5100 -j ACCEPT
```

### Hairpin NAT (Internal Access)

```bash
# Allow internal network to access forwarded services using external IP
sudo iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -d 192.168.1.100 -p tcp --dport 8080 -j MASQUERADE
```

---

## 🔗 Connection Tracking: Stateful Filtering

*Connection tracking enables stateful firewall rules.*

### Connection States

```bash
# NEW - new connection
# ESTABLISHED - existing connection
# RELATED - related to existing connection (e.g., FTP data)
# INVALID - invalid packet

# Allow established and related connections
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow new SSH connections
sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

# Drop invalid packets
sudo iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Using state module (older)
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
```

### Connection Tracking Helpers

```bash
# FTP helper (for FTP data connections)
sudo modprobe nf_conntrack_ftp
sudo iptables -A INPUT -p tcp --dport 21 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -m conntrack --ctstate RELATED -j ACCEPT

# SIP helper (for VoIP)
sudo modprobe nf_conntrack_sip
```

---

## 📝 Logging: The Audit Trail

*Logging helps track and debug firewall activity.*

### Basic Logging

```bash
# Log dropped packets
sudo iptables -A INPUT -j LOG --log-prefix "INPUT DROP: " --log-level 4
sudo iptables -A INPUT -j DROP

# Log accepted packets
sudo iptables -A INPUT -p tcp --dport 22 -j LOG --log-prefix "SSH ACCEPT: "
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Log with rate limiting
sudo iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "FIREWALL: "
```

### Log Levels

```bash
# Log levels (syslog)
--log-level 0  # emerg
--log-level 1  # alert
--log-level 2  # crit
--log-level 3  # err
--log-level 4  # warning (default)
--log-level 5  # notice
--log-level 6  # info
--log-level 7  # debug
```

### Custom Logging Chain

```bash
# Create logging chain
sudo iptables -N LOGGING

# Send packets to logging chain
sudo iptables -A INPUT -j LOGGING

# Log and drop in logging chain
sudo iptables -A LOGGING -m limit --limit 5/min -j LOG --log-prefix "DROPPED: " --log-level 4
sudo iptables -A LOGGING -j DROP
```

### View Logs

```bash
# View firewall logs
sudo tail -f /var/log/syslog | grep FIREWALL
sudo tail -f /var/log/messages | grep FIREWALL
sudo journalctl -f | grep FIREWALL

# View with dmesg
sudo dmesg | grep FIREWALL
```

---

## 💾 Persistence: Saving Rules

*Rules are lost on reboot unless saved.*

### Debian/Ubuntu

```bash
# Install iptables-persistent
sudo apt-get install iptables-persistent

# Save current rules
sudo netfilter-persistent save
sudo iptables-save > /etc/iptables/rules.v4
sudo ip6tables-save > /etc/iptables/rules.v6

# Restore rules
sudo netfilter-persistent reload
sudo iptables-restore < /etc/iptables/rules.v4

# Auto-save on changes
sudo dpkg-reconfigure iptables-persistent
```

### RHEL/CentOS

```bash
# Save rules
sudo service iptables save
sudo iptables-save > /etc/sysconfig/iptables

# Restore rules
sudo service iptables restart
sudo iptables-restore < /etc/sysconfig/iptables

# Enable on boot
sudo systemctl enable iptables
```

### Manual Save/Restore

```bash
# Save to file
sudo iptables-save > /root/iptables.rules

# Restore from file
sudo iptables-restore < /root/iptables.rules

# Backup before changes
sudo iptables-save > /root/iptables.backup.$(date +%Y%m%d-%H%M%S)
```

---

## 🔮 Common Patterns: The Sacred Workflows

*These are the rituals performed by monks in production temples daily.*

### Pattern 1: Basic Server Firewall

```bash
#!/bin/bash
# basic-firewall.sh

# Flush existing rules
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

# Set default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

# Allow HTTP/HTTPS
iptables -A INPUT -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT

# Allow ping
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# Log dropped packets
iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "DROPPED: " --log-level 4

# Save rules
iptables-save > /etc/iptables/rules.v4
```

**Use case**: Basic web server protection  
**Best for**: Simple server deployments

### Pattern 2: SSH Brute Force Protection

```bash
# Create chain for SSH
sudo iptables -N SSH_CHECK

# Send SSH traffic to chain
sudo iptables -A INPUT -p tcp --dport 22 -j SSH_CHECK

# Track SSH attempts
sudo iptables -A SSH_CHECK -m recent --name SSH --set
sudo iptables -A SSH_CHECK -m recent --name SSH --update --seconds 60 --hitcount 4 -j LOG --log-prefix "SSH BRUTE FORCE: "
sudo iptables -A SSH_CHECK -m recent --name SSH --update --seconds 60 --hitcount 4 -j DROP

# Allow SSH if not brute forcing
sudo iptables -A SSH_CHECK -j ACCEPT
```

**Use case**: Protect SSH from brute force  
**Best for**: Internet-facing servers

### Pattern 3: NAT Gateway/Router

```bash
#!/bin/bash
# nat-gateway.sh

# Enable IP forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

# Flush rules
iptables -F
iptables -t nat -F

# Set policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow SSH from internal network
iptables -A INPUT -i eth1 -p tcp --dport 22 -j ACCEPT

# Allow forwarding from internal to external
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT

# NAT for internal network
iptables -t nat -A POSTROUTING -o eth0 -s 192.168.1.0/24 -j MASQUERADE

# Port forwarding (HTTP to internal server)
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.100:80
iptables -A FORWARD -p tcp -d 192.168.1.100 --dport 80 -j ACCEPT

# Save rules
iptables-save > /etc/iptables/rules.v4
```

**Use case**: NAT gateway for private network  
**Best for**: Home/office router

### Pattern 4: Docker Host Firewall

```bash
#!/bin/bash
# docker-firewall.sh

# Flush rules (except Docker chains)
iptables -F INPUT
iptables -F OUTPUT

# Set policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allow SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow Docker published ports
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allow Docker daemon (if remote access needed)
# iptables -A INPUT -p tcp --dport 2376 -s 192.168.1.0/24 -j ACCEPT

# Allow Docker bridge traffic
iptables -A FORWARD -i docker0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o docker0 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Save rules
iptables-save > /etc/iptables/rules.v4
```

**Use case**: Firewall for Docker host  
**Best for**: Containerized applications

### Pattern 5: Rate Limiting Web Server

```bash
#!/bin/bash
# rate-limit-web.sh

# Create chain for rate limiting
iptables -N RATE_LIMIT

# HTTP rate limiting
iptables -A INPUT -p tcp --dport 80 -j RATE_LIMIT
iptables -A RATE_LIMIT -m recent --name HTTP --set
iptables -A RATE_LIMIT -m recent --name HTTP --update --seconds 1 --hitcount 20 -j LOG --log-prefix "HTTP RATE LIMIT: "
iptables -A RATE_LIMIT -m recent --name HTTP --update --seconds 1 --hitcount 20 -j DROP
iptables -A RATE_LIMIT -j ACCEPT

# HTTPS rate limiting
iptables -A INPUT -p tcp --dport 443 -j RATE_LIMIT

# Connection limit per IP
iptables -A INPUT -p tcp --dport 80 -m connlimit --connlimit-above 10 --connlimit-mask 32 -j REJECT --reject-with tcp-reset
iptables -A INPUT -p tcp --dport 443 -m connlimit --connlimit-above 10 --connlimit-mask 32 -j REJECT --reject-with tcp-reset
```

**Use case**: Protect web server from abuse  
**Best for**: High-traffic websites

---

## 🔧 Troubleshooting: When the Path is Obscured

*Even the wisest monks encounter obstacles.*

### Common Issues

#### Rules Not Working

```bash
# Check rule order (first match wins)
sudo iptables -L -n --line-numbers

# Check if packet reaches rule
sudo iptables -L -v -n

# Add logging to debug
sudo iptables -I INPUT 1 -j LOG --log-prefix "DEBUG: "
sudo tail -f /var/log/syslog | grep DEBUG

# Check default policy
sudo iptables -L | grep policy
```

#### Connection Timeout

```bash
# Check if packets are being dropped
sudo iptables -L -v -n | grep DROP

# Check connection tracking
sudo cat /proc/net/nf_conntrack | grep <IP>

# Check if forwarding is enabled
cat /proc/sys/net/ipv4/ip_forward

# Enable forwarding
sudo sysctl -w net.ipv4.ip_forward=1
```

#### NAT Not Working

```bash
# Check NAT table
sudo iptables -t nat -L -v -n

# Check MASQUERADE rule
sudo iptables -t nat -L POSTROUTING -v -n

# Check if packets are being forwarded
sudo iptables -L FORWARD -v -n

# Verify routing
ip route show
```

#### Locked Out After Rule Change

```bash
# Prevention: Set timer to flush rules
(sleep 300 && iptables -F && iptables -P INPUT ACCEPT) &

# Make changes
sudo iptables -P INPUT DROP
# ... add rules ...

# If successful, kill timer
kill %1

# If locked out, wait 5 minutes for auto-recovery
```

#### Performance Issues

```bash
# Check connection tracking table size
sudo cat /proc/sys/net/netfilter/nf_conntrack_count
sudo cat /proc/sys/net/netfilter/nf_conntrack_max

# Increase conntrack table size
sudo sysctl -w net.netfilter.nf_conntrack_max=131072

# Reduce conntrack timeout
sudo sysctl -w net.netfilter.nf_conntrack_tcp_timeout_established=600
```

---

## 🙏 Closing Wisdom

*The path of iptables mastery is endless. These rules are but stepping stones.*

### Essential Daily Commands

```bash
# The monk's morning ritual
sudo iptables -L -v -n
sudo iptables -t nat -L -v -n
sudo tail -100 /var/log/syslog | grep FIREWALL

# The monk's rule change ritual
sudo iptables-save > /root/iptables.backup.$(date +%Y%m%d)
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4

# The monk's evening reflection
sudo iptables -L -v -n --line-numbers
sudo iptables -Z  # Reset counters
```

### Best Practices from the Monastery

1. **Default Deny**: Set INPUT/FORWARD to DROP
2. **Allow Established**: Always allow ESTABLISHED,RELATED
3. **Order Matters**: Specific rules before general
4. **Test Before Save**: Verify rules work
5. **Backup Rules**: Save before changes
6. **Use Logging**: Debug with LOG target
7. **Rate Limiting**: Protect against abuse
8. **Connection Tracking**: Use stateful rules
9. **Document Rules**: Comment complex rules
10. **Regular Audits**: Review rules periodically
11. **Minimal Rules**: Only what's necessary
12. **Persistence**: Save rules for reboot

### Quick Reference Card

| Command | What It Does |
|---------|-------------|
| `iptables -L` | List rules |
| `iptables -A INPUT` | Append rule |
| `iptables -I INPUT 1` | Insert at position |
| `iptables -D INPUT 3` | Delete rule |
| `iptables -F` | Flush all rules |
| `iptables -P INPUT DROP` | Set default policy |
| `iptables-save` | Export rules |
| `iptables-restore` | Import rules |
| `iptables -L -v -n` | List with details |
| `iptables -t nat -L` | List NAT table |

---

*May your packets be filtered, your rules be ordered, and your firewall always secure.*

**— The Monk of Firewalls**  
*Monastery of Network Security*  
*Temple of iptables*

🧘 **Namaste, `iptables`**

---

## 📚 Additional Resources

- [iptables Documentation](https://netfilter.org/documentation/)
- [iptables Tutorial](https://www.frozentux.net/iptables-tutorial/iptables-tutorial.html)
- [Netfilter Project](https://www.netfilter.org/)
- [iptables Man Page](https://linux.die.net/man/8/iptables)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*iptables Version: 1.8+*
