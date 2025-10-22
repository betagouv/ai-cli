# Go Code Style

> Go coding standards for {{PROJECT_NAME}}

## 🎯 General Principles

- Follow the official [Effective Go](https://golang.org/doc/effective_go.html) guidelines
- Use `gofmt` to format code (non-negotiable)
- Keep code simple and idiomatic
- Prefer clarity over cleverness

## 📁 Project Structure

```
project/
├── cmd/
│   └── app/
│       └── main.go          # Application entrypoint
├── internal/
│   ├── api/                 # HTTP handlers
│   ├── service/             # Business logic
│   ├── repository/          # Data access
│   └── model/               # Data models
├── pkg/                     # Public packages
├── config/                  # Configuration
└── migrations/              # Database migrations
```

## 🔤 Naming Conventions

### Packages

```go
// ✅ Use short, single-word names
package user
package http
package config

// ❌ Avoid underscores or mixed caps
package user_service  // Bad
package userService   // Bad
```

### Variables

```go
// ✅ Use camelCase for unexported
var userCount int
var isActive bool

// ✅ Use PascalCase for exported
var MaxConnections int
var DefaultTimeout time.Duration

// ✅ Use short names in small scopes
for i := 0; i < 10; i++ {
    // i is fine here
}

// ✅ Descriptive names for longer scopes
func ProcessUserData(userID string) error {
    // Use full names in longer functions
}
```

### Functions

```go
// ✅ Exported functions use PascalCase
func GetUser(id string) (*User, error) {
    // ...
}

// ✅ Unexported functions use camelCase
func validateEmail(email string) bool {
    // ...
}

// ✅ Use verb+noun pattern
func CreateUser() {}
func DeletePost() {}
func ValidateInput() {}
```

### Interfaces

```go
// ✅ Single-method interfaces end with 'er'
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

// ✅ Multi-method interfaces use descriptive names
type UserRepository interface {
    Get(id string) (*User, error)
    Create(user *User) error
    Update(user *User) error
    Delete(id string) error
}
```

## 🎨 Code Style

### Error Handling

```go
// ✅ Check errors immediately
result, err := doSomething()
if err != nil {
    return nil, fmt.Errorf("failed to do something: %w", err)
}

// ✅ Use fmt.Errorf with %w to wrap errors
if err := processData(); err != nil {
    return fmt.Errorf("processing failed: %w", err)
}

// ✅ Create custom error types for specific cases
type ValidationError struct {
    Field string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

// ✅ Use errors.Is and errors.As
if errors.Is(err, ErrNotFound) {
    // Handle not found
}

var validationErr *ValidationError
if errors.As(err, &validationErr) {
    // Handle validation error
}
```

### Struct Definition

```go
// ✅ Group related fields
type User struct {
    // Identity
    ID        string    `json:"id"`
    Email     string    `json:"email"`

    // Profile
    Name      string    `json:"name"`
    Avatar    string    `json:"avatar"`

    // Metadata
    CreatedAt time.Time `json:"createdAt"`
    UpdatedAt time.Time `json:"updatedAt"`
}

// ✅ Use struct tags for JSON, DB, etc.
type User struct {
    ID    string `json:"id" db:"id"`
    Name  string `json:"name" db:"name"`
    Email string `json:"email" db:"email"`
}
```

### Methods

```go
// ✅ Use pointer receivers for mutating methods
func (u *User) SetName(name string) {
    u.Name = name
}

// ✅ Use value receivers for read-only methods
func (u User) FullName() string {
    return fmt.Sprintf("%s %s", u.FirstName, u.LastName)
}

// ✅ Be consistent: if one method uses pointer, all should
type User struct {
    Name string
}

func (u *User) SetName(name string) { u.Name = name }
func (u *User) GetName() string { return u.Name } // Pointer for consistency
```

## 🔧 Go-Specific Patterns

### Initialization

```go
// ✅ Use init functions sparingly
func init() {
    // Only for truly necessary initialization
    rand.Seed(time.Now().UnixNano())
}

// ✅ Prefer explicit initialization
func NewUserService(repo UserRepository) *UserService {
    return &UserService{
        repo: repo,
    }
}

// ✅ Zero values are useful
var count int        // 0
var name string      // ""
var isActive bool    // false
var users []User     // nil
```

### Concurrency

```go
// ✅ Use goroutines for concurrent work
go func() {
    // Background work
}()

// ✅ Use channels for communication
results := make(chan Result, 10)

go func() {
    result := doWork()
    results <- result
}()

result := <-results

// ✅ Use sync.WaitGroup for coordination
var wg sync.WaitGroup

for _, item := range items {
    wg.Add(1)
    go func(item Item) {
        defer wg.Done()
        process(item)
    }(item)
}

wg.Wait()

// ✅ Use context for cancellation
ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
defer cancel()

result, err := doSomethingWithContext(ctx)
```

### Defer

```go
// ✅ Use defer for cleanup
func readFile(path string) ([]byte, error) {
    f, err := os.Open(path)
    if err != nil {
        return nil, err
    }
    defer f.Close() // Always closes, even if panic

    return io.ReadAll(f)
}

// ✅ Defer in loops with care
func processFiles(paths []string) error {
    for _, path := range paths {
        func() {
            f, err := os.Open(path)
            if err != nil {
                return
            }
            defer f.Close() // Closes after each iteration

            // Process file
        }()
    }
    return nil
}
```

## 📦 Package Organization

### Internal vs Pkg

```go
// internal/ - Private packages
// Cannot be imported by external projects
internal/
├── api/
├── service/
└── repository/

// pkg/ - Public packages
// Can be imported by external projects
pkg/
├── client/
├── types/
└── utils/
```

### Import Grouping

```go
import (
    // 1. Standard library
    "context"
    "fmt"
    "time"

    // 2. External dependencies
    "github.com/gin-gonic/gin"
    "github.com/jmoiron/sqlx"

    // 3. Internal packages
    "github.com/yourorg/project/internal/model"
    "github.com/yourorg/project/internal/service"
)
```

## 🔍 Interfaces

### Accepting Interfaces

```go
// ✅ Accept interfaces, return structs
func ProcessData(reader io.Reader) (*Result, error) {
    // Flexible: works with files, buffers, network connections
}

// ❌ Don't accept structs unnecessarily
func ProcessData(file *os.File) (*Result, error) {
    // Inflexible: only works with files
}
```

### Small Interfaces

```go
// ✅ Prefer small, focused interfaces
type UserGetter interface {
    Get(id string) (*User, error)
}

type UserCreator interface {
    Create(user *User) error
}

// ✅ Compose interfaces
type UserRepository interface {
    UserGetter
    UserCreator
}
```

## 🧪 Testing

```go
// user_test.go
package user

import "testing"

// ✅ Test function naming
func TestCreateUser(t *testing.T) {
    // ...
}

func TestGetUser_NotFound(t *testing.T) {
    // ...
}

// ✅ Table-driven tests
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name  string
        email string
        want  bool
    }{
        {"valid email", "user@example.com", true},
        {"missing @", "userexample.com", false},
        {"empty", "", false},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := ValidateEmail(tt.email)
            if got != tt.want {
                t.Errorf("ValidateEmail(%q) = %v, want %v", tt.email, got, tt.want)
            }
        })
    }
}

// ✅ Use testify for assertions (optional)
import "github.com/stretchr/testify/assert"

func TestCreateUser(t *testing.T) {
    user, err := CreateUser("john@example.com")
    assert.NoError(t, err)
    assert.NotNil(t, user)
    assert.Equal(t, "john@example.com", user.Email)
}
```

## 🎯 Best Practices

### Early Returns

```go
// ✅ Use guard clauses
func processUser(user *User) error {
    if user == nil {
        return errors.New("user is nil")
    }

    if !user.IsActive {
        return errors.New("user is not active")
    }

    // Happy path
    return user.Process()
}
```

### Avoid Global State

```go
// ❌ Bad: Global variable
var db *sql.DB

// ✅ Good: Dependency injection
type UserService struct {
    db *sql.DB
}

func NewUserService(db *sql.DB) *UserService {
    return &UserService{db: db}
}
```

### Use Context

```go
// ✅ Pass context as first parameter
func GetUser(ctx context.Context, id string) (*User, error) {
    // Check context
    if err := ctx.Err(); err != nil {
        return nil, err
    }

    // Use context in queries
    return db.QueryRowContext(ctx, "SELECT * FROM users WHERE id = $1", id)
}
```

## 📚 Documentation

```go
// ✅ Document exported identifiers
// User represents a user in the system.
type User struct {
    ID   string
    Name string
}

// CreateUser creates a new user with the given email.
// It returns an error if the email is invalid or already exists.
func CreateUser(email string) (*User, error) {
    // ...
}

// ❌ Don't document obvious things
// Get gets a user.
func Get(id string) (*User, error) {
    // ...
}
```

---

**Tools**: gofmt, golint, go vet, staticcheck
**Review frequency**: Follow Go releases and official guidelines
