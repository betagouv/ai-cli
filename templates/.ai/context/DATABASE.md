# Database Guidelines

> Database design and optimization for {{PROJECT_NAME}}

## 🎯 General Principles

- **Normalize first, denormalize when needed** - Start with proper normalization
- **Index wisely** - Every query should use an index
- **Plan for scale** - Design for 10x your current data
- **Migration safety** - All schema changes must be reversible
- **Monitor performance** - Track slow queries

## 📊 Schema Design

### Naming Conventions

```sql
-- ✅ Tables: plural, snake_case
users
user_profiles
blog_posts
post_comments

-- ✅ Columns: singular, snake_case
user_id
created_at
first_name
is_active

-- ✅ Primary keys: id or table_id
id
user_id (in users table)

-- ✅ Foreign keys: related_table_id
user_id (in posts table)
post_id (in comments table)

-- ✅ Booleans: is_, has_, can_
is_active
has_profile
can_edit

-- ✅ Timestamps: _at suffix
created_at
updated_at
deleted_at
published_at

-- ❌ Avoid
UserTable
tblUsers
user-profiles (hyphen)
UserId (camelCase)
```

### Data Types

```sql
-- ✅ Use appropriate types

-- IDs: use UUID or bigint
id UUID PRIMARY KEY DEFAULT gen_random_uuid()
id BIGSERIAL PRIMARY KEY

-- Strings
name VARCHAR(255)        -- Known max length
bio TEXT                 -- Unlimited text
status ENUM('pending', 'approved', 'rejected')

-- Numbers
age INT
price DECIMAL(10, 2)    -- Money (avoid FLOAT!)
rating DECIMAL(3, 2)    -- e.g., 4.75

-- Booleans
is_active BOOLEAN DEFAULT true NOT NULL

-- Dates/Times
created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
birth_date DATE
meeting_time TIME

-- JSON (PostgreSQL)
metadata JSONB          -- Use JSONB, not JSON
settings JSONB DEFAULT '{}'::jsonb

-- Arrays (PostgreSQL)
tags TEXT[]
```

### Constraints

```sql
-- ✅ Use constraints for data integrity

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  age INT CHECK (age >= 18 AND age <= 120),
  status VARCHAR(20) CHECK (status IN ('active', 'inactive', 'banned')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,

  -- Composite unique constraint
  UNIQUE (email, deleted_at)
);

CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(500) NOT NULL,
  content TEXT NOT NULL,
  published_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,

  -- Constraints
  CHECK (LENGTH(title) >= 3),
  CHECK (published_at IS NULL OR published_at >= created_at)
);
```

### Indexes

```sql
-- ✅ Index foreign keys
CREATE INDEX idx_posts_user_id ON posts(user_id);

-- ✅ Index frequently queried columns
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_posts_published_at ON posts(published_at);

-- ✅ Composite indexes for common queries
-- Query: SELECT * FROM posts WHERE user_id = ? AND status = ?
CREATE INDEX idx_posts_user_status ON posts(user_id, status);

-- ✅ Partial indexes
CREATE INDEX idx_active_users ON users(email) WHERE is_active = true;

-- ✅ Index for sorting
CREATE INDEX idx_posts_created_desc ON posts(created_at DESC);

-- ✅ Full-text search index (PostgreSQL)
CREATE INDEX idx_posts_search ON posts USING GIN (to_tsvector('english', title || ' ' || content));

-- ❌ Don't over-index
-- Every index slows down INSERT/UPDATE/DELETE
-- Only index what you actually query
```

### Normalization

```sql
-- ✅ Normalized (good for most cases)

-- users table
CREATE TABLE users (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL
);

-- addresses table (1:many)
CREATE TABLE addresses (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  street VARCHAR(255),
  city VARCHAR(100),
  country VARCHAR(100)
);

-- ❌ Denormalized (only when needed for performance)
CREATE TABLE users (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  address_street VARCHAR(255),
  address_city VARCHAR(100),
  address_country VARCHAR(100)
  -- Harder to update, data duplication
);
```

### Soft Deletes

