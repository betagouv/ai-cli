# API Design Guidelines

> API design conventions for {{PROJECT_NAME}}

## 🎯 General Principles

- **Consistency**: Follow patterns across all endpoints
- **Predictability**: Developers should be able to guess the API
- **RESTful** (or GraphQL/tRPC): Choose one pattern and stick to it
- **Documentation**: Every endpoint must be documented
- **Versioning**: Plan for breaking changes from day one

## 🌐 REST API Design

### Resource Naming

```bash
# ✅ Use nouns for resources (not verbs)
GET    /users              # Get all users
GET    /users/123          # Get specific user
POST   /users              # Create user
PUT    /users/123          # Update user (full)
PATCH  /users/123          # Update user (partial)
DELETE /users/123          # Delete user

# ✅ Use plural nouns
/users   not /user
/posts   not /post

# ✅ Nested resources
GET /users/123/posts       # Get posts by user 123
GET /posts/456/comments    # Get comments on post 456

# ❌ Don't use verbs in URLs
POST /createUser           # Bad
GET  /getUserById/123      # Bad
POST /users/123/delete     # Bad
```

### HTTP Methods

```
GET     - Retrieve resource(s)       - Idempotent, cacheable
POST    - Create new resource        - Not idempotent
PUT     - Replace entire resource    - Idempotent
PATCH   - Update part of resource    - Not idempotent
DELETE  - Remove resource            - Idempotent
```

### Status Codes

```typescript
// ✅ Use appropriate status codes

// 2xx Success
200 OK                  // Successful GET, PUT, PATCH, DELETE
201 Created            // Successful POST
204 No Content         // Successful DELETE or update with no response body

// 3xx Redirection
301 Moved Permanently  // Resource permanently moved
304 Not Modified       // Cached resource hasn't changed

// 4xx Client Errors
400 Bad Request        // Invalid input
401 Unauthorized       // Not authenticated
403 Forbidden          // Authenticated but not authorized
404 Not Found          // Resource doesn't exist
409 Conflict           // Constraint violation (duplicate, etc.)
422 Unprocessable      // Validation failed
429 Too Many Requests  // Rate limited

// 5xx Server Errors
500 Internal Error     // Server error
502 Bad Gateway        // Upstream service error
503 Service Unavailable // Server overloaded or down
```

### Request/Response Format

```typescript
// ✅ Request with validation
POST /api/users
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "age": 30
}

// ✅ Successful response
HTTP/1.1 201 Created
Content-Type: application/json

{
  "id": "usr_123",
  "name": "John Doe",
  "email": "john@example.com",
  "age": 30,
  "createdAt": "2025-01-15T10:30:00Z",
  "updatedAt": "2025-01-15T10:30:00Z"
}

// ✅ Error response
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format"
      },
      {
        "field": "age",
        "message": "Must be at least 18"
      }
    ]
  }
}
```

### Pagination

```typescript
// ✅ Cursor-based pagination (recommended for large datasets)
GET /api/posts?cursor=eyJpZCI6MTIzfQ&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6MTQzfQ",
    "hasMore": true
  }
}

// ✅ Offset pagination (simpler, less efficient)
GET /api/posts?page=2&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 20,
    "total": 150,
    "totalPages": 8,
    "hasNext": true,
    "hasPrev": true
  }
}
```

### Filtering, Sorting, Search

```typescript
// ✅ Filtering
GET /api/users?status=active&role=admin

// ✅ Sorting
GET /api/posts?sort=-createdAt,title
// - prefix means descending

// ✅ Field selection
GET /api/users?fields=id,name,email

// ✅ Search
GET /api/posts?q=typescript&status=published

// ✅ Complex filtering (JSON)
GET /api/users?filter={"age":{"$gt":18},"status":"active"}
```

## 🔄 Versioning

### URL Versioning (Recommended)

```typescript
// ✅ Version in URL path
GET /api/v1/users
GET /api/v2/users

// Benefits:
// - Clear and visible
// - Easy to route
// - Works with all HTTP clients
```

### Header Versioning

```typescript
// Alternative: Version in header
GET /api/users
Accept: application/vnd.myapi.v2+json

// Benefits:
// - Cleaner URLs
// - More RESTful
```

### Version Strategy

```typescript
// ✅ Maintain multiple versions
// v1 (stable)
GET /api/v1/users -> { "user_name": "..." }

// v2 (breaking changes)
GET /api/v2/users -> { "userName": "..." }

// ✅ Deprecation policy
// 1. Announce deprecation 6 months in advance
// 2. Support old version for 12 months
// 3. Return deprecation warning in headers

Response Headers:
Deprecation: true
Sunset: Sat, 1 Jul 2025 23:59:59 GMT
Link: </api/v2/users>; rel="successor-version"
```

## ⚡ GraphQL API Design

### Schema Design

```graphql
# ✅ Well-structured schema
type User {
  id: ID!
  name: String!
  email: String!
  posts: [Post!]!
  createdAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
  comments: [Comment!]!
  publishedAt: DateTime
}

type Query {
  user(id: ID!): User
  users(limit: Int, cursor: String): UserConnection!
  post(id: ID!): Post
  posts(filter: PostFilter): PostConnection!
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  deleteUser(id: ID!): Boolean!
}

input CreateUserInput {
  name: String!
  email: String!
}

# ✅ Pagination types
type UserConnection {
  edges: [UserEdge!]!
  pageInfo: PageInfo!
}

type UserEdge {
  node: User!
  cursor: String!
}

type PageInfo {
  hasNextPage: Boolean!
  endCursor: String
}
```

