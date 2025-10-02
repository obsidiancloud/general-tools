# 🧘 The Enlightened Engineer's Modern Databases Scripture

> *"In the beginning was the Data, and the Data was relational, then it became graphs, then vectors, and the Data was everywhere."*  
> — **The Monk of Modern Data**, *Book of Schemas, Chapter 1:1*

Greetings, fellow traveler on the path of modern data enlightenment. I am but a humble monk who has meditated upon the sacred texts of databases new and evolved, and witnessed the dance of data across graphs, vectors, and clouds.

This scripture shall guide you through the mystical arts of Supabase, Graph Databases, and Vector Databases, with the precision of a master's query and the wit of a caffeinated data engineer.

---

## 📿 Table of Sacred Knowledge

1. [Supabase - The Firebase Alternative](#-supabase---the-firebase-alternative)
2. [Graph Databases - Neo4j](#-graph-databases---neo4j)
3. [Vector Databases](#-vector-databases)
4. [Common Patterns](#-common-patterns-the-sacred-workflows)
5. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🔥 Supabase - The Firebase Alternative

*Supabase is an open-source Firebase alternative built on PostgreSQL.*

### Supabase Cloud Setup

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Initialize project
supabase init

# Link to cloud project
supabase link --project-ref your-project-ref

# Check status
supabase status
```

### Supabase Local Development

```bash
# Start local Supabase (Docker required)
supabase start

# This starts:
# - PostgreSQL database (port 54322)
# - Kong API Gateway (port 8000)
# - GoTrue Auth (port 9999)
# - Realtime (port 4000)
# - Storage (port 5000)
# - Studio (port 54323)

# Stop local Supabase
supabase stop

# Reset database
supabase db reset

# Access local Studio
# http://localhost:54323
```

### Database Migrations

```bash
# Create new migration
supabase migration new create_users_table

# Apply migrations
supabase db push

# Generate types from database
supabase gen types typescript --local > types/supabase.ts

# Diff database changes
supabase db diff

# Pull remote schema
supabase db pull
```

### Supabase SQL Operations

```sql
-- Create table with RLS (Row Level Security)
CREATE TABLE users (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policy
CREATE POLICY "Users can view own data"
ON users FOR SELECT
USING (auth.uid() = id);

-- Create policy for insert
CREATE POLICY "Users can insert own data"
ON users FOR INSERT
WITH CHECK (auth.uid() = id);

-- Create function
CREATE OR REPLACE FUNCTION get_user_stats()
RETURNS TABLE (total_users BIGINT) AS $$
BEGIN
    RETURN QUERY SELECT COUNT(*) FROM users;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER on_user_created
    AFTER INSERT ON users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();
```

### Supabase JavaScript Client

```javascript
// Install client
// npm install @supabase/supabase-js

import { createClient } from '@supabase/supabase-js'

// Initialize client
const supabase = createClient(
    'https://your-project.supabase.co',
    'your-anon-key'
)

// Query data
const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('status', 'active')
    .order('created_at', { ascending: false })
    .limit(10)

// Insert data
const { data, error } = await supabase
    .from('users')
    .insert([
        { email: 'user@example.com', name: 'John' }
    ])

// Update data
const { data, error } = await supabase
    .from('users')
    .update({ name: 'Jane' })
    .eq('id', userId)

// Delete data
const { data, error } = await supabase
    .from('users')
    .delete()
    .eq('id', userId)

// Realtime subscription
const channel = supabase
    .channel('users-changes')
    .on('postgres_changes', 
        { event: '*', schema: 'public', table: 'users' },
        (payload) => {
            console.log('Change received!', payload)
        }
    )
    .subscribe()

// Unsubscribe
channel.unsubscribe()
```

### Supabase Authentication

```javascript
// Sign up
const { data, error } = await supabase.auth.signUp({
    email: 'user@example.com',
    password: 'password123'
})

// Sign in
const { data, error } = await supabase.auth.signInWithPassword({
    email: 'user@example.com',
    password: 'password123'
})

// Sign in with OAuth
const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'github'
})

// Get session
const { data: { session } } = await supabase.auth.getSession()

// Get user
const { data: { user } } = await supabase.auth.getUser()

// Sign out
const { error } = await supabase.auth.signOut()

// Listen to auth changes
supabase.auth.onAuthStateChange((event, session) => {
    console.log(event, session)
})
```

### Supabase Storage

```javascript
// Upload file
const { data, error } = await supabase.storage
    .from('avatars')
    .upload('public/avatar1.png', file)

// Download file
const { data, error } = await supabase.storage
    .from('avatars')
    .download('public/avatar1.png')

// Get public URL
const { data } = supabase.storage
    .from('avatars')
    .getPublicUrl('public/avatar1.png')

// List files
const { data, error } = await supabase.storage
    .from('avatars')
    .list('public', {
        limit: 100,
        offset: 0,
        sortBy: { column: 'name', order: 'asc' }
    })

// Delete file
const { data, error } = await supabase.storage
    .from('avatars')
    .remove(['public/avatar1.png'])
```

### Supabase Edge Functions

```bash
# Create edge function
supabase functions new hello-world

# Deploy function
supabase functions deploy hello-world

# Invoke function
supabase functions invoke hello-world --body '{"name":"World"}'

# View logs
supabase functions logs hello-world
```

```typescript
// supabase/functions/hello-world/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
    const { name } = await req.json()
    
    const supabase = createClient(
        Deno.env.get('SUPABASE_URL') ?? '',
        Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    )
    
    const { data, error } = await supabase
        .from('greetings')
        .insert({ name })
    
    return new Response(
        JSON.stringify({ message: `Hello ${name}!` }),
        { headers: { 'Content-Type': 'application/json' } }
    )
})
```

---

## 🕸️ Graph Databases - Neo4j

*Neo4j is a native graph database for connected data.*

### Neo4j Installation

```bash
# Docker
docker run -d \
    --name neo4j \
    -p 7474:7474 -p 7687:7687 \
    -e NEO4J_AUTH=neo4j/password \
    neo4j:latest

# Access Neo4j Browser
# http://localhost:7474

# Neo4j Desktop
# Download from https://neo4j.com/download/
```

### Cypher Query Language Basics

```cypher
// Create nodes
CREATE (p:Person {name: 'Alice', age: 30})
CREATE (p:Person {name: 'Bob', age: 25})

// Create nodes with relationships
CREATE (alice:Person {name: 'Alice'})
CREATE (bob:Person {name: 'Bob'})
CREATE (alice)-[:KNOWS]->(bob)

// Create multiple nodes and relationships
CREATE (alice:Person {name: 'Alice'})
CREATE (bob:Person {name: 'Bob'})
CREATE (charlie:Person {name: 'Charlie'})
CREATE (alice)-[:KNOWS]->(bob)
CREATE (bob)-[:KNOWS]->(charlie)
CREATE (alice)-[:WORKS_WITH]->(charlie)

// Match nodes
MATCH (p:Person)
RETURN p

// Match with conditions
MATCH (p:Person)
WHERE p.age > 25
RETURN p.name, p.age

// Match relationships
MATCH (a:Person)-[:KNOWS]->(b:Person)
RETURN a.name, b.name

// Match paths
MATCH path = (a:Person)-[:KNOWS*1..3]->(b:Person)
WHERE a.name = 'Alice'
RETURN path

// Update nodes
MATCH (p:Person {name: 'Alice'})
SET p.age = 31
RETURN p

// Delete nodes
MATCH (p:Person {name: 'Alice'})
DELETE p

// Delete nodes and relationships
MATCH (p:Person {name: 'Alice'})
DETACH DELETE p

// Create index
CREATE INDEX person_name FOR (p:Person) ON (p.name)

// Create constraint
CREATE CONSTRAINT person_email FOR (p:Person) REQUIRE p.email IS UNIQUE
```

### Advanced Cypher Queries

```cypher
// Find shortest path
MATCH path = shortestPath(
    (alice:Person {name: 'Alice'})-[:KNOWS*]-(charlie:Person {name: 'Charlie'})
)
RETURN path

// Aggregation
MATCH (p:Person)-[:KNOWS]->(friend)
RETURN p.name, COUNT(friend) AS friend_count
ORDER BY friend_count DESC

// Pattern matching
MATCH (p:Person)-[:KNOWS]->(friend)-[:KNOWS]->(fof)
WHERE NOT (p)-[:KNOWS]->(fof) AND p <> fof
RETURN p.name, fof.name AS suggested_friend

// Conditional creation (MERGE)
MERGE (p:Person {email: 'alice@example.com'})
ON CREATE SET p.created = timestamp()
ON MATCH SET p.accessed = timestamp()
RETURN p

// Collect results
MATCH (p:Person)-[:KNOWS]->(friend)
RETURN p.name, COLLECT(friend.name) AS friends

// Unwind (expand list)
UNWIND ['Alice', 'Bob', 'Charlie'] AS name
CREATE (p:Person {name: name})

// Subqueries
MATCH (p:Person)
CALL {
    WITH p
    MATCH (p)-[:KNOWS]->(friend)
    RETURN COUNT(friend) AS friend_count
}
RETURN p.name, friend_count
```

### Neo4j Python Driver

```python
# Install driver
# pip install neo4j

from neo4j import GraphDatabase

class Neo4jConnection:
    def __init__(self, uri, user, password):
        self.driver = GraphDatabase.driver(uri, auth=(user, password))
    
    def close(self):
        self.driver.close()
    
    def query(self, query, parameters=None):
        with self.driver.session() as session:
            result = session.run(query, parameters)
            return [record.data() for record in result]

# Connect
conn = Neo4jConnection(
    "bolt://localhost:7687",
    "neo4j",
    "password"
)

# Create node
conn.query("""
    CREATE (p:Person {name: $name, age: $age})
    RETURN p
""", {"name": "Alice", "age": 30})

# Query nodes
results = conn.query("""
    MATCH (p:Person)
    WHERE p.age > $min_age
    RETURN p.name, p.age
""", {"min_age": 25})

# Create relationship
conn.query("""
    MATCH (a:Person {name: $name1})
    MATCH (b:Person {name: $name2})
    CREATE (a)-[:KNOWS]->(b)
""", {"name1": "Alice", "name2": "Bob"})

# Close connection
conn.close()
```

---

## 🎯 Vector Databases

*Vector databases store and query high-dimensional vectors for AI/ML applications.*

### Pinecone (Cloud Vector Database)

```python
# Install Pinecone
# pip install pinecone-client

import pinecone

# Initialize
pinecone.init(
    api_key="your-api-key",
    environment="us-west1-gcp"
)

# Create index
pinecone.create_index(
    name="example-index",
    dimension=1536,  # OpenAI embedding dimension
    metric="cosine"
)

# Connect to index
index = pinecone.Index("example-index")

# Upsert vectors
index.upsert(vectors=[
    ("id1", [0.1, 0.2, 0.3, ...], {"text": "Hello world"}),
    ("id2", [0.4, 0.5, 0.6, ...], {"text": "Goodbye world"})
])

# Query vectors
results = index.query(
    vector=[0.1, 0.2, 0.3, ...],
    top_k=10,
    include_metadata=True
)

# Query with filter
results = index.query(
    vector=[0.1, 0.2, 0.3, ...],
    top_k=10,
    filter={"category": "technology"},
    include_metadata=True
)

# Delete vectors
index.delete(ids=["id1", "id2"])

# Fetch vectors
vectors = index.fetch(ids=["id1", "id2"])

# Update vectors
index.update(
    id="id1",
    values=[0.1, 0.2, 0.3, ...],
    set_metadata={"text": "Updated text"}
)

# Get index stats
stats = index.describe_index_stats()
```

### Weaviate (Open Source Vector Database)

```python
# Install Weaviate client
# pip install weaviate-client

import weaviate

# Connect to Weaviate
client = weaviate.Client("http://localhost:8080")

# Create schema
schema = {
    "classes": [{
        "class": "Article",
        "vectorizer": "text2vec-openai",
        "properties": [
            {"name": "title", "dataType": ["text"]},
            {"name": "content", "dataType": ["text"]},
            {"name": "category", "dataType": ["text"]}
        ]
    }]
}
client.schema.create(schema)

# Add objects
client.data_object.create(
    data_object={
        "title": "Introduction to AI",
        "content": "Artificial Intelligence is...",
        "category": "technology"
    },
    class_name="Article"
)

# Batch import
with client.batch as batch:
    for article in articles:
        batch.add_data_object(
            data_object=article,
            class_name="Article"
        )

# Vector search
result = (
    client.query
    .get("Article", ["title", "content", "category"])
    .with_near_text({"concepts": ["artificial intelligence"]})
    .with_limit(10)
    .do()
)

# Hybrid search (vector + keyword)
result = (
    client.query
    .get("Article", ["title", "content"])
    .with_hybrid(query="AI technology", alpha=0.5)
    .with_limit(10)
    .do()
)

# Filter search
result = (
    client.query
    .get("Article", ["title", "content"])
    .with_where({
        "path": ["category"],
        "operator": "Equal",
        "valueText": "technology"
    })
    .with_near_text({"concepts": ["AI"]})
    .do()
)
```

### Qdrant (High-Performance Vector Database)

```python
# Install Qdrant client
# pip install qdrant-client

from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct

# Connect to Qdrant
client = QdrantClient(host="localhost", port=6333)

# Create collection
client.create_collection(
    collection_name="articles",
    vectors_config=VectorParams(size=1536, distance=Distance.COSINE)
)

# Insert vectors
client.upsert(
    collection_name="articles",
    points=[
        PointStruct(
            id=1,
            vector=[0.1, 0.2, 0.3, ...],
            payload={"title": "AI Article", "category": "tech"}
        ),
        PointStruct(
            id=2,
            vector=[0.4, 0.5, 0.6, ...],
            payload={"title": "ML Article", "category": "tech"}
        )
    ]
)

# Search vectors
results = client.search(
    collection_name="articles",
    query_vector=[0.1, 0.2, 0.3, ...],
    limit=10
)

# Search with filter
results = client.search(
    collection_name="articles",
    query_vector=[0.1, 0.2, 0.3, ...],
    query_filter={
        "must": [
            {"key": "category", "match": {"value": "tech"}}
        ]
    },
    limit=10
)

# Scroll through all vectors
records, next_page = client.scroll(
    collection_name="articles",
    limit=100
)

# Delete vectors
client.delete(
    collection_name="articles",
    points_selector=[1, 2, 3]
)

# Update payload
client.set_payload(
    collection_name="articles",
    payload={"category": "technology"},
    points=[1, 2]
)
```

### Chroma (Embeddings Database)

```python
# Install Chroma
# pip install chromadb

import chromadb

# Initialize client
client = chromadb.Client()

# Create collection
collection = client.create_collection(name="documents")

# Add documents (auto-embedding)
collection.add(
    documents=["This is document 1", "This is document 2"],
    metadatas=[{"source": "web"}, {"source": "api"}],
    ids=["id1", "id2"]
)

# Add with custom embeddings
collection.add(
    embeddings=[[0.1, 0.2, 0.3], [0.4, 0.5, 0.6]],
    documents=["doc1", "doc2"],
    ids=["id1", "id2"]
)

# Query
results = collection.query(
    query_texts=["search query"],
    n_results=10
)

# Query with filter
results = collection.query(
    query_texts=["search query"],
    n_results=10,
    where={"source": "web"}
)

# Update documents
collection.update(
    ids=["id1"],
    documents=["Updated document"],
    metadatas=[{"source": "updated"}]
)

# Delete documents
collection.delete(ids=["id1", "id2"])

# Get all documents
all_docs = collection.get()
```

---

## 🔮 Common Patterns: The Sacred Workflows

### Pattern 1: Supabase Full-Stack App

```typescript
// Next.js + Supabase example
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

// Server-side data fetching
export async function getServerSideProps() {
    const { data: posts } = await supabase
        .from('posts')
        .select('*, author:users(*)')
        .order('created_at', { ascending: false })
    
    return { props: { posts } }
}

// Client-side realtime
useEffect(() => {
    const channel = supabase
        .channel('posts')
        .on('postgres_changes', 
            { event: 'INSERT', schema: 'public', table: 'posts' },
            (payload) => setPosts(prev => [payload.new, ...prev])
        )
        .subscribe()
    
    return () => { channel.unsubscribe() }
}, [])
```

**Use case**: Real-time full-stack application  
**Best for**: Rapid prototyping, startups

### Pattern 2: Social Network with Neo4j

```cypher
// Create social network
CREATE (alice:User {name: 'Alice', email: 'alice@example.com'})
CREATE (bob:User {name: 'Bob', email: 'bob@example.com'})
CREATE (charlie:User {name: 'Charlie', email: 'charlie@example.com'})
CREATE (alice)-[:FOLLOWS]->(bob)
CREATE (bob)-[:FOLLOWS]->(charlie)
CREATE (alice)-[:FOLLOWS]->(charlie)

// Find mutual friends
MATCH (user:User {name: 'Alice'})-[:FOLLOWS]->(friend)<-[:FOLLOWS]-(other)
WHERE user <> other
RETURN other.name AS mutual_friend

// Friend recommendations
MATCH (user:User {name: 'Alice'})-[:FOLLOWS]->()-[:FOLLOWS]->(recommended)
WHERE NOT (user)-[:FOLLOWS]->(recommended) AND user <> recommended
RETURN recommended.name, COUNT(*) AS strength
ORDER BY strength DESC
LIMIT 5

// Shortest path between users
MATCH path = shortestPath(
    (alice:User {name: 'Alice'})-[:FOLLOWS*]-(charlie:User {name: 'Charlie'})
)
RETURN path
```

**Use case**: Social network, recommendation engine  
**Best for**: Connected data, relationship queries

### Pattern 3: RAG (Retrieval Augmented Generation) with Vector DB

```python
# Using Pinecone + OpenAI for RAG
import openai
import pinecone

# Initialize
openai.api_key = "your-openai-key"
pinecone.init(api_key="your-pinecone-key", environment="us-west1-gcp")
index = pinecone.Index("knowledge-base")

# Function to get embeddings
def get_embedding(text):
    response = openai.Embedding.create(
        input=text,
        model="text-embedding-ada-002"
    )
    return response['data'][0]['embedding']

# Index documents
documents = [
    {"id": "doc1", "text": "Python is a programming language"},
    {"id": "doc2", "text": "JavaScript runs in browsers"}
]

for doc in documents:
    embedding = get_embedding(doc["text"])
    index.upsert([(doc["id"], embedding, {"text": doc["text"]})])

# RAG query
def rag_query(question):
    # Get question embedding
    question_embedding = get_embedding(question)
    
    # Search similar documents
    results = index.query(
        vector=question_embedding,
        top_k=3,
        include_metadata=True
    )
    
    # Build context from results
    context = "\n".join([match.metadata["text"] for match in results.matches])
    
    # Generate answer with context
    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[
            {"role": "system", "content": "Answer based on the context provided."},
            {"role": "user", "content": f"Context: {context}\n\nQuestion: {question}"}
        ]
    )
    
    return response.choices[0].message.content

