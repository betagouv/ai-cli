# Ruby Code Style

> Ruby coding standards for {{PROJECT_NAME}}

## 🎯 General Principles

- Follow the [Ruby Style Guide](https://rubystyle.guide/)
- Use [RuboCop](https://rubocop.org/) for linting
- Prefer clarity and readability over cleverness
- Embrace Ruby idioms and conventions

## 🔤 Naming Conventions

### Variables and Methods

```ruby
# ✅ Use snake_case for variables and methods
user_name = 'John'
is_active = true

def get_user_by_id(id)
  # ...
end

# ✅ Use ? for predicate methods
def admin?
  role == 'admin'
end

# ✅ Use ! for dangerous methods (mutate or raise)
def save!
  raise ValidationError unless valid?
  persist
end
```

### Classes and Modules

```ruby
# ✅ Use PascalCase for classes and modules
class UserService
  # ...
end

module Authentication
  # ...
end

# ✅ Constants use SCREAMING_SNAKE_CASE
MAX_RETRIES = 3
API_BASE_URL = 'https://api.example.com'
```

## 🎨 Code Style

### String Literals

```ruby
# ✅ Use single quotes for static strings
name = 'John'
message = 'Hello, world!'

# ✅ Use double quotes for interpolation
greeting = "Hello, #{name}!"

# ✅ Use %w for word arrays
colors = %w[red green blue]
# Same as: ['red', 'green', 'blue']

# ✅ Use %i for symbol arrays
statuses = %i[pending approved rejected]
# Same as: [:pending, :approved, :rejected]
```

### Symbols vs Strings

```ruby
# ✅ Use symbols for identifiers, internal names, hash keys
user = { name: 'John', age: 30 }
status = :pending

# ✅ Use strings for data, user input, text
greeting = "Hello, #{name}"
file_content = File.read('data.txt')
```

### Blocks

```ruby
# ✅ Use {...} for single-line blocks
users.map { |u| u.name }
items.select { |i| i.active? }

# ✅ Use do...end for multi-line blocks
users.each do |user|
  puts user.name
  puts user.email
end

# ✅ Prefer block syntax for chaining
users
  .select { |u| u.active? }
  .map { |u| u.name }
  .sort
```

### Conditionals

```ruby
# ✅ Use if/unless for single-line conditionals
return if user.nil?
raise Error unless valid?

# ✅ Use if for positive conditions
if user.admin?
  # ...
end

# ✅ Use unless for negative conditions (but not with else)
unless user.banned?
  # ...
end

# ❌ Avoid unless with else
unless user.admin?
  # ...
else
  # Confusing
end

# ✅ Use modifier if/unless for simple guards
return nil if user.nil?
send_email unless user.unsubscribed?

# ✅ Use case for multiple conditions
case status
when :pending
  'Waiting'
when :approved
  'Accepted'
when :rejected
  'Denied'
else
  'Unknown'
end
```

## 🔧 Ruby Idioms

### Safe Navigation

```ruby
# ✅ Use &. for safe navigation
user&.address&.city

# ❌ Don't chain nil checks
user && user.address && user.address.city
```

### Operator Shortcuts

```ruby
# ✅ Use ||= for default assignment
@user ||= find_user

# ✅ Use += for accumulation
count += 1

# ✅ Use map, select, reject
names = users.map(&:name)
active_users = users.select(&:active?)
inactive = users.reject(&:active?)
```

### Each vs Map

```ruby
# ✅ Use each for side effects
users.each do |user|
  puts user.name
end

# ✅ Use map for transformations
names = users.map(&:name)

# ❌ Don't use each when you need map
names = []
users.each { |u| names << u.name } # Use map instead
```

### Guard Clauses

```ruby
# ✅ Use early returns
def process_user(user)
  return nil if user.nil?
  return false unless user.active?

  # Happy path
  user.process
end

# ❌ Avoid deep nesting
def process_user(user)
  if user
    if user.active?
      user.process
    end
  end
end
```

## 🏗️ Classes and Modules

### Class Definition

```ruby
# ✅ Use attr_accessor, attr_reader, attr_writer
class User
  attr_accessor :name, :email
  attr_reader :id
  attr_writer :password

  def initialize(id, name, email)
    @id = id
    @name = name
    @email = email
  end
end

# ✅ Use class methods
class User
  def self.find_by_email(email)
    # ...
  end

  def self.active
    where(active: true)
  end
end
```

### Modules

```ruby
# ✅ Use modules for mixins
module Timestampable
  def created_at
    @created_at ||= Time.now
  end
end

class User
  include Timestampable
end

# ✅ Use modules for namespacing
module API
  module V1
    class UsersController
      # ...
    end
  end
end
```

## 🔍 Error Handling

```ruby
# ✅ Use begin/rescue for error handling
def fetch_user(id)
  begin
    api.get("/users/#{id}")
  rescue ApiError => e
    log_error(e)
    nil
  rescue NetworkError => e
    log_error(e)
    raise
  ensure
    # Always runs
    close_connection
  end
end

# ✅ Use rescue inline for simple cases
def fetch_data
  api.get('/data')
rescue ApiError
  default_data
end

# ✅ Create custom errors
class ValidationError < StandardError
  attr_reader :field

  def initialize(message, field)
    super(message)
    @field = field
  end
end

raise ValidationError.new('Invalid email', :email)
```

## 🎯 Rails-Specific (if applicable)

### ActiveRecord

```ruby
# ✅ Use scopes for queries
class User < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :admin, -> { where(role: 'admin') }

  # Chainable
  User.active.admin
end

# ✅ Use validations
class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :age, numericality: { greater_than: 0 }
end

# ✅ Use callbacks sparingly
class User < ApplicationRecord
  before_save :normalize_email

  private

  def normalize_email
    self.email = email.downcase.strip
  end
end

# ✅ Avoid N+1 queries
# ❌ Bad
users = User.all
users.each { |u| puts u.posts.count }

# ✅ Good
users = User.includes(:posts)
users.each { |u| puts u.posts.count }
```

### Controllers

```ruby
# ✅ Keep controllers thin
class UsersController < ApplicationController
  def create
    @user = UserService.create(user_params)

    if @user.persisted?
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
```

## 🧪 Testing (RSpec)

```ruby
# user_spec.rb
RSpec.describe User do
  describe '#admin?' do
    it 'returns true for admin users' do
      user = User.new(role: 'admin')
      expect(user.admin?).to be true
    end

    it 'returns false for regular users' do
      user = User.new(role: 'user')
      expect(user.admin?).to be false
    end
  end

  # ✅ Use contexts for different scenarios
  describe '#save' do
    context 'with valid attributes' do
      it 'persists the user' do
        user = User.new(name: 'John', email: 'john@example.com')
        expect(user.save).to be true
      end
    end

    context 'with invalid email' do
      it 'fails validation' do
        user = User.new(name: 'John', email: 'invalid')
        expect(user.save).to be false
      end
    end
  end

  # ✅ Use let for test data
  let(:user) { User.new(name: 'John', email: 'john@example.com') }

  # ✅ Use factories
  let(:user) { create(:user) }
end
```

## 🎨 Best Practices

### Prefer Explicit Returns

```ruby
# ✅ Implicit return (Ruby default)
def full_name
  "#{first_name} #{last_name}"
end

# ✅ Explicit return for early exit
def process
  return nil if invalid?
  return false unless ready?

  do_work
end
```

### Use Symbols for Hash Keys

```ruby
# ✅ Use symbols for hash keys
user = { name: 'John', email: 'john@example.com' }

# ✅ Access with symbols
user[:name]

# ✅ Use keyword arguments
def create_user(name:, email:, age: 18)
  # ...
end

create_user(name: 'John', email: 'john@example.com')
```

### Avoid Global Variables

```ruby
# ❌ Don't use global variables
$database = Database.new

# ✅ Use constants or dependency injection
class UserService
  def initialize(database = Database.new)
    @database = database
  end
end
```

## 📚 Documentation

```ruby
# ✅ Use YARD for documentation
# Returns the full name of the user
#
# @return [String] the full name
def full_name
  "#{first_name} #{last_name}"
end

# Finds a user by email address
#
# @param email [String] the email to search for
# @return [User, nil] the user if found, nil otherwise
def self.find_by_email(email)
  # ...
end
```

---

**Tools**: RuboCop, RSpec, YARD
**Review frequency**: Follow Ruby and Rails updates
