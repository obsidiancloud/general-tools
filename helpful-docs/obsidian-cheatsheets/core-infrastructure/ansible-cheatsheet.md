# 🧘 The Enlightened Engineer's Ansible Scripture

> *"In the beginning was the Playbook, and the Playbook was with Ansible, and the Playbook was idempotent."*  
> — **The Monk of Automation**, *Book of Configuration, Chapter 1:1*

Greetings, fellow traveler on the path of automation enlightenment. I am but a humble monk who has meditated upon the sacred texts of Red Hat and witnessed the dance of tasks across countless hosts.

This scripture shall guide you through the mystical arts of Ansible, with the precision of a master's YAML and the wit of a caffeinated systems administrator.

---

## 📿 Table of Sacred Knowledge

1. [Ansible Installation & Setup](#-ansible-installation--setup)
2. [Inventory Management](#-inventory-management-knowing-your-hosts)
3. [Ad-Hoc Commands](#-ad-hoc-commands-quick-strikes)
4. [Playbooks](#-playbooks-the-orchestrated-dance)
5. [Variables & Facts](#-variables--facts-the-data-realm)
6. [Modules](#-modules-the-building-blocks)
7. [Conditionals & Loops](#-conditionals--loops-the-logic-flow)
8. [Handlers](#-handlers-the-triggered-actions)
9. [Roles](#-roles-the-reusable-patterns)
10. [Ansible Vault](#-ansible-vault-the-secret-keeper)
11. [Collections & Galaxy](#-collections--galaxy-the-shared-wisdom)
12. [Common Patterns: The Sacred Workflows](#-common-patterns-the-sacred-workflows)
13. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🛠 Ansible Installation & Setup

*Before automating hosts, one must first install the tools.*

### Installation

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ansible

# RHEL/CentOS
sudo yum install ansible

# macOS
brew install ansible

# Python pip (any OS)
pip install ansible

# Verify installation
ansible --version
ansible-playbook --version
```

### Configuration

```bash
# Create ansible.cfg
cat > ansible.cfg <<EOF
[defaults]
inventory = ./inventory
host_key_checking = False
retry_files_enabled = False
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/ansible_facts
fact_caching_timeout = 86400
stdout_callback = yaml
callbacks_enabled = timer, profile_tasks

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[ssh_connection]
pipelining = True
control_path = /tmp/ansible-ssh-%%h-%%p-%%r
EOF
```

### Essential Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc
alias ap='ansible-playbook'
alias a='ansible'
alias ag='ansible-galaxy'
alias av='ansible-vault'
alias ai='ansible-inventory'
alias ad='ansible-doc'
```

---

## 📋 Inventory Management: Knowing Your Hosts

*Before commanding hosts, one must first know them.*

### Static Inventory

```ini
# inventory/hosts
[webservers]
web1.example.com
web2.example.com
web3.example.com

[databases]
db1.example.com ansible_host=192.168.1.10
db2.example.com ansible_host=192.168.1.11

[loadbalancers]
lb1.example.com

[production:children]
webservers
databases
loadbalancers

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### YAML Inventory

```yaml
# inventory/hosts.yml
all:
  children:
    webservers:
      hosts:
        web1.example.com:
        web2.example.com:
        web3.example.com:
      vars:
        http_port: 80
        
    databases:
      hosts:
        db1.example.com:
          ansible_host: 192.168.1.10
        db2.example.com:
          ansible_host: 192.168.1.11
      vars:
        db_port: 5432
        
    production:
      children:
        webservers:
        databases:
      vars:
        env: production
```

### Dynamic Inventory

```bash
# AWS EC2 dynamic inventory
ansible-inventory -i aws_ec2.yml --list

# aws_ec2.yml
plugin: aws_ec2
regions:
  - us-east-1
  - us-west-2
filters:
  tag:Environment: production
keyed_groups:
  - key: tags.Role
    prefix: role
  - key: placement.region
    prefix: region
```

### Inventory Commands

```bash
# List inventory
ansible-inventory --list
ansible-inventory --graph

# List specific group
ansible-inventory --list --limit webservers

# Show host variables
ansible-inventory --host web1.example.com
```

---

## ⚡ Ad-Hoc Commands: Quick Strikes

*Sometimes a single command is all you need.*

### Basic Ad-Hoc Commands

```bash
# Ping all hosts
ansible all -m ping

# Ping specific group
ansible webservers -m ping

# Run shell command
ansible all -m shell -a "uptime"
ansible webservers -m shell -a "df -h"

# Run command as sudo
ansible all -m shell -a "systemctl status nginx" --become

# Copy file
ansible webservers -m copy -a "src=/tmp/file.txt dest=/tmp/file.txt"

# Install package
ansible webservers -m apt -a "name=nginx state=present" --become

# Restart service
ansible webservers -m service -a "name=nginx state=restarted" --become

# Gather facts
ansible all -m setup
ansible all -m setup -a "filter=ansible_distribution*"
```

### Advanced Ad-Hoc Commands

```bash
# Run command on specific hosts
ansible web1.example.com,web2.example.com -m shell -a "hostname"

# Use pattern matching
ansible "web*" -m ping
ansible "~web[0-9]" -m ping

# Limit to subset
ansible all -m ping --limit webservers
ansible all -m ping --limit "webservers:&production"

# Parallel execution
ansible all -m ping -f 10  # 10 forks

# Check mode (dry run)
ansible all -m apt -a "name=nginx state=present" --check

# Diff mode
ansible all -m copy -a "src=file.txt dest=/tmp/file.txt" --diff
```

---

## 📜 Playbooks: The Orchestrated Dance

*Playbooks are the heart of Ansible, declarative and powerful.*

### Basic Playbook

```yaml
# playbook.yml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present
        update_cache: yes
    
    - name: Start nginx service
      service:
        name: nginx
        state: started
        enabled: yes
    
    - name: Copy website files
      copy:
        src: ./website/
        dest: /var/www/html/
        owner: www-data
        group: www-data
        mode: '0644'
```

### Running Playbooks

```bash
# Run playbook
ansible-playbook playbook.yml

# Check syntax
ansible-playbook playbook.yml --syntax-check

# Dry run
ansible-playbook playbook.yml --check

# Show diff
ansible-playbook playbook.yml --diff

# Limit to hosts
ansible-playbook playbook.yml --limit webservers

# Start at task
ansible-playbook playbook.yml --start-at-task="Install nginx"

# Use tags
ansible-playbook playbook.yml --tags "install,configure"
ansible-playbook playbook.yml --skip-tags "deploy"

# Verbose output
ansible-playbook playbook.yml -v
ansible-playbook playbook.yml -vvv  # Very verbose
```

### Multi-Play Playbook

```yaml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  tasks:
    - name: Install nginx
      apt:
        name: nginx
        state: present

- name: Configure databases
  hosts: databases
  become: yes
  tasks:
    - name: Install PostgreSQL
      apt:
        name: postgresql
        state: present

- name: Configure load balancers
  hosts: loadbalancers
  become: yes
  tasks:
    - name: Install HAProxy
      apt:
        name: haproxy
        state: present
```

---

## 🔢 Variables & Facts: The Data Realm

*Variables bring flexibility, facts reveal truth.*

### Variable Definition

```yaml
# In playbook
---
- name: Deploy application
  hosts: webservers
  vars:
    app_name: myapp
    app_version: 1.0.0
    http_port: 8080
  
  tasks:
    - name: Print variables
      debug:
        msg: "Deploying {{ app_name }} version {{ app_version }} on port {{ http_port }}"
```

### Variable Files

```yaml
# vars/main.yml
app_name: myapp
app_version: 1.0.0
http_port: 8080
db_host: db.example.com
db_port: 5432

# Use in playbook
---
- name: Deploy application
  hosts: webservers
  vars_files:
    - vars/main.yml
  
  tasks:
    - name: Deploy app
      debug:
        msg: "Deploying {{ app_name }}"
```

### Host/Group Variables

```yaml
# inventory/host_vars/web1.example.com.yml
http_port: 8080
app_instances: 2

# inventory/group_vars/webservers.yml
http_port: 80
max_connections: 1000
keepalive_timeout: 65

# inventory/group_vars/all.yml
ntp_server: pool.ntp.org
timezone: America/New_York
```

### Facts

```yaml
# Gather facts
- name: Show facts
  hosts: all
  tasks:
    - name: Print OS family
      debug:
        msg: "OS: {{ ansible_distribution }} {{ ansible_distribution_version }}"
    
    - name: Print IP address
      debug:
        msg: "IP: {{ ansible_default_ipv4.address }}"
    
    - name: Print memory
      debug:
        msg: "Memory: {{ ansible_memtotal_mb }} MB"

# Disable fact gathering
- name: Quick playbook
  hosts: all
  gather_facts: no
  tasks:
    - name: Do something
      debug:
        msg: "No facts needed"
```

### Variable Precedence

```yaml
# From lowest to highest precedence:
# 1. role defaults
# 2. inventory file/script group vars
# 3. inventory group_vars/all
# 4. playbook group_vars/all
# 5. inventory group_vars/*
# 6. playbook group_vars/*
# 7. inventory file/script host vars
# 8. inventory host_vars/*
# 9. playbook host_vars/*
# 10. host facts
# 11. play vars
# 12. play vars_prompt
# 13. play vars_files
# 14. role vars
# 15. block vars
# 16. task vars
# 17. include_vars
# 18. set_facts / registered vars
# 19. role (and include_role) params
# 20. include params
# 21. extra vars (always win) -e
```

---

## 🧩 Modules: The Building Blocks

*Modules are the actions Ansible performs.*

### Common Modules

```yaml
# Package management
- name: Install package (apt)
  apt:
    name: nginx
    state: present
    update_cache: yes

- name: Install package (yum)
  yum:
    name: nginx
    state: present

- name: Install multiple packages
  apt:
    name:
      - nginx
      - git
      - curl
    state: present

# Service management
- name: Start service
  service:
    name: nginx
    state: started
    enabled: yes

- name: Restart service
  service:
    name: nginx
    state: restarted

# File operations
- name: Create directory
  file:
    path: /opt/myapp
    state: directory
    owner: www-data
    group: www-data
    mode: '0755'

- name: Create file
  file:
    path: /tmp/myfile
    state: touch
    mode: '0644'

- name: Remove file
  file:
    path: /tmp/myfile
    state: absent

# Copy files
- name: Copy file
  copy:
    src: files/config.conf
    dest: /etc/myapp/config.conf
    owner: root
    group: root
    mode: '0644'
    backup: yes

# Template files
- name: Template configuration
  template:
    src: templates/nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: '0644'
  notify: restart nginx

# Shell commands
- name: Run shell command
  shell: |
    cd /opt/myapp
    ./deploy.sh
  args:
    creates: /opt/myapp/deployed

- name: Run command
  command: /usr/bin/make install
  args:
    chdir: /opt/myapp

# Git operations
- name: Clone repository
  git:
    repo: https://github.com/user/repo.git
    dest: /opt/myapp
    version: main
    force: yes

# User management
- name: Create user
  user:
    name: appuser
    shell: /bin/bash
    groups: sudo
    append: yes
    create_home: yes

# Archive operations
- name: Extract archive
  unarchive:
    src: /tmp/archive.tar.gz
    dest: /opt/myapp
    remote_src: yes

# Download files
- name: Download file
  get_url:
    url: https://example.com/file.tar.gz
    dest: /tmp/file.tar.gz
    mode: '0644'

# Line in file
- name: Add line to file
  lineinfile:
    path: /etc/hosts
    line: "192.168.1.10 db.example.com"
    state: present

# Block in file
- name: Add block to file
  blockinfile:
    path: /etc/ssh/sshd_config
    block: |
      PermitRootLogin no
      PasswordAuthentication no
```

---

## 🔀 Conditionals & Loops: The Logic Flow

*Control the flow of execution with wisdom.*

### Conditionals

```yaml
# Simple when
- name: Install nginx on Debian
  apt:
    name: nginx
    state: present
  when: ansible_os_family == "Debian"

- name: Install nginx on RedHat
  yum:
    name: nginx
    state: present
  when: ansible_os_family == "RedHat"

# Multiple conditions (AND)
- name: Install on Ubuntu 20.04
  apt:
    name: nginx
    state: present
  when:
    - ansible_distribution == "Ubuntu"
    - ansible_distribution_version == "20.04"

# Multiple conditions (OR)
- name: Install on Debian or Ubuntu
  apt:
    name: nginx
    state: present
  when: ansible_distribution == "Debian" or ansible_distribution == "Ubuntu"

# Check variable defined
- name: Do something if variable exists
  debug:
    msg: "Variable is defined"
  when: my_var is defined

# Check variable value
- name: Do something in production
  debug:
    msg: "Production environment"
  when: environment == "production"

# Register and check result
- name: Check if file exists
  stat:
    path: /etc/myapp/config.conf
  register: config_file

- name: Create config if not exists
  copy:
    src: config.conf
    dest: /etc/myapp/config.conf
  when: not config_file.stat.exists
```

### Loops

```yaml
# Simple loop
- name: Install packages
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - nginx
    - git
    - curl

# Loop with dict
- name: Create users
  user:
    name: "{{ item.name }}"
    groups: "{{ item.groups }}"
    state: present
  loop:
    - { name: 'alice', groups: 'sudo' }
    - { name: 'bob', groups: 'developers' }
    - { name: 'charlie', groups: 'operators' }

# Loop over dict
- name: Set file permissions
  file:
    path: "{{ item.key }}"
    mode: "{{ item.value }}"
  loop: "{{ files | dict2items }}"
  vars:
    files:
      /tmp/file1: '0644'
      /tmp/file2: '0755'

# Loop with index
- name: Create numbered files
  file:
    path: "/tmp/file{{ item }}"
    state: touch
  loop: "{{ range(1, 6) | list }}"

# Loop with register
- name: Check services
  service:
    name: "{{ item }}"
    state: started
  loop:
    - nginx
    - postgresql
  register: service_status

- name: Show service status
  debug:
    msg: "{{ item.name }} is {{ item.state }}"
  loop: "{{ service_status.results }}"

# Loop until
- name: Wait for service
  uri:
    url: http://localhost:8080/health
  register: result
  until: result.status == 200
  retries: 10
  delay: 5
```

---

## 🔔 Handlers: The Triggered Actions

*Handlers run when notified, like bells ringing.*

### Basic Handlers

```yaml
---
- name: Configure web server
  hosts: webservers
  become: yes
  
  tasks:
    - name: Copy nginx config
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
      notify: restart nginx
    
    - name: Copy site config
      template:
        src: site.conf.j2
        dest: /etc/nginx/sites-available/default
      notify:
        - reload nginx
        - clear cache
  
  handlers:
    - name: restart nginx
      service:
        name: nginx
        state: restarted
    
    - name: reload nginx
      service:
        name: nginx
        state: reloaded
    
    - name: clear cache
      shell: rm -rf /var/cache/nginx/*
```

### Handler Features

```yaml
# Listen to multiple notifications
handlers:
  - name: restart web services
    service:
      name: "{{ item }}"
      state: restarted
    loop:
      - nginx
      - php-fpm
    listen: "restart web"

# Use in task
tasks:
  - name: Update config
    template:
      src: config.j2
      dest: /etc/config
    notify: restart web

# Force handler execution
- name: Force handlers
  meta: flush_handlers
```

---

## 📦 Roles: The Reusable Patterns

*Roles organize playbooks into reusable components.*

### Role Structure

```
roles/
└── webserver/
    ├── tasks/
    │   └── main.yml
    ├── handlers/
    │   └── main.yml
    ├── templates/
    │   └── nginx.conf.j2
    ├── files/
    │   └── index.html
    ├── vars/
    │   └── main.yml
    ├── defaults/
    │   └── main.yml
    ├── meta/
    │   └── main.yml
    └── README.md
```

### Creating a Role

```bash
# Create role structure
ansible-galaxy init webserver

# Role files
# roles/webserver/tasks/main.yml
---
- name: Install nginx
  apt:
    name: nginx
    state: present
    update_cache: yes

- name: Copy nginx config
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
  notify: restart nginx

- name: Start nginx
  service:
    name: nginx
    state: started
    enabled: yes

# roles/webserver/handlers/main.yml
---
- name: restart nginx
  service:
    name: nginx
    state: restarted

# roles/webserver/defaults/main.yml
---
http_port: 80
worker_processes: auto
worker_connections: 1024

# roles/webserver/vars/main.yml
---
nginx_user: www-data
nginx_group: www-data
```

### Using Roles

```yaml
# playbook.yml
---
- name: Configure web servers
  hosts: webservers
  become: yes
  
  roles:
    - webserver
    - { role: database, db_name: myapp }
    - role: monitoring
      vars:
        monitoring_port: 9090

# With tags
- name: Configure servers
  hosts: all
  roles:
    - { role: common, tags: ['common'] }
    - { role: webserver, tags: ['web'] }

# Conditional role
- name: Configure servers
  hosts: all
  roles:
    - role: webserver
      when: "'webservers' in group_names"
```

### Role Dependencies

```yaml
# roles/webserver/meta/main.yml
---
dependencies:
  - role: common
    vars:
      ntp_server: pool.ntp.org
  - role: firewall
    vars:
      allowed_ports:
        - 80
        - 443
```

---

## 🔐 Ansible Vault: The Secret Keeper

*Secrets must be encrypted, never exposed.*

### Vault Operations

```bash
# Create encrypted file
ansible-vault create secrets.yml

# Edit encrypted file
ansible-vault edit secrets.yml

# Encrypt existing file
ansible-vault encrypt vars/secrets.yml

# Decrypt file
ansible-vault decrypt vars/secrets.yml

# View encrypted file
ansible-vault view secrets.yml

# Rekey (change password)
ansible-vault rekey secrets.yml

# Encrypt string
ansible-vault encrypt_string 'secret_password' --name 'db_password'
```

### Using Vault in Playbooks

```yaml
# secrets.yml (encrypted)
db_password: supersecret
api_key: abc123xyz

# playbook.yml
---
- name: Deploy application
  hosts: webservers
  vars_files:
    - secrets.yml
  
  tasks:
    - name: Configure database
      template:
        src: db_config.j2
        dest: /etc/myapp/db.conf
```

### Running with Vault

```bash
# Prompt for password
ansible-playbook playbook.yml --ask-vault-pass

# Use password file
ansible-playbook playbook.yml --vault-password-file ~/.vault_pass

# Use script
ansible-playbook playbook.yml --vault-password-file vault_pass.sh

# Multiple vault IDs
ansible-playbook playbook.yml --vault-id dev@prompt --vault-id prod@~/.vault_pass_prod
```

---

## 🌌 Collections & Galaxy: The Shared Wisdom

*Collections package roles, modules, and plugins.*

### Ansible Galaxy

```bash
# Install role from Galaxy
ansible-galaxy install geerlingguy.nginx

# Install specific version
ansible-galaxy install geerlingguy.nginx,2.8.0

# Install from requirements
ansible-galaxy install -r requirements.yml

# List installed roles
ansible-galaxy list

# Remove role
ansible-galaxy remove geerlingguy.nginx

# Search Galaxy
ansible-galaxy search nginx
```

### Requirements File

```yaml
# requirements.yml
---
# Roles from Galaxy
- name: geerlingguy.nginx
  version: 2.8.0

- name: geerlingguy.postgresql
  version: 3.3.0

# Roles from Git
- src: https://github.com/user/ansible-role-myapp.git
  version: main
  name: myapp

# Collections
collections:
  - name: community.general
    version: 5.0.0
  
  - name: ansible.posix
    version: 1.4.0
```

### Collections

```bash
# Install collection
ansible-galaxy collection install community.general

# Install from requirements
ansible-galaxy collection install -r requirements.yml

# List collections
ansible-galaxy collection list

# Use collection in playbook
---
- name: Use collection
  hosts: all
  tasks:
    - name: Use module from collection
      community.general.docker_container:
        name: myapp
        image: nginx
        state: started
```

---

## 🔮 Common Patterns: The Sacred Workflows

*These are the rituals performed by monks in production temples daily.*

### Pattern 1: Server Provisioning

```yaml
---
- name: Provision new servers
  hosts: new_servers
  become: yes
  
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes
        cache_valid_time: 3600
    
    - name: Upgrade all packages
      apt:
        upgrade: dist
    
    - name: Install base packages
      apt:
        name:
          - vim
          - git
          - curl
          - htop
          - ufw
        state: present
    
    - name: Create admin user
      user:
        name: admin
        groups: sudo
        shell: /bin/bash
        create_home: yes
    
    - name: Add SSH key
      authorized_key:
        user: admin
        key: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"
    
    - name: Configure firewall
      ufw:
        rule: allow
        port: "{{ item }}"
      loop:
        - 22
        - 80
        - 443
    
    - name: Enable firewall
      ufw:
        state: enabled
    
    - name: Set timezone
      timezone:
        name: America/New_York
```

**Use case**: Initial server setup  
**Best for**: New server deployment

### Pattern 2: Application Deployment

```yaml
---
- name: Deploy application
  hosts: webservers
  become: yes
  
  vars:
    app_name: myapp
    app_version: "{{ lookup('env', 'APP_VERSION') | default('latest') }}"
    app_path: /opt/{{ app_name }}
  
  tasks:
    - name: Stop application
      systemd:
        name: "{{ app_name }}"
        state: stopped
      ignore_errors: yes
    
    - name: Create backup
      archive:
        path: "{{ app_path }}"
        dest: "/tmp/{{ app_name }}-backup-{{ ansible_date_time.epoch }}.tar.gz"
      when: app_path is directory
    
    - name: Clone repository
      git:
        repo: "https://github.com/user/{{ app_name }}.git"
        dest: "{{ app_path }}"
        version: "{{ app_version }}"
        force: yes
    
    - name: Install dependencies
      pip:
        requirements: "{{ app_path }}/requirements.txt"
        virtualenv: "{{ app_path }}/venv"
    
    - name: Copy configuration
      template:
        src: config.j2
        dest: "{{ app_path }}/config.py"
      notify: restart application
    
    - name: Run database migrations
      shell: |
        source venv/bin/activate
        python manage.py migrate
      args:
        chdir: "{{ app_path }}"
    
    - name: Start application
      systemd:
        name: "{{ app_name }}"
        state: started
        enabled: yes
  
  handlers:
    - name: restart application
      systemd:
        name: "{{ app_name }}"
        state: restarted
```

**Use case**: Zero-downtime deployment  
**Best for**: Production application updates

### Pattern 3: Rolling Updates

```yaml
---
- name: Rolling update
  hosts: webservers
  serial: 1  # One host at a time
  max_fail_percentage: 0
  become: yes
  
  pre_tasks:
    - name: Remove from load balancer
      haproxy:
        state: disabled
        host: "{{ inventory_hostname }}"
        backend: web_backend
      delegate_to: "{{ item }}"
      loop: "{{ groups['loadbalancers'] }}"
  
  tasks:
    - name: Update application
      git:
        repo: https://github.com/user/myapp.git
        dest: /opt/myapp
        version: main
        force: yes
    
    - name: Restart service
      systemd:
        name: myapp
        state: restarted
    
    - name: Wait for service
      wait_for:
        port: 8080
        delay: 5
        timeout: 60
    
    - name: Health check
      uri:
        url: "http://{{ inventory_hostname }}:8080/health"
        status_code: 200
      register: result
      until: result.status == 200
      retries: 5
      delay: 10
  
  post_tasks:
    - name: Add to load balancer
      haproxy:
        state: enabled
        host: "{{ inventory_hostname }}"
        backend: web_backend
      delegate_to: "{{ item }}"
      loop: "{{ groups['loadbalancers'] }}"
```

**Use case**: Zero-downtime updates  
**Best for**: High-availability deployments

### Pattern 4: Configuration Management

```yaml
---
- name: Manage configuration
  hosts: all
  become: yes
  
  tasks:
    - name: Ensure configuration directory
      file:
        path: /etc/myapp
        state: directory
        mode: '0755'
    
    - name: Template main config
      template:
        src: templates/config.j2
        dest: /etc/myapp/config.yml
        validate: '/usr/bin/myapp validate %s'
      notify: reload application
    
    - name: Ensure log directory
      file:
        path: /var/log/myapp
        state: directory
        owner: myapp
        group: myapp
        mode: '0755'
    
    - name: Configure logrotate
      template:
        src: templates/logrotate.j2
        dest: /etc/logrotate.d/myapp
    
    - name: Set kernel parameters
      sysctl:
        name: "{{ item.key }}"
        value: "{{ item.value }}"
        state: present
        reload: yes
      loop:
        - { key: 'net.ipv4.tcp_fin_timeout', value: '30' }
        - { key: 'net.core.somaxconn', value: '1024' }
  
  handlers:
    - name: reload application
      systemd:
        name: myapp
        state: reloaded
```

**Use case**: Consistent configuration  
**Best for**: Configuration drift prevention

### Pattern 5: Secrets Rotation

```yaml
---
- name: Rotate secrets
  hosts: all
  become: yes
  vars_files:
    - vault/secrets.yml
  
  tasks:
    - name: Generate new password
      set_fact:
        new_password: "{{ lookup('password', '/dev/null length=32 chars=ascii_letters,digits') }}"
      run_once: yes
      delegate_to: localhost
    
    - name: Update database password
      postgresql_user:
        name: appuser
        password: "{{ new_password }}"
      delegate_to: "{{ groups['databases'][0] }}"
      run_once: yes
    
    - name: Update application config
      lineinfile:
        path: /etc/myapp/config.yml
        regexp: '^db_password:'
        line: "db_password: {{ new_password }}"
      notify: restart application
    
    - name: Update vault file
      copy:
        content: |
          db_password: {{ new_password }}
        dest: vault/secrets.yml
      delegate_to: localhost
      run_once: yes
    
    - name: Encrypt vault file
      shell: ansible-vault encrypt vault/secrets.yml
      delegate_to: localhost
      run_once: yes
  
  handlers:
    - name: restart application
      systemd:
        name: myapp
        state: restarted
```

**Use case**: Automated secret rotation  
**Best for**: Security compliance

---

## 🔧 Troubleshooting: When the Path is Obscured

*Even the wisest monks encounter obstacles.*

### Common Issues

#### Connection Problems

```bash
# Test connection
ansible all -m ping

# Verbose output
ansible all -m ping -vvv

# Check SSH
ssh -i ~/.ssh/id_rsa user@host

# Test with different user
ansible all -m ping -u ubuntu

# Use password authentication
ansible all -m ping --ask-pass

# Disable host key checking
export ANSIBLE_HOST_KEY_CHECKING=False
ansible all -m ping
```

#### Syntax Errors

```bash
# Check playbook syntax
ansible-playbook playbook.yml --syntax-check

# Validate YAML
yamllint playbook.yml

# Check with ansible-lint
ansible-lint playbook.yml
```

#### Variable Issues

```bash
# Debug variables
- name: Show all variables
  debug:
    var: hostvars[inventory_hostname]

- name: Show specific variable
  debug:
    var: my_variable

# Check variable precedence
ansible-playbook playbook.yml -e "my_var=override"
```

#### Performance Issues

```bash
# Increase parallelism
ansible-playbook playbook.yml -f 20

# Profile tasks
# Add to ansible.cfg:
# callbacks_enabled = profile_tasks

# Disable fact gathering
- hosts: all
  gather_facts: no

# Use fact caching
# In ansible.cfg:
# gathering = smart
# fact_caching = jsonfile
```

#### Idempotency Issues

```bash
# Check mode
ansible-playbook playbook.yml --check

# Diff mode
ansible-playbook playbook.yml --diff

# Fix shell/command tasks
- name: Run command
  command: /usr/bin/make install
  args:
    creates: /opt/app/installed  # Only run if file doesn't exist
```

---

## 🙏 Closing Wisdom

*The path of Ansible mastery is endless. These commands are but stepping stones.*

### Essential Daily Commands

```bash
# The monk's morning ritual
ansible all -m ping
ansible-playbook site.yml --check
ansible-inventory --graph

# The monk's deployment ritual
ansible-playbook deploy.yml --limit webservers
ansible-playbook deploy.yml --tags deploy
ansible all -m service -a "name=myapp state=restarted" --become

# The monk's evening reflection
ansible all -m setup -a "filter=ansible_distribution*"
ansible-playbook site.yml --list-tasks
```

### Best Practices from the Monastery

1. **Idempotency**: Tasks should be safe to run multiple times
2. **Use Roles**: Organize playbooks into reusable roles
3. **Version Control**: Store all playbooks in Git
4. **Use Vault**: Encrypt sensitive data
5. **Tag Tasks**: Use tags for selective execution
6. **Check Mode**: Always test with --check first
7. **Handlers**: Use handlers for service restarts
8. **Variables**: Use group_vars and host_vars
9. **Documentation**: Comment complex tasks
10. **Testing**: Test playbooks in staging first
11. **Limit Scope**: Use --limit for targeted runs
12. **Error Handling**: Use ignore_errors and failed_when

### Quick Reference Card

| Command | What It Does |
|---------|-------------|
| `ansible all -m ping` | Test connectivity |
| `ansible-playbook playbook.yml` | Run playbook |
| `ansible-playbook --check` | Dry run |
| `ansible-vault create` | Create encrypted file |
| `ansible-galaxy install` | Install role |
| `ansible-inventory --list` | Show inventory |
| `ansible all -m setup` | Gather facts |
| `ansible-playbook --tags` | Run specific tags |
| `ansible-playbook --limit` | Limit to hosts |
| `ansible-doc module` | Module documentation |

---

*May your playbooks be idempotent, your tasks be declarative, and your automation always successful.*

**— The Monk of Automation**  
*Monastery of Configuration*  
*Temple of Ansible*

🧘 **Namaste, `ansible`**

---

## 📚 Additional Resources

- [Official Ansible Documentation](https://docs.ansible.com/)
- [Ansible Galaxy](https://galaxy.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Ansible Lint](https://ansible-lint.readthedocs.io/)
- [Ansible Examples](https://github.com/ansible/ansible-examples)
- [Awesome Ansible](https://github.com/ansible-community/awesome-ansible)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*Ansible Version: 2.15+*
