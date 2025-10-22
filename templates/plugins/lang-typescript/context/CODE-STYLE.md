# TypeScript Code Style

> TypeScript coding standards for {{PROJECT_NAME}}

## 🎯 TypeScript Configuration

### tsconfig.json Essentials

```json
{
  "compilerOptions": {
    "strict": true,
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "noUncheckedIndexedAccess": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

## 🔤 Type Definitions

### Prefer Types over Interfaces

```typescript
// ✅ Use type for most cases
type User = {
  id: string
  name: string
  email: string
}

// ✅ Use interface only for:
// - When you need declaration merging
// - Public APIs that might be extended

interface ApiResponse {
  data: unknown
  status: number
}
```

### Type Naming

```typescript
// ✅ Use PascalCase for types
type UserProfile = {
  // ...
}

// ✅ Don't prefix with 'I' or 'T'
// ❌ Bad
interface IUser {}
type TUser = {}

// ✅ Good
type User = {}
type UserOptions = {}

// ✅ For union/discriminated unions, be descriptive
type Status = 'pending' | 'approved' | 'rejected'
type Result<T> = Success<T> | Failure
```

### Avoid Enums

```typescript
// ❌ Don't use enums
enum Status {
  Pending = 'pending',
  Approved = 'approved'
}

// ✅ Use const objects or union types
const Status = {
  Pending: 'pending',
  Approved: 'approved',
  Rejected: 'rejected'
} as const

type StatusType = typeof Status[keyof typeof Status]

// ✅ Or simple union types
type Status = 'pending' | 'approved' | 'rejected'
```

## 📝 Type Annotations

### When to Annotate

```typescript
// ✅ Annotate function parameters
function getUser(id: string): Promise<User> {
  // ...
}

// ✅ Annotate function returns for public APIs
export function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0)
}

// ✅ Let TypeScript infer variable types
const user = getUser('123') // Type is inferred
const count = items.length   // Type is inferred

// ❌ Don't annotate when obvious
const name: string = 'John' // Redundant
const isActive: boolean = true // Redundant
```

### Type Imports

```typescript
// ✅ Use type imports
import type { User, Post } from './types'
import { getUserData } from './api'

// ✅ Inline type imports
import { type ReactNode, useState } from 'react'

// This helps with tree-shaking and makes intent clear
```

## 🎨 Advanced Types

### Utility Types

```typescript
// ✅ Use built-in utility types
type PartialUser = Partial<User>
type RequiredUser = Required<User>
type ReadonlyUser = Readonly<User>
type UserWithoutEmail = Omit<User, 'email'>
type UserIdAndName = Pick<User, 'id' | 'name'>

// ✅ Create reusable generic types
type ApiResponse<T> = {
  data: T
  meta: {
    page: number
    total: number
  }
}

type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E }
```

### Discriminated Unions

```typescript
// ✅ Use discriminated unions for state
type LoadingState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: User }
  | { status: 'error'; error: string }

function handleState(state: LoadingState) {
  switch (state.status) {
    case 'idle':
      return 'Not started'
    case 'loading':
      return 'Loading...'
    case 'success':
      return `Welcome, ${state.data.name}` // data available here
    case 'error':
      return `Error: ${state.error}` // error available here
  }
}
```

### Template Literal Types

```typescript
// ✅ Use template literals for string patterns
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE'
type Endpoint = `/api/${string}`
type Route = `${HttpMethod} ${Endpoint}`

// Example: 'GET /api/users' | 'POST /api/posts' etc.
```

### Conditional Types

```typescript
// ✅ Extract types conditionally
type Awaited<T> = T extends Promise<infer U> ? U : T
type ArrayElement<T> = T extends (infer U)[] ? U : never

// ✅ Useful for function overloads
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never
```

## 🔧 Type Guards

### Custom Type Guards

```typescript
// ✅ Create type guards for runtime checks
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value &&
    'email' in value
  )
}

// Usage
if (isUser(data)) {
  console.log(data.email) // TypeScript knows it's a User
}

// ✅ Use zod for complex validation
import { z } from 'zod'

const UserSchema = z.object({
  id: z.string(),
  name: z.string(),
  email: z.string().email(),
  age: z.number().min(0)
})

type User = z.infer<typeof UserSchema>

// Runtime validation with type safety
const user = UserSchema.parse(data)
```

### Narrowing

```typescript
// ✅ Use type narrowing
function processValue(value: string | number) {
  if (typeof value === 'string') {
    return value.toUpperCase() // string methods available
  }
  return value.toFixed(2) // number methods available
}

// ✅ Discriminated union narrowing
function handle(response: ApiResponse) {
  if (response.success) {
    console.log(response.data) // data available
  } else {
    console.error(response.error) // error available
  }
}
```

## 🚫 Avoid Any

```typescript
// ❌ Never use 'any'
function bad(data: any) {
  // Type safety lost
}

// ✅ Use 'unknown' for truly unknown types
function good(data: unknown) {
  if (isUser(data)) {
    // Now we know it's a User
    console.log(data.email)
  }
}

// ✅ Use generics when appropriate
function process<T>(data: T): T {
  return data
}

// ✅ Use type assertions only when necessary
const user = data as User // Only if you're absolutely sure!
```

## 🎯 Function Types

### Function Signatures

```typescript
// ✅ Type function parameters and returns
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0)
}