### Resolver Best Practices

```typescript
// ✅ Use DataLoader to avoid N+1 queries
const postLoader = new DataLoader(async (postIds) => {
  const posts = await db.post.findMany({
    where: { id: { in: postIds } }
  })
  return postIds.map(id => posts.find(p => p.id === id))
})

const resolvers = {
  User: {
    posts: (user, args, context) => {
      return context.postLoader.load(user.id)
    }
  }
}

// ✅ Handle errors gracefully
const resolvers = {
  Query: {
    user: async (parent, { id }, context) => {
      const user = await context.db.user.findUnique({ where: { id } })

      if (!user) {
        throw new GraphQLError('User not found', {
          extensions: { code: 'USER_NOT_FOUND' }
        })
      }

      return user
    }
  }
}
```

## 🔧 tRPC API Design

### Router Structure

```typescript
// ✅ Organized routers
import { router } from './trpc'
import { userRouter } from './routers/user'
import { postRouter } from './routers/post'

export const appRouter = router({
  user: userRouter,
  post: postRouter,
})

// user.router.ts
export const userRouter = router({
  getById: publicProcedure
    .input(z.object({ id: z.string() }))
    .query(async ({ input }) => {
      return await db.user.findUnique({ where: { id: input.id } })
    }),

  create: publicProcedure
    .input(z.object({
      name: z.string(),
      email: z.string().email()
    }))
    .mutation(async ({ input }) => {
      return await db.user.create({ data: input })
    }),

  list: publicProcedure
    .input(z.object({
      limit: z.number().min(1).max(100).default(10),
      cursor: z.string().optional()
    }))
    .query(async ({ input }) => {
      const users = await db.user.findMany({
        take: input.limit + 1,
        cursor: input.cursor ? { id: input.cursor } : undefined
      })

      let nextCursor: string | undefined
      if (users.length > input.limit) {
        const nextUser = users.pop()
        nextCursor = nextUser!.id
      }

      return { users, nextCursor }
    })
})
```

### Middleware & Auth

```typescript
// ✅ Auth middleware
const isAuthed = middleware(({ ctx, next }) => {
  if (!ctx.user) {
    throw new TRPCError({ code: 'UNAUTHORIZED' })
  }
  return next({
    ctx: {
      user: ctx.user
    }
  })
})

const protectedProcedure = publicProcedure.use(isAuthed)

// Usage
export const userRouter = router({
  me: protectedProcedure
    .query(({ ctx }) => {
      return ctx.user // Type-safe!
    })
})
```

## 🔒 Authentication & Authorization

### JWT Authentication

```typescript
// ✅ Token-based auth
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "secret"
}

Response:
{
  "accessToken": "eyJhbGc...",  // Short-lived (15min)
  "refreshToken": "dGVzdC...",  // Long-lived (30 days)
  "expiresIn": 900
}

// ✅ Protected endpoint
GET /api/users/me
Authorization: Bearer eyJhbGc...

// ✅ Refresh token
POST /api/auth/refresh
{
  "refreshToken": "dGVzdC..."
}
```

### API Keys

```typescript
// ✅ API key auth (for services)
GET /api/data
X-API-Key: sk_live_123456789

// ✅ Rate limiting per key
Response Headers:
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640000000
```

## 📊 Error Handling

### Standard Error Format

```typescript
// ✅ Consistent error structure
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "email",
        "message": "Invalid email format",
        "value": "notanemail"
      }
    ],
    "requestId": "req_abc123",
    "timestamp": "2025-01-15T10:30:00Z"
  }
}

// ✅ Error codes
enum ErrorCode {
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  NOT_FOUND = 'NOT_FOUND',
  UNAUTHORIZED = 'UNAUTHORIZED',
  FORBIDDEN = 'FORBIDDEN',
  RATE_LIMITED = 'RATE_LIMITED',
  INTERNAL_ERROR = 'INTERNAL_ERROR'
}
```

### Error Response Examples

```typescript
// ✅ Validation error (400)
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [...]
  }
}

// ✅ Not found (404)
{
  "error": {
    "code": "NOT_FOUND",
    "message": "User not found",
    "resourceType": "User",
    "resourceId": "123"
  }
}

// ✅ Rate limit (429)
{
  "error": {
    "code": "RATE_LIMITED",
    "message": "Too many requests",
    "retryAfter": 60
  }
}
```

## 🚀 Performance

### Caching

```typescript
// ✅ Cache headers
GET /api/posts/123

Response Headers:
Cache-Control: public, max-age=3600
ETag: "abc123"

// ✅ Conditional requests
GET /api/posts/123
If-None-Match: "abc123"

Response:
304 Not Modified
```

### Compression

```typescript
// ✅ Enable compression
Response Headers:
Content-Encoding: gzip
Vary: Accept-Encoding
```

### Rate Limiting

```typescript
// ✅ Rate limit headers
Response Headers:
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 99
X-RateLimit-Reset: 1640000000
Retry-After: 3600
```

## 📚 Documentation

### OpenAPI/Swagger (REST)

```yaml
openapi: 3.0.0
info:
  title: My API
  version: 1.0.0

paths:
  /users:
    get:
      summary: List users
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
      responses:
        '200':
          description: Success
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
```

### API Documentation Checklist

- [ ] Every endpoint documented
- [ ] Request/response examples
- [ ] Error responses documented
- [ ] Authentication explained
- [ ] Rate limits specified
- [ ] Changelog maintained

---

**Tools**: OpenAPI, GraphQL Playground, tRPC Panel
**Review frequency**: With each API version release
