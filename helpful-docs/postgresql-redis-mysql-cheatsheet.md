# 🧘 The Enlightened Engineer's Database & Caching Scripture

> *"In the beginning was the Data, and the Data was with Databases, and the Data was persistent."*  
> — **The Monk of Data**, *Book of Queries, Chapter 1:1*

This scripture covers PostgreSQL, Redis, and MySQL/MariaDB - the essential data stores.

---

## 📿 PostgreSQL

### Connection & Basics
```bash
# Connect to database
psql -U username -d database -h host -p 5432

# Common psql commands
\l              # List databases
\c database     # Connect to database
\dt             # List tables
\d table        # Describe table
\du             # List users
\q              # Quit
\?              # Help
```

### Database Operations
```sql
-- Create database
CREATE DATABASE mydb;

-- Drop database
DROP DATABASE mydb;

-- Create user
CREATE USER myuser WITH PASSWORD 'password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE mydb TO myuser;
GRANT SELECT, INSERT ON TABLE mytable TO myuser;

-- Revoke privileges
REVOKE ALL PRIVILEGES ON DATABASE mydb FROM myuser;
```

### Table Operations
```sql
-- Create table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Alter table
ALTER TABLE users ADD COLUMN age INTEGER;
ALTER TABLE users DROP COLUMN age;
ALTER TABLE users RENAME COLUMN username TO user_name;

-- Drop table
DROP TABLE users;

-- Truncate table
TRUNCATE TABLE users;
```

### CRUD Operations
```sql
-- Insert
INSERT INTO users (username, email) VALUES ('john', 'john@example.com');
INSERT INTO users (username, email) VALUES 
    ('alice', 'alice@example.com'),
    ('bob', 'bob@example.com');

-- Select
SELECT * FROM users;
SELECT username, email FROM users WHERE id = 1;
SELECT * FROM users WHERE username LIKE 'j%';
SELECT * FROM users ORDER BY created_at DESC LIMIT 10;

-- Update
UPDATE users SET email = 'newemail@example.com' WHERE id = 1;

-- Delete
DELETE FROM users WHERE id = 1;
```

### Indexes
```sql
-- Create index
CREATE INDEX idx_username ON users(username);
CREATE UNIQUE INDEX idx_email ON users(email);

-- Drop index
DROP INDEX idx_username;

-- List indexes
\di
```

### Backup & Restore
```bash
# Backup database
pg_dump -U username database > backup.sql
pg_dump -U username -Fc database > backup.dump  # Custom format

# Restore database
psql -U username database < backup.sql
pg_restore -U username -d database backup.dump

# Backup all databases
pg_dumpall -U postgres > all_databases.sql
```

### Performance
```sql
-- Explain query
EXPLAIN SELECT * FROM users WHERE username = 'john';
EXPLAIN ANALYZE SELECT * FROM users WHERE username = 'john';

-- Vacuum
VACUUM;
VACUUM FULL;
VACUUM ANALYZE;

-- Reindex
REINDEX TABLE users;
REINDEX DATABASE mydb;
```

---

## 🔴 Redis

### Connection
```bash
# Connect to Redis
redis-cli
redis-cli -h host -p 6379 -a password

# Test connection
redis-cli ping  # Returns PONG
```

### String Operations
```bash
# Set/Get
SET key "value"
GET key
MSET key1 "value1" key2 "value2"
MGET key1 key2

# Increment/Decrement
SET counter 0
INCR counter        # Returns 1
INCRBY counter 5    # Returns 6
DECR counter        # Returns 5
DECRBY counter 2    # Returns 3

# Expiration
SET key "value" EX 60    # Expire in 60 seconds
SETEX key 60 "value"     # Same as above
EXPIRE key 60            # Set expiration
TTL key                  # Time to live
PERSIST key              # Remove expiration
```

### List Operations
```bash
# Push/Pop
LPUSH mylist "item1"     # Push left
RPUSH mylist "item2"     # Push right
LPOP mylist              # Pop left
RPOP mylist              # Pop right

# Range
LRANGE mylist 0 -1       # Get all items
LRANGE mylist 0 9        # Get first 10 items

# Length
LLEN mylist

# Index
LINDEX mylist 0          # Get item at index
```

