# Vue.js Code Style

> Vue.js coding standards for {{PROJECT_NAME}}

## 🎯 General Principles

- Follow the [Vue.js Style Guide](https://vuejs.org/style-guide/)
- Use Composition API for Vue 3
- Prefer TypeScript for type safety
- Keep components small and focused

## 📁 Component Structure

### File Naming

```bash
# ✅ Use PascalCase for component files
UserProfile.vue
NavigationBar.vue
DataTable.vue

# ✅ Multi-word component names (avoid conflicts with HTML)
UserCard.vue      # ✅ Good
Card.vue          # ❌ Too generic

# ✅ Base components
BaseButton.vue
BaseInput.vue
BaseIcon.vue

# ✅ Feature-specific components
UserProfileCard.vue
UserProfileAvatar.vue
```

### Component Organization

```vue
<script setup lang="ts">
// 1. Imports
import { ref, computed, onMounted } from 'vue'
import type { User } from '@/types'

// 2. Props
const props = defineProps<{
  user: User
  isActive?: boolean
}>()

// 3. Emits
const emit = defineEmits<{
  update: [user: User]
  delete: [id: string]
}>()

// 4. Reactive state
const count = ref(0)
const isLoading = ref(false)

// 5. Computed properties
const displayName = computed(() => {
  return `${props.user.firstName} ${props.user.lastName}`
})

// 6. Methods
const handleClick = () => {
  count.value++
  emit('update', props.user)
}

// 7. Lifecycle hooks
onMounted(() => {
  // Initialize
})
</script>

<template>
  <!-- Template here -->
</template>

<style scoped>
/* Styles here */
</style>
```

## 🔧 Composition API

### Ref vs Reactive

```typescript
// ✅ Use ref for primitives
const count = ref(0)
const name = ref('John')
const isActive = ref(true)

// Access with .value in script
count.value++

// No .value needed in template
<template>
  <div>{{ count }}</div>
</template>

// ✅ Use reactive for objects
const state = reactive({
  count: 0,
  name: 'John',
  isActive: true
})

// No .value needed
state.count++

// ✅ Prefer ref for consistency
const user = ref<User | null>(null)
const items = ref<Item[]>([])
```

### Props

```typescript
// ✅ Type-safe props with TypeScript
const props = defineProps<{
  // Required prop
  user: User
  // Optional prop
  isActive?: boolean
  // With default
  count?: number
}>()

// ✅ With defaults using withDefaults
const props = withDefaults(
  defineProps<{
    user: User
    isActive?: boolean
    count?: number
  }>(),
  {
    isActive: false,
    count: 0
  }
)

// ✅ Runtime props validation (if not using TS)
const props = defineProps({
  user: {
    type: Object as PropType<User>,
    required: true
  },
  isActive: {
    type: Boolean,
    default: false
  }
})
```

### Emits

```typescript
// ✅ Type-safe emits
const emit = defineEmits<{
  update: [user: User]
  delete: [id: string]
  close: []  // No payload
}>()

// Usage
emit('update', user)
emit('delete', userId)
emit('close')

// ✅ Runtime validation (if not using TS)
const emit = defineEmits({
  update: (user: User) => {
    return user && user.id
  }
})
```

### Computed

```typescript
// ✅ Use computed for derived state
const displayName = computed(() => {
  return `${user.value.firstName} ${user.value.lastName}`
})

// ✅ Writable computed
const fullName = computed({
  get: () => `${firstName.value} ${lastName.value}`,
  set: (value) => {
    const [first, last] = value.split(' ')
    firstName.value = first
    lastName.value = last
  }
})

// ❌ Don't use methods for derived state
const getDisplayName = () => `${user.value.firstName} ${user.value.lastName}`
```

### Watchers

```typescript
// ✅ Watch a ref
watch(count, (newValue, oldValue) => {
  console.log(`Count changed from ${oldValue} to ${newValue}`)
})

// ✅ Watch multiple sources
watch([count, name], ([newCount, newName], [oldCount, oldName]) => {
  // ...
})

// ✅ Deep watch for objects
watch(
  user,
  (newUser) => {
    saveUser(newUser)
  },
  { deep: true }
)

// ✅ Immediate execution
watch(
  userId,
  (id) => {
    fetchUser(id)
  },
  { immediate: true }
)

// ✅ watchEffect for simple cases
watchEffect(() => {
  // Automatically tracks dependencies
  console.log(`Count is ${count.value}`)
})
```

## 🎨 Template Syntax

### Directives

```vue
<!-- ✅ Use v-if for conditional rendering -->
<div v-if="isActive">Active</div>
<div v-else-if="isPending">Pending</div>
<div v-else>Inactive</div>

<!-- ✅ Use v-show for toggling visibility -->
<div v-show="isVisible">Toggle me</div>

<!-- ✅ Use v-for with :key -->
<div v-for="user in users" :key="user.id">
  {{ user.name }}
</div>

<!-- ✅ Avoid v-if with v-for on same element -->
<!-- ❌ Bad -->
<div v-for="user in users" v-if="user.active" :key="user.id">

<!-- ✅ Good - Filter first -->
<div v-for="user in activeUsers" :key="user.id">
  {{ user.name }}
</div>

<script setup>
const activeUsers = computed(() => users.value.filter(u => u.active))
</script>
```

### Event Handling

```vue
<!-- ✅ Use @ shorthand -->
<button @click="handleClick">Click me</button>

<!-- ✅ Inline handlers for simple cases -->
<button @click="count++">Increment</button>

<!-- ✅ Method handlers -->
<button @click="handleSubmit">Submit</button>

<!-- ✅ Event modifiers -->
<form @submit.prevent="handleSubmit">
<input @keyup.enter="search">
<button @click.once="initialize">

<!-- ✅ Pass arguments -->
<button @click="handleClick(user.id)">Delete</button>

<!-- ✅ Access event object -->
<input @input="handleInput($event)">
```

### Class and Style Binding

```vue
<!-- ✅ Object syntax -->
<div :class="{ active: isActive, disabled: !isEnabled }">

<!-- ✅ Array syntax -->
<div :class="[baseClass, { active: isActive }]">

<!-- ✅ Computed classes -->
<div :class="containerClasses">

<script setup>
const containerClasses = computed(() => ({
  'container': true,
  'container--active': isActive.value,
  'container--large': size.value === 'large'
}))
</script>

<!-- ✅ Style binding -->
<div :style="{ color: textColor, fontSize: fontSize + 'px' }">
```

## 🏗️ Component Patterns

### Composables

```typescript
// useUser.ts
export function useUser(userId: Ref<string>) {
  const user = ref<User | null>(null)
  const loading = ref(false)
  const error = ref<Error | null>(null)

  const fetchUser = async () => {
    loading.value = true
    error.value = null

    try {
      const response = await fetch(`/api/users/${userId.value}`)
      user.value = await response.json()
    } catch (e) {
      error.value = e as Error
    } finally {
      loading.value = false
    }
  }

  // Auto-fetch on mount
  onMounted(fetchUser)

  // Re-fetch when userId changes
  watch(userId, fetchUser)

  return {
    user: readonly(user),
    loading: readonly(loading),
    error: readonly(error),
    refetch: fetchUser
  }
}

// Usage in component
const userId = ref('123')
const { user, loading, error } = useUser(userId)
```

### Provide/Inject

```typescript
// Parent component
const theme = ref('light')
provide('theme', theme)

// Child component (any level deep)
const theme = inject<Ref<string>>('theme')

// ✅ With default value
const theme = inject('theme', ref('light'))

// ✅ Type-safe with injection key
// keys.ts
export const ThemeKey = Symbol() as InjectionKey<Ref<string>>

// Parent
provide(ThemeKey, theme)

// Child
const theme = inject(ThemeKey)
```

### Slots

```vue
<!-- Parent component -->
<template>
  <Card>
    <template #header>
      <h2>Title</h2>
    </template>

    <template #default>
      <p>Content</p>
    </template>

    <template #footer>
      <button>Action</button>
    </template>
  </Card>
</template>

<!-- Card.vue -->
<template>
  <div class="card">
    <header v-if="$slots.header">
      <slot name="header" />
    </header>

    <main>
      <slot /> <!-- default slot -->
    </main>

    <footer v-if="$slots.footer">
      <slot name="footer" />
    </footer>
  </div>
</template>

<!-- ✅ Scoped slots -->
<template>
  <List :items="users">
    <template #item="{ item }">
      <UserCard :user="item" />
    </template>
  </List>
</template>

<!-- List.vue -->
<template>
  <div v-for="item in items" :key="item.id">
    <slot name="item" :item="item" />
  </div>
</template>
```

## 🎯 Best Practices

### Component Communication

```typescript
// ✅ Props down, events up
// Parent
<UserCard :user="user" @update="handleUpdate" />

// Child
const props = defineProps<{ user: User }>()
const emit = defineEmits<{ update: [user: User] }>()

// ✅ Use provide/inject for deeply nested props
// ✅ Use Pinia/Vuex for global state
```

### Performance

```vue
<!-- ✅ Use v-once for static content -->
<div v-once>{{ staticContent }}</div>

<!-- ✅ Use v-memo for conditional memoization -->
<div v-memo="[user.id, user.name]">
  <!-- Expensive rendering -->
</div>

<!-- ✅ Lazy load components -->
<script setup>
const HeavyComponent = defineAsyncComponent(() =>
  import('./HeavyComponent.vue')
)
</script>

<!-- ✅ Use Suspense for async components -->
<Suspense>
  <template #default>
    <AsyncComponent />
  </template>
  <template #fallback>
    <LoadingSpinner />
  </template>
</Suspense>
```

### TypeScript

```typescript
// ✅ Define types for props
type UserProps = {
  user: User
  isActive?: boolean
}

const props = defineProps<UserProps>()

// ✅ Use generic components
<script setup lang="ts" generic="T">
const props = defineProps<{
  items: T[]
  keyExtractor: (item: T) => string
}>()
</script>

// ✅ Type template refs
const inputRef = ref<HTMLInputElement>()
const buttonRef = ref<InstanceType<typeof BaseButton>>()
```

## 🧪 Testing

```typescript
import { mount } from '@vue/test-utils'
import UserCard from './UserCard.vue'

describe('UserCard', () => {
  it('renders user name', () => {
    const wrapper = mount(UserCard, {
      props: {
        user: { id: '1', name: 'John' }
      }
    })

    expect(wrapper.text()).toContain('John')
  })

  it('emits update event on button click', async () => {
    const wrapper = mount(UserCard, {
      props: {
        user: { id: '1', name: 'John' }
      }
    })

    await wrapper.find('button').trigger('click')

    expect(wrapper.emitted('update')).toBeTruthy()
  })
})
```

---

**Tools**: Vite, ESLint, Prettier, Vue DevTools
**Review frequency**: Follow Vue.js major releases