// ✅ Async functions
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`)
  return response.json()
}

// ✅ Function type
type Callback = (error: Error | null, data?: User) => void
type AsyncFn<T> = () => Promise<T>
type Predicate<T> = (value: T) => boolean
```

### Generics

```typescript
// ✅ Use meaningful generic names
type Response<TData> = {
  data: TData
  status: number
}

// ✅ Generic constraints
function first<T extends { id: string }>(items: T[]): T | undefined {
  return items[0]
}

// ✅ Default generic parameters
type ApiCall<TData = unknown, TError = Error> = {
  // ...
}

// ✅ Multiple generics
function map<TInput, TOutput>(
  items: TInput[],
  fn: (item: TInput) => TOutput
): TOutput[] {
  return items.map(fn)
}
```

## 📦 Modules and Imports

### Module Organization

```typescript
// user.types.ts
export type User = {
  id: string
  name: string
  email: string
}

export type UserCreateInput = Omit<User, 'id'>
export type UserUpdateInput = Partial<UserCreateInput>

// user.service.ts
import type { User, UserCreateInput } from './user.types'

export class UserService {
  async create(input: UserCreateInput): Promise<User> {
    // ...
  }
}
```

### Re-exports

```typescript
// index.ts - Barrel export
export type { User, UserCreateInput, UserUpdateInput } from './user.types'
export { UserService } from './user.service'

// Usage
import { type User, UserService } from './users'
```

## 🎨 React + TypeScript

### Component Types

```typescript
// ✅ Use type for props
type ButtonProps = {
  children: React.ReactNode
  onClick: () => void
  variant?: 'primary' | 'secondary'
  disabled?: boolean
}

export function Button({ children, onClick, variant = 'primary', disabled }: ButtonProps) {
  return (
    <button onClick={onClick} disabled={disabled} className={variant}>
      {children}
    </button>
  )
}

// ✅ Generic components
type ListProps<T> = {
  items: T[]
  renderItem: (item: T) => React.ReactNode
}

export function List<T>({ items, renderItem }: ListProps<T>) {
  return <ul>{items.map(renderItem)}</ul>
}
```

### Hooks

```typescript
// ✅ Type useState
const [user, setUser] = useState<User | null>(null)
const [count, setCount] = useState(0) // Inferred as number

// ✅ Type useRef
const inputRef = useRef<HTMLInputElement>(null)

// ✅ Type custom hooks
function useUser(id: string) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(false)

  // ...

  return { user, loading } // Return type inferred
}

// ✅ Type event handlers
const handleClick = (event: React.MouseEvent<HTMLButtonElement>) => {
  event.preventDefault()
  // ...
}

const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
  setValue(event.target.value)
}
```

## 🔍 Strict Null Checks

```typescript
// ✅ Handle null/undefined explicitly
function getUsername(user: User | null): string {
  // Option 1: Guard clause
  if (!user) return 'Guest'
  return user.name

  // Option 2: Nullish coalescing
  return user?.name ?? 'Guest'
}

// ✅ Use noUncheckedIndexedAccess
const item = array[0] // Type: Item | undefined (not just Item)

if (item) {
  // Now TypeScript knows item exists
  console.log(item.name)
}
```

## ⚡ Performance

### Type-Only Imports

```typescript
// ✅ Type-only imports don't affect bundle
import type { User } from './types' // Stripped at compile time
import { getUser } from './api'     // Included in bundle
```

### Const Assertions

```typescript
// ✅ Use const assertions for literals
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000
} as const

// Type: { readonly apiUrl: "https://api.example.com", readonly timeout: 5000 }

// ✅ For arrays
const colors = ['red', 'green', 'blue'] as const
// Type: readonly ["red", "green", "blue"]
```

## 📚 Best Practices

### DRY with Types

```typescript
// ✅ Create reusable types
type Timestamps = {
  createdAt: Date
  updatedAt: Date
}

type Entity = {
  id: string
} & Timestamps

type User = Entity & {
  name: string
  email: string
}

type Post = Entity & {
  title: string
  content: string
}
```

### Branded Types

```typescript
// ✅ Create branded types for IDs
type UserId = string & { readonly brand: unique symbol }
type PostId = string & { readonly brand: unique symbol }

function getUser(id: UserId): User {
  // ...
}

// Prevents mixing up IDs
const userId: UserId = '123' as UserId
const postId: PostId = '456' as PostId

getUser(userId) // ✅ OK
getUser(postId) // ❌ Error: PostId is not assignable to UserId
```

### Type-Safe Builders

```typescript
// ✅ Type-safe builder pattern
class UserBuilder {
  private user: Partial<User> = {}

  setName(name: string): this {
    this.user.name = name
    return this
  }

  setEmail(email: string): this {
    this.user.email = email
    return this
  }

  build(): User {
    if (!this.user.name || !this.user.email) {
      throw new Error('Missing required fields')
    }
    return this.user as User
  }
}
```

## 🧪 Testing

```typescript
// ✅ Type test utilities
import { expectType } from 'tsd'

expectType<string>(getUserName())
expectType<Promise<User>>(fetchUser('123'))

// ✅ Mock types
type MockUser = Pick<User, 'id' | 'name'>

const mockUser: MockUser = {
  id: '123',
  name: 'Test User'
}
```

---

**Tools**: TypeScript, ts-node, tsx, tsd
**Review frequency**: When TypeScript releases major versions