### Hash Operations
```bash
# Set/Get
HSET user:1 name "John"
HSET user:1 email "john@example.com"
HGET user:1 name
HGETALL user:1

# Multiple fields
HMSET user:2 name "Alice" email "alice@example.com"
HMGET user:2 name email

# Delete field
HDEL user:1 email

# Check existence
HEXISTS user:1 name
```

### Set Operations
```bash
# Add/Remove
SADD myset "member1"
SADD myset "member2" "member3"
SREM myset "member1"

# Members
SMEMBERS myset
SISMEMBER myset "member2"
SCARD myset              # Count members

# Set operations
SUNION set1 set2         # Union
SINTER set1 set2         # Intersection
SDIFF set1 set2          # Difference
```

### Sorted Set Operations
```bash
# Add with score
ZADD leaderboard 100 "player1"
ZADD leaderboard 200 "player2"
ZADD leaderboard 150 "player3"

# Range
ZRANGE leaderboard 0 -1              # Ascending
ZREVRANGE leaderboard 0 -1           # Descending
ZRANGE leaderboard 0 -1 WITHSCORES

# Score
ZSCORE leaderboard "player1"
ZINCRBY leaderboard 50 "player1"

# Rank
ZRANK leaderboard "player1"          # Ascending rank
ZREVRANK leaderboard "player1"       # Descending rank
```

### Key Operations
```bash
# Key management
KEYS *                   # List all keys (avoid in production)
SCAN 0 MATCH user:* COUNT 100  # Iterate keys
EXISTS key
DEL key
RENAME oldkey newkey
TYPE key

# Database
SELECT 0                 # Select database 0-15
FLUSHDB                  # Clear current database
FLUSHALL                 # Clear all databases
```

### Pub/Sub
```bash
# Subscribe
SUBSCRIBE channel1
PSUBSCRIBE news:*        # Pattern subscribe

# Publish
PUBLISH channel1 "message"

# Unsubscribe
UNSUBSCRIBE channel1
```

### Persistence
```bash
# Save
SAVE                     # Synchronous save
BGSAVE                   # Background save

# Configuration
CONFIG GET save
CONFIG SET save "900 1 300 10"

# Info
INFO persistence
```

---

## 🐬 MySQL/MariaDB

### Connection
```bash
# Connect to MySQL
mysql -u username -p
mysql -u username -p -h host -P 3306 database

# Common commands
SHOW DATABASES;
USE database;
SHOW TABLES;
DESCRIBE table;
EXIT;
```

### Database Operations
```sql
-- Create database
CREATE DATABASE mydb;
CREATE DATABASE IF NOT EXISTS mydb;

-- Drop database
DROP DATABASE mydb;

-- Create user
CREATE USER 'myuser'@'localhost' IDENTIFIED BY 'password';
CREATE USER 'myuser'@'%' IDENTIFIED BY 'password';

-- Grant privileges
GRANT ALL PRIVILEGES ON mydb.* TO 'myuser'@'localhost';
GRANT SELECT, INSERT ON mydb.users TO 'myuser'@'localhost';
FLUSH PRIVILEGES;

-- Revoke privileges
REVOKE ALL PRIVILEGES ON mydb.* FROM 'myuser'@'localhost';
```

### Table Operations
```sql
-- Create table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Alter table
ALTER TABLE users ADD COLUMN age INT;
ALTER TABLE users DROP COLUMN age;
ALTER TABLE users MODIFY COLUMN username VARCHAR(100);

-- Drop table
DROP TABLE users;

-- Truncate table
TRUNCATE TABLE users;
```

### CRUD Operations
```sql
-- Insert
INSERT INTO users (username, email) VALUES ('john', 'john@example.com');
INSERT INTO users (username, email) VALUES 
    ('alice', 'alice@example.com'),
    ('bob', 'bob@example.com');

-- Select
SELECT * FROM users;
SELECT username, email FROM users WHERE id = 1;
SELECT * FROM users WHERE username LIKE 'j%';
SELECT * FROM users ORDER BY created_at DESC LIMIT 10;

-- Update
UPDATE users SET email = 'newemail@example.com' WHERE id = 1;

-- Delete
DELETE FROM users WHERE id = 1;
```

