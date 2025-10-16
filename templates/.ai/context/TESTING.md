# Testing Guidelines

> Testing strategy and best practices for {{PROJECT_NAME}}

## 🎯 Testing Philosophy

- **Test behavior, not implementation** - Focus on what, not how
- **Maintain high coverage** - Aim for >80% for business logic
- **Fast feedback loop** - Tests should run quickly
- **Tests as documentation** - Tests should explain intent
- **Test early, test often** - Write tests as you code

## 📊 Testing Strategy

### Test Pyramid

```
       /\
      /  \      E2E Tests (5-10%)
     /____\     - Full user flows
    /      \    - Critical paths only
   /________\
  /          \  Integration Tests (20-30%)
 /____________\ - API endpoints
/              \- Database queries
/                \
/                  \
/____________________\ Unit Tests (60-80%)
                        - Pure functions
                        - Business logic
                        - Components
```

### Coverage Goals

| Code Type | Target Coverage | Priority |
|-----------|----------------|----------|
| Business Logic | >90% | Critical |
| API Endpoints | >80% | High |
| UI Components | >70% | Medium |
| Utilities | >90% | High |
| Types/Interfaces | N/A | N/A |

## 🧪 Unit Tests

### What to Test

```typescript
// ✅ Test pure functions
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0)
}

test('calculateTotal sums item prices', () => {
  const items = [
    { price: 10 },
    { price: 20 },
    { price: 30 }
  ]
  expect(calculateTotal(items)).toBe(60)
})

// ✅ Test business logic
function canUserAccess(user: User, resource: Resource): boolean {
  if (!user.active) return false
  if (user.role === 'admin') return true
  return resource.ownerId === user.id
}

test('admin can access any resource', () => {
  const admin = { id: '1', role: 'admin', active: true }
  const resource = { ownerId: '2' }
  expect(canUserAccess(admin, resource)).toBe(true)
})

test('inactive users cannot access resources', () => {
  const user = { id: '1', role: 'user', active: false }
  const resource = { ownerId: '1' }
  expect(canUserAccess(user, resource)).toBe(false)
})
```

### Test Structure

```typescript
// ✅ Arrange-Act-Assert pattern
describe('UserService', () => {
  describe('createUser', () => {
    it('creates a user with valid data', async () => {
      // Arrange
      const userData = {
        name: 'John Doe',
        email: 'john@example.com'
      }
      const mockRepo = createMockRepository()

      // Act
      const user = await userService.createUser(userData)

      // Assert
      expect(user).toBeDefined()
      expect(user.email).toBe('john@example.com')
      expect(mockRepo.save).toHaveBeenCalledWith(userData)
    })

    it('throws error for invalid email', async () => {
      // Arrange
      const userData = {
        name: 'John Doe',
        email: 'invalid-email'
      }

      // Act & Assert
      await expect(userService.createUser(userData))
        .rejects
        .toThrow('Invalid email')
    })
  })
})
```

### Test Naming

```typescript
// ✅ Descriptive test names
describe('Authentication', () => {
  it('allows login with valid credentials')
  it('rejects login with invalid password')
  it('locks account after 5 failed attempts')
  it('sends password reset email to registered users')
})

// ❌ Vague test names
it('works') // What works?
it('test1')  // Not descriptive
it('should do something') // Be specific
```

## 🔗 Integration Tests

### API Testing

```typescript
// ✅ Test API endpoints
describe('POST /api/users', () => {
  it('creates a new user', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({
        name: 'John Doe',
        email: 'john@example.com'
      })

    expect(response.status).toBe(201)
    expect(response.body).toMatchObject({
      id: expect.any(String),
      name: 'John Doe',
      email: 'john@example.com'
    })

    // Verify database
    const user = await db.user.findUnique({
      where: { email: 'john@example.com' }
    })
    expect(user).toBeDefined()
  })

  it('returns 400 for invalid data', async () => {
    const response = await request(app)
      .post('/api/users')
      .send({ name: 'John' }) // Missing email

    expect(response.status).toBe(400)
    expect(response.body.error).toContain('email')
  })
})
```