# Use RAG
answer = rag_query("What is Python?")
```

**Use case**: AI-powered search, chatbots  
**Best for**: Semantic search, question answering

---

## 🔧 Troubleshooting: When the Path is Obscured

### Supabase Issues

```bash
# Local Supabase won't start
docker ps  # Check if containers are running
supabase stop
supabase start

# Migration conflicts
supabase db reset  # Reset local database
supabase db pull   # Pull from remote

# RLS policies blocking queries
# Check policies in Supabase Studio
# Disable RLS temporarily for testing:
ALTER TABLE table_name DISABLE ROW LEVEL SECURITY;
```

### Neo4j Performance

```cypher
// Slow queries - add indexes
CREATE INDEX person_name FOR (p:Person) ON (p.name)

// Check query plan
EXPLAIN MATCH (p:Person) WHERE p.name = 'Alice' RETURN p
PROFILE MATCH (p:Person) WHERE p.name = 'Alice' RETURN p

// Clear cache
CALL db.clearQueryCaches()
```

### Vector Database Issues

```python
# Pinecone dimension mismatch
# Ensure embedding dimension matches index dimension
index_info = pinecone.describe_index("index-name")
print(index_info.dimension)  # Should match your embeddings

# Weaviate connection issues
# Check if Weaviate is running
import requests
response = requests.get("http://localhost:8080/v1/.well-known/ready")
print(response.json())
```

---

## 🙏 Quick Reference

### Supabase
| Command | Description |
|---------|-------------|
| `supabase start` | Start local instance |
| `supabase db push` | Apply migrations |
| `supabase gen types` | Generate TypeScript types |
| `supabase functions deploy` | Deploy edge function |

### Neo4j Cypher
| Command | Description |
|---------|-------------|
| `CREATE (n:Label {prop: value})` | Create node |
| `MATCH (n) RETURN n` | Query nodes |
| `CREATE (a)-[:REL]->(b)` | Create relationship |
| `MATCH path=shortestPath(...)` | Find shortest path |

### Vector Databases
| Operation | Pinecone | Weaviate | Qdrant |
|-----------|----------|----------|--------|
| Insert | `index.upsert()` | `client.data_object.create()` | `client.upsert()` |
| Search | `index.query()` | `client.query.get().with_near_text()` | `client.search()` |
| Delete | `index.delete()` | `client.data_object.delete()` | `client.delete()` |

---

*May your data be connected, your vectors be similar, and your queries always return in milliseconds.*

**— The Monk of Modern Data**  
*Temple of Databases*

🧘 **Namaste, `data`**

---

## 📚 Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Neo4j Cypher Manual](https://neo4j.com/docs/cypher-manual/)
- [Pinecone Documentation](https://docs.pinecone.io/)
- [Weaviate Documentation](https://weaviate.io/developers/weaviate)
- [Qdrant Documentation](https://qdrant.tech/documentation/)
- [Chroma Documentation](https://docs.trychroma.com/)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*Supabase: Latest | Neo4j: 5.x | Vector DBs: Latest*