```sql
-- ✅ Implement soft deletes for important data

CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) NOT NULL,
  deleted_at TIMESTAMP WITH TIME ZONE,

  -- Unique constraint that allows soft-deleted duplicates
  UNIQUE (email) WHERE deleted_at IS NULL
);

-- Query active users
SELECT * FROM users WHERE deleted_at IS NULL;

-- Soft delete
UPDATE users SET deleted_at = NOW() WHERE id = ?;

-- Restore
UPDATE users SET deleted_at = NULL WHERE id = ?;
```

### Timestamps

```sql
-- ✅ Always include timestamps

CREATE TABLE posts (
  id UUID PRIMARY KEY,
  title VARCHAR(500) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- ✅ Trigger to auto-update updated_at (PostgreSQL)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_posts_updated_at
  BEFORE UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

## 🔄 Migrations

### Migration Strategy

```typescript
// ✅ One migration per change
// migrations/001_create_users_table.sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

// migrations/002_add_users_name.sql
ALTER TABLE users ADD COLUMN name VARCHAR(255) NOT NULL DEFAULT '';

// ✅ Always include rollback
// migrations/002_add_users_name_down.sql
ALTER TABLE users DROP COLUMN name;
```

### Safe Migrations

```sql
-- ✅ Add column with default (safe)
ALTER TABLE users ADD COLUMN age INT DEFAULT 18;

-- ✅ Add nullable column first, then make NOT NULL
-- Step 1
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Step 2 (after backfilling data)
UPDATE users SET phone = '...' WHERE phone IS NULL;

-- Step 3
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;

-- ❌ Don't add NOT NULL column without default (breaks existing rows)
ALTER TABLE users ADD COLUMN age INT NOT NULL; -- ERROR!

-- ✅ Drop column safely
-- Step 1: Stop using the column in code
-- Step 2: Deploy
-- Step 3: Drop in next migration
ALTER TABLE users DROP COLUMN old_column;

-- ✅ Rename column safely
-- Use views or add new column, migrate data, drop old
```

### Zero-Downtime Migrations

```sql
-- ✅ Adding an index concurrently (PostgreSQL)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- ✅ Changing column type (multi-step)
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN age_new INT;

-- Step 2: Backfill data
UPDATE users SET age_new = age::INT;

-- Step 3: Swap columns
ALTER TABLE users DROP COLUMN age;
ALTER TABLE users RENAME COLUMN age_new TO age;
```

## ⚡ Query Optimization

### Use EXPLAIN

```sql
-- ✅ Analyze queries
EXPLAIN ANALYZE
SELECT u.name, COUNT(p.id) as post_count
FROM users u
LEFT JOIN posts p ON p.user_id = u.id
GROUP BY u.id, u.name;

-- Look for:
-- - Seq Scan (bad for large tables)
-- - Index Scan (good)
-- - Execution time
-- - Rows returned vs rows scanned
```

### N+1 Query Problem

```typescript
// ❌ N+1 queries (bad)
const users = await db.user.findMany()
for (const user of users) {
  user.posts = await db.post.findMany({ where: { userId: user.id } })
}
// 1 query for users + N queries for posts

// ✅ Single query with join
const users = await db.user.findMany({
  include: { posts: true }
})
// 1 query total
```

### Pagination

```typescript
// ❌ Offset pagination (slow for large offsets)
SELECT * FROM posts
ORDER BY created_at DESC
LIMIT 20 OFFSET 10000; -- Scans first 10,000 rows!

// ✅ Cursor pagination (fast)
SELECT * FROM posts
WHERE created_at < '2025-01-15'
ORDER BY created_at DESC
LIMIT 20;
```

### Query Tips

```sql
-- ✅ Select only needed columns
SELECT id, name, email FROM users;  -- Good
SELECT * FROM users;                 -- Wasteful

-- ✅ Use EXISTS instead of COUNT for checking existence
-- Instead of:
SELECT COUNT(*) FROM posts WHERE user_id = ?;

-- Use:
SELECT EXISTS(SELECT 1 FROM posts WHERE user_id = ?);

-- ✅ Use LIMIT when you don't need all results
SELECT * FROM posts ORDER BY created_at DESC LIMIT 10;

-- ✅ Filter early with WHERE
SELECT u.name, p.title
FROM users u
JOIN posts p ON p.user_id = u.id
WHERE u.is_active = true    -- Filter before join
  AND p.published_at IS NOT NULL;
