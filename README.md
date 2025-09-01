# iState - Lightweight Flutter State Management, Business Logic

A lightweight, efficient state management solution for Flutter applications with automatic lifecycle management and hot reload preservation.

## 🌟 Features

- **Automatic Lifecycle Management**: States are created, registered, and disposed automatically
- **Hot Reload Preservation**: Automatic state persistence during development
- **Global State Access**: Convenient `state<T>()` function for state interaction
- **Type Safety**: Compile-time type checking with generic parameters
- **Performance Optimization**: Selective UI rebuilds with `StateBuilder`
- **No Context Propagation**: Access states without passing context through widget trees

## 🚀 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  istate: ^1.0.0
```

## 📖 Core Concepts

### IStatelessWidget

Extend `IStatelessWidget` instead of `StatelessWidget` to manage states:

```dart
class MyApp extends IStatelessWidget {
  @override
  List<IState> get states => [CounterState()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen());
  }
}
```

### IState

Create custom states by extending `IState<T>`:

```dart
class CounterState extends IState<int> {
  CounterState() : super(0); // restorationId is auto-generated

  void increment() => set(value + 1);
  void decrement() => set(value - 1);
  void reset() => set(0);
}
```

### StateBuilder

Use `StateBuilder` for reactive UI updates:

```dart
StateBuilder<CounterState>(
  builder: (state) => Text('Count: ${state.value}'),
)
```

### Global Access

Access states globally using the `state<T>()` function:

```dart
onPressed: () => state<CounterState>().increment(),
```

## 🔧 Usage Guide

### 1. Create State Classes

```dart
class UserState extends IState<User> {
  UserState() : super(User.empty());

  void login(User user) => set(user);
  void logout() => set(User.empty());
  bool get isLoggedIn => value.id.isNotEmpty;
}
```

### 2. Declare States in Widgets

```dart
class HomeScreen extends IStatelessWidget {
  @override
  List<IState> get states => [CounterState(), UserState()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CounterDisplay(),
      floatingActionButton: IncrementButton(),
    );
  }
}
```

### 3. Build Reactive UI

```dart
class CounterDisplay extends IStatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StateBuilder<CounterState>(
      builder: (state) => Text('Count: ${state.value}'),
    );
  }
}
```

### 4. Access States Globally

```dart
class IncrementButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => state<CounterState>().increment(),
      child: Icon(Icons.add),
    );
  }
}
```

## 🔥 Hot Reload Preservation

States automatically preserve their values during hot reload:

```dart
class CounterState extends IState<int> {
  CounterState() : super(0); // Auto-generated restoration ID
  // Or explicitly: super(0, restorationId: 'my_counter');

  void increment() => set(value + 1);
}
```

During development, counter values persist across hot reload sessions without any additional configuration.

## 🏗️ Architecture

```
IStatelessWidget
├── _IStateProvider (lifecycle management)
│   ├── _IStateModel (state distribution)
│   └── _GlobalStateManager (global access)
├── IState (individual states)
└── StateBuilder (reactive UI)
```

## 🎯 Advanced Patterns

### Complex State Management

```dart
class TodoListState extends IState<List<Todo>> {
  TodoListState() : super([]);

  void addTodo(Todo todo) => set([...value, todo]);
  void removeTodo(Todo todo) => set(value.where((t) => t.id != todo.id).toList());
  int get completedCount => value.where((todo) => todo.completed).length;
}
```

### State Composition

```dart
class DashboardWidget extends IStatelessWidget {
  @override
  List<IState> get states => [UserState(), NotificationState()];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StateBuilder<UserState>(
          builder: (userState) => UserHeader(user: userState.value),
        ),
        StateBuilder<NotificationState>(
          builder: (notificationState) => NotificationBadge(
            count: notificationState.unreadCount,
          ),
        ),
      ],
    );
  }
}
```

## ⚡ Performance Optimization

### Selective Rebuilding

```dart
// Efficient: Only rebuilds when specific state changes
Column(
  children: [
    StateBuilder<CounterState>(
      builder: (state) => Text('Count: ${state.value}'),
    ),
    StateBuilder<UserState>(
      builder: (state) => Text('User: ${state.value.name}'),
    ),
  ],
)
```

### Efficient State Updates

```dart
// Good: Batch updates
void updateProfile(String name, String email) {
  set(value.copyWith(name: name, email: email));
}

// Avoid: Multiple sequential updates
void updateProfileBad(String name, String email) {
  set(value.copyWith(name: name));    // Triggers rebuild
  set(value.copyWith(email: email));  // Triggers rebuild
}
```

## 🧪 Testing

### Unit Testing States

```dart
void main() {
  test('CounterState increments correctly', () {
    final counter = CounterState();
    expect(counter.value, 0);

    counter.increment();
    expect(counter.value, 1);
  });
}
```

### Widget Testing

```dart
testWidgets('Counter updates UI', (tester) async {
  await tester.pumpWidget(MyApp());

  expect(find.text('Count: 0'), findsOneWidget);

  state<CounterState>().increment();
  await tester.pump();

  expect(find.text('Count: 1'), findsOneWidget);
});
```

## ⚠️ Error Handling

Common error messages and solutions:

```dart
// Error: StateBuilder must be used within IStatelessWidget
// Solution: Ensure parent widget extends IStatelessWidget

// Error: State of type X not found
// Solution: Add X to states getter in IStatelessWidget
```

## 🔄 Migration

### From setState

```dart
// Before: StatefulWidget with setState
class CounterWidget extends StatefulWidget {...}

// After: IStatelessWidget with IState
class CounterWidget extends IStatelessWidget {
  @override
  List<IState> get states => [CounterState()];
  ...
}
```

## 📚 API Reference

### Main Classes

- `IStatelessWidget`: Base widget for state management
- `IState<T>`: Base class for application states
- `StateBuilder<T>`: Widget that rebuilds on state changes
- `state<T>()`: Global state accessor function

### Key Methods

- `IState.set(T newValue)`: Update state and notify listeners
- `IState.reset()`: Reset to initial value
- `IStatelessWidget.states`: Declare required states
- `StateBuilder.builder`: Builder function for UI

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

_iState - Simple, Efficient, Flutter State Management_