### Indexes
```sql
-- Create index
CREATE INDEX idx_username ON users(username);
CREATE UNIQUE INDEX idx_email ON users(email);

-- Drop index
DROP INDEX idx_username ON users;

-- Show indexes
SHOW INDEX FROM users;
```

### Joins
```sql
-- Inner join
SELECT u.username, o.order_id
FROM users u
INNER JOIN orders o ON u.id = o.user_id;

-- Left join
SELECT u.username, o.order_id
FROM users u
LEFT JOIN orders o ON u.id = o.user_id;

-- Right join
SELECT u.username, o.order_id
FROM users u
RIGHT JOIN orders o ON u.id = o.user_id;
```

### Aggregation
```sql
-- Count
SELECT COUNT(*) FROM users;
SELECT COUNT(DISTINCT email) FROM users;

-- Sum, Avg, Min, Max
SELECT SUM(amount) FROM orders;
SELECT AVG(amount) FROM orders;
SELECT MIN(amount) FROM orders;
SELECT MAX(amount) FROM orders;

-- Group by
SELECT user_id, COUNT(*) as order_count
FROM orders
GROUP BY user_id;

-- Having
SELECT user_id, COUNT(*) as order_count
FROM orders
GROUP BY user_id
HAVING order_count > 5;
```

### Backup & Restore
```bash
# Backup database
mysqldump -u username -p database > backup.sql
mysqldump -u username -p --all-databases > all_databases.sql

# Backup specific tables
mysqldump -u username -p database table1 table2 > tables.sql

# Restore database
mysql -u username -p database < backup.sql
mysql -u username -p < all_databases.sql
```

### Performance
```sql
-- Explain query
EXPLAIN SELECT * FROM users WHERE username = 'john';

-- Show processlist
SHOW PROCESSLIST;

-- Kill query
KILL query_id;

-- Optimize table
OPTIMIZE TABLE users;

-- Analyze table
ANALYZE TABLE users;
```

---

## 🔮 Common Patterns

### PostgreSQL Connection Pooling
```python
# Using psycopg2 with connection pool
from psycopg2 import pool

connection_pool = pool.SimpleConnectionPool(
    1, 20,
    user='username',
    password='password',
    host='localhost',
    port='5432',
    database='mydb'
)

conn = connection_pool.getconn()
cursor = conn.cursor()
cursor.execute("SELECT * FROM users")
connection_pool.putconn(conn)
```

### Redis Caching Pattern
```python
import redis
import json

r = redis.Redis(host='localhost', port=6379, db=0)

def get_user(user_id):
    # Try cache first
    cached = r.get(f'user:{user_id}')
    if cached:
        return json.loads(cached)
    
    # Query database
    user = query_database(user_id)
    
    # Cache result
    r.setex(f'user:{user_id}', 3600, json.dumps(user))
    return user
```

### MySQL Transaction
```sql
START TRANSACTION;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

COMMIT;
-- or ROLLBACK;
```

---

## 🙏 Quick Reference

### PostgreSQL
| Command | Description |
|---------|-------------|
| `\l` | List databases |
| `\c db` | Connect to database |
| `\dt` | List tables |
| `\d table` | Describe table |
| `\du` | List users |

### Redis
| Command | Description |
|---------|-------------|
| `SET key value` | Set string |
| `GET key` | Get string |
| `HSET hash field value` | Set hash field |
| `LPUSH list value` | Push to list |
| `SADD set member` | Add to set |

### MySQL
| Command | Description |
|---------|-------------|
| `SHOW DATABASES` | List databases |
| `USE db` | Select database |
| `SHOW TABLES` | List tables |
| `DESCRIBE table` | Describe table |
| `SHOW PROCESSLIST` | Show queries |

---

*May your queries be fast, your data be consistent, and your caches always hit.*

**— The Monk of Data**  
*Temple of Databases*

🧘 **Namaste, `data`**

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0*