```

## 🔧 ORM Best Practices

### Prisma

```typescript
// ✅ Use select to limit fields
const users = await prisma.user.findMany({
  select: {
    id: true,
    name: true,
    email: true
  }
})

// ✅ Use include for relations
const users = await prisma.user.findMany({
  include: {
    posts: {
      where: { published: true },
      orderBy: { createdAt: 'desc' },
      take: 5
    }
  }
})

// ✅ Use transactions
await prisma.$transaction(async (tx) => {
  await tx.user.create({ data: userData })
  await tx.post.create({ data: postData })
})

// ✅ Use raw queries for complex operations
const result = await prisma.$queryRaw`
  SELECT u.name, COUNT(p.id) as post_count
  FROM users u
  LEFT JOIN posts p ON p.user_id = u.id
  GROUP BY u.id, u.name
  HAVING COUNT(p.id) > 10
`
```

### Drizzle

```typescript
// ✅ Type-safe queries
const users = await db
  .select({
    id: users.id,
    name: users.name,
    postCount: count(posts.id)
  })
  .from(users)
  .leftJoin(posts, eq(posts.userId, users.id))
  .groupBy(users.id, users.name)
  .where(eq(users.isActive, true))

// ✅ Prepared statements
const getUser = db
  .select()
  .from(users)
  .where(eq(users.id, placeholder('id')))
  .prepare()

const user = await getUser.execute({ id: '123' })
```

## 🔒 Security

### SQL Injection Prevention

```typescript
// ❌ Never concatenate user input
const query = `SELECT * FROM users WHERE email = '${userEmail}'`
// Vulnerable to: ' OR '1'='1

// ✅ Use parameterized queries
const query = 'SELECT * FROM users WHERE email = $1'
const result = await db.query(query, [userEmail])

// ✅ Use ORM (automatically parameterized)
const user = await db.user.findUnique({ where: { email: userEmail } })
```

### Access Control

```sql
-- ✅ Use database roles (PostgreSQL)
CREATE ROLE app_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_readonly;

CREATE ROLE app_readwrite;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_readwrite;

-- ✅ Row-level security (PostgreSQL)
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_posts ON posts
  FOR ALL
  USING (user_id = current_setting('app.user_id')::uuid);
```

## 📊 Monitoring

### Slow Query Logging

```sql
-- PostgreSQL: log queries slower than 100ms
ALTER SYSTEM SET log_min_duration_statement = 100;
SELECT pg_reload_conf();

-- Review logs
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

### Connection Pooling

```typescript
// ✅ Use connection pooling
const pool = new Pool({
  host: 'localhost',
  database: 'mydb',
  max: 20,                // Maximum pool size
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000
})

// ✅ Always close connections
const client = await pool.connect()
try {
  await client.query('SELECT * FROM users')
} finally {
  client.release()
}
```

## 🧹 Maintenance

### Vacuuming (PostgreSQL)

```sql
-- ✅ Analyze tables after large changes
ANALYZE users;

-- ✅ Vacuum to reclaim space
VACUUM users;

-- ✅ Auto-vacuum (usually enabled by default)
ALTER TABLE users SET (autovacuum_vacuum_scale_factor = 0.1);
```

### Backup Strategy

```bash
# ✅ Regular backups
pg_dump -U postgres mydb > backup_$(date +%Y%m%d).sql

# ✅ Point-in-time recovery (PostgreSQL)
# Enable WAL archiving in postgresql.conf
archive_mode = on
archive_command = 'cp %p /path/to/archive/%f'
```

## 📚 Database Checklist

- [ ] All tables have primary keys
- [ ] Foreign keys have indexes
- [ ] Frequently queried columns are indexed
- [ ] No SELECT * in production code
- [ ] Timestamps (created_at, updated_at) on all tables
- [ ] Soft deletes for important data
- [ ] Migrations are reversible
- [ ] Slow query monitoring enabled
- [ ] Connection pooling configured
- [ ] Regular backups scheduled
- [ ] Query performance tested with production-like data

---

**Tools**: Prisma, Drizzle, pg_stat_statements, EXPLAIN ANALYZE
**Review frequency**: Monitor slow queries weekly, audit schema quarterly