### Database Testing

```typescript
// ✅ Test database operations
describe('UserRepository', () => {
  beforeEach(async () => {
    await db.user.deleteMany() // Clean slate
  })

  it('finds user by email', async () => {
    // Arrange
    await db.user.create({
      data: {
        name: 'John Doe',
        email: 'john@example.com'
      }
    })

    // Act
    const user = await userRepository.findByEmail('john@example.com')

    // Assert
    expect(user).toBeDefined()
    expect(user?.name).toBe('John Doe')
  })

  it('returns null for non-existent email', async () => {
    const user = await userRepository.findByEmail('nonexistent@example.com')
    expect(user).toBeNull()
  })
})
```

## 🌐 End-to-End Tests

### User Flow Testing

```typescript
// ✅ Test critical user flows
import { test, expect } from '@playwright/test'

test('user can sign up and create a post', async ({ page }) => {
  // Navigate to signup
  await page.goto('/signup')

  // Fill signup form
  await page.fill('[name="email"]', 'user@example.com')
  await page.fill('[name="password"]', 'SecurePass123!')
  await page.click('button[type="submit"]')

  // Verify redirect to dashboard
  await expect(page).toHaveURL('/dashboard')

  // Create a post
  await page.click('text=New Post')
  await page.fill('[name="title"]', 'My First Post')
  await page.fill('[name="content"]', 'Hello, world!')
  await page.click('text=Publish')

  // Verify post appears
  await expect(page.locator('text=My First Post')).toBeVisible()
})
```

### When to Write E2E Tests

- Critical user flows (signup, checkout, payment)
- Features that integrate multiple systems
- Smoke tests for production deployments
- Regression tests for past critical bugs

## 🎭 Mocking & Stubbing

### When to Mock

```typescript
// ✅ Mock external dependencies
describe('EmailService', () => {
  it('sends welcome email on signup', async () => {
    // Mock SMTP client
    const mockSmtp = {
      sendMail: vi.fn().mockResolvedValue({ messageId: '123' })
    }

    const emailService = new EmailService(mockSmtp)
    await emailService.sendWelcomeEmail('user@example.com')

    expect(mockSmtp.sendMail).toHaveBeenCalledWith(
      expect.objectContaining({
        to: 'user@example.com',
        subject: 'Welcome!'
      })
    )
  })
})

// ✅ Mock expensive operations
describe('DataProcessor', () => {
  it('processes data correctly', async () => {
    const mockAiService = {
      analyze: vi.fn().mockResolvedValue({ sentiment: 'positive' })
    }

    const result = await processData(data, mockAiService)
    expect(result.sentiment).toBe('positive')
  })
})
```

### What NOT to Mock

```typescript
// ❌ Don't mock what you're testing
describe('calculateTotal', () => {
  it('sums item prices', () => {
    const mockCalculate = vi.fn().mockReturnValue(60)
    // This tests the mock, not the real function!
  })
})

// ❌ Don't mock simple utilities
describe('formatDate', () => {
  // Don't mock date-fns, just test it
  const result = formatDate(new Date('2025-01-01'))
  expect(result).toBe('January 1, 2025')
})
```

## 🔧 Test Utilities

### Test Factories

```typescript
// ✅ Create test data factories
export function createTestUser(overrides?: Partial<User>): User {
  return {
    id: randomUUID(),
    name: 'Test User',
    email: 'test@example.com',
    role: 'user',
    active: true,
    createdAt: new Date(),
    ...overrides
  }
}

// Usage
const admin = createTestUser({ role: 'admin' })
const inactive = createTestUser({ active: false })
```

### Custom Matchers

```typescript
// ✅ Create reusable matchers
expect.extend({
  toBeValidEmail(received: string) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    const pass = emailRegex.test(received)

    return {
      pass,
      message: () =>
        pass
          ? `expected ${received} not to be a valid email`
          : `expected ${received} to be a valid email`
    }
  }
})

// Usage
expect('user@example.com').toBeValidEmail()
```

## 📦 Test Organization

### File Structure

```
src/
├── services/
│   ├── user.service.ts
│   └── user.service.test.ts      # Co-located tests
├── utils/
│   ├── format.ts
│   └── format.test.ts
└── __tests__/
    ├── integration/               # Integration tests
    │   └── api.test.ts
    └── e2e/                       # E2E tests
        └── user-flow.spec.ts
```

### Test Grouping

```typescript
describe('UserService', () => {
  // Group related tests
  describe('authentication', () => {
    describe('login', () => {
      it('succeeds with valid credentials')
      it('fails with invalid password')
      it('locks after failed attempts')
    })

    describe('logout', () => {
      it('clears session')
      it('invalidates refresh token')
    })
  })

  describe('profile management', () => {
    it('updates user profile')
    it('uploads avatar')
  })
})
```

## 🎯 Best Practices

### DRY in Tests

```typescript
// ✅ Extract common setup
describe('UserController', () => {
  let app: Express
  let testUser: User

  beforeEach(async () => {
    app = await createTestApp()
    testUser = await createTestUser()
  })

  afterEach(async () => {
    await cleanupDatabase()
  })

  // Tests use shared setup
})
```

### Test Independence

```typescript
// ✅ Each test should be independent
it('test 1', () => {
  const data = createTestData() // Don't rely on previous tests
  // ...
})

it('test 2', () => {
  const data = createTestData() // Create own data
  // ...
})

// ❌ Don't share state between tests
let sharedData // Avoid this!

it('test 1', () => {
  sharedData = something // Bad!
})

it('test 2', () => {
  expect(sharedData).toBe(something) // Depends on test 1!
})
```

### Testing Errors

```typescript
// ✅ Test error cases
describe('divide', () => {
  it('divides two numbers', () => {
    expect(divide(10, 2)).toBe(5)
  })

  it('throws error when dividing by zero', () => {
    expect(() => divide(10, 0)).toThrow('Division by zero')
  })

  it('handles invalid inputs', () => {
    expect(() => divide(NaN, 5)).toThrow('Invalid number')
  })
})
```

### Async Testing

```typescript
// ✅ Always await async operations
it('fetches user data', async () => {
  const user = await fetchUser('123')
  expect(user).toBeDefined()
})

// ✅ Test async errors
it('handles fetch errors', async () => {
  await expect(fetchUser('invalid'))
    .rejects
    .toThrow('User not found')
})

// ✅ Use fake timers for time-based tests
it('retries after timeout', async () => {
  vi.useFakeTimers()

  const promise = retryOperation()
  vi.advanceTimersByTime(5000)

  await expect(promise).resolves.toBe(true)
  vi.useRealTimers()
})
```

## 📊 Test Coverage

### Running Coverage

```bash
# Generate coverage report
npm run test:coverage

# View in browser
open coverage/index.html
```

### What Coverage Means

```typescript
// 100% line coverage doesn't mean 100% tested!

function divide(a: number, b: number): number {
  return a / b // ✅ Line covered
}

// Test only happy path
it('divides', () => {
  expect(divide(10, 2)).toBe(5) // What about divide by zero?
})

// ✅ Better coverage
it('handles division by zero', () => {
  expect(() => divide(10, 0)).toThrow()
})
```

## 🚀 CI/CD Integration

### GitHub Actions Example

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npm run test:ci
      - run: npm run test:e2e
      - uses: codecov/codecov-action@v4
        with:
          files: ./coverage/coverage-final.json
```

## 🔍 Test Quality Checklist

- [ ] Tests are fast (< 10ms for unit tests)
- [ ] Tests are isolated and independent
- [ ] Tests are deterministic (no random failures)
- [ ] Test names clearly describe what is tested
- [ ] Happy path and error cases are covered
- [ ] Edge cases are tested
- [ ] Tests use AAA pattern (Arrange-Act-Assert)
- [ ] No commented-out tests
- [ ] No `.only` or `.skip` in committed code
- [ ] Mocks are used appropriately
- [ ] Test data is meaningful, not random

---

**Tools**: Vitest, Jest, Playwright, Cypress, Testing Library
**Review frequency**: Update with testing strategy changes
