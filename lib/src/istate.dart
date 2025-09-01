/// A lightweight, efficient state management library for Flutter applications.
///
/// This library provides a comprehensive yet simple state management solution
/// that combines the best practices of reactive programming with Flutter's
/// widget system. It offers automatic state lifecycle management, hot reload
/// preservation, global state access, and efficient UI updates.
///
/// ## Core Concepts
///
/// ### IStatelessWidget
/// The foundation widget that manages state lifecycle automatically:
/// ```dart
/// class MyApp extends IStatelessWidget {
///   @override
///   List<IState> get states => [CounterState(), UserState()];
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(home: HomeScreen());
///   }
/// }
/// ```
///
/// ### IState
/// Base class for all application states with built-in reactivity:
/// ```dart
/// class CounterState extends IState<int> {
///   CounterState() : super(0, restorationId: 'counter');
///   void increment() => set(value + 1);
///   void decrement() => set(value - 1);
/// }
/// ```
///
/// ### StateBuilder
/// Widget that rebuilds efficiently when specific states change:
/// ```dart
/// StateBuilder<CounterState>(
///   builder: (state) => Text('Count: ${state.value}'),
/// )
/// ```
///
/// ### Global State Access
/// Convenient global accessor function for state interaction:
/// ```dart
/// onPressed: () => state<CounterState>().increment(),
/// ```
///
/// ## Key Features
///
/// ### Automatic Lifecycle Management
/// - States are created, registered, and disposed automatically
/// - No manual cleanup required
/// - Prevents memory leaks
/// - Handles complex widget lifecycles
///
/// ### Hot Reload Preservation
/// - States with [restorationId] preserve values during hot reload
/// - Seamless development experience
/// - No loss of test data during UI iterations
/// - Transparent integration with Flutter tools
///
/// ### Performance Optimization
/// - Selective UI rebuilds through [StateBuilder]
/// - Efficient listener management
/// - Minimal rebuild overhead
/// - Optimized state access patterns
///
/// ### Type Safety
/// - Compile-time type checking
/// - IDE autocomplete support
/// - Generic type parameters throughout
/// - Clear error messages
///
/// ## Architecture Overview
///
/// ```
/// IStatelessWidget
/// ├── _IStateProvider (lifecycle management)
/// │   ├── _IStateModel (state distribution)
/// │   │   └── InheritedWidget system
/// │   └── _GlobalStateManager (global access)
/// ├── IState (individual states)
/// │   ├── ChangeNotifier integration
/// │   ├── Hot reload storage
/// │   └── Type-safe operations
/// └── StateBuilder (reactive UI)
///     └── ListenableBuilder optimization
/// ```
///
/// ## Getting Started
///
/// 1. **Extend IStatelessWidget** for your main widgets:
/// ```dart
/// class MyApp extends IStatelessWidget {
///   @override
///   List<IState> get states => [CounterState()];
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: Scaffold(
///         body: CounterDisplay(),
///       ),
///     );
///   }
/// }
/// ```
///
/// 2. **Define your states** by extending [IState]:
/// ```dart
/// class CounterState extends IState<int> {
///   CounterState() : super(0, restorationId: 'counter');
///
///   void increment() => set(value + 1);
///   void decrement() => set(value - 1);
///   void reset() => set(0);
/// }
/// ```
///
/// 3. **Build reactive UI** with [StateBuilder]:
/// ```dart
/// class CounterDisplay extends IStatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: [
///         StateBuilder<CounterState>(
///           builder: (state) => Text('Count: ${state.value}'),
///         ),
///         ElevatedButton(
///           onPressed: () => state<CounterState>().increment(),
///           child: Text('Increment'),
///         ),
///       ],
///     );
///   }
/// }
/// ```
///
/// ## Advanced Patterns
///
/// ### Complex State Management
/// ```dart
/// class TodoListState extends IState<List<Todo>> {
///   TodoListState() : super([], restorationId: 'todos');
///
///   void addTodo(Todo todo) => set([...value, todo]);
///   void removeTodo(Todo todo) => set(value.where((t) => t.id != todo.id).toList());
///   int get completedCount => value.where((todo) => todo.completed).length;
/// }
/// ```
///
/// ### Global State Interaction
/// ```dart
/// class BusinessLogic {
///   void handleUserAction() {
///     final authState = state<AuthState>();
///     final analyticsState = state<AnalyticsState>();
///
///     if (authState.isAuthenticated) {
///       // Perform action
///       analyticsState.logEvent('user_action');
///     }
///   }
/// }
/// ```
///
/// ### Themed Applications
/// ```dart
/// class ThemedApp extends IStatelessWidget {
///   @override
///   List<IState> get states => [ThemeState(), UserPreferencesState()];
///
///   @override
///   Widget build(BuildContext context) {
///     return StateBuilder<ThemeState>(
///       builder: (themeState) => MaterialApp(
///         theme: themeState.value,
///         home: HomeScreen(),
///       ),
///     );
///   }
/// }
/// ```
///
/// ## Performance Best Practices
///
/// ### Efficient State Updates
/// ```dart
/// // Good: Batch updates when possible
/// void updateMultipleFields(User newUser) {
///   set(newUser); // Single notification
/// }
///
/// // Avoid: Multiple sequential updates
/// // set(user.copyWith(name: newName));
/// // set(user.copyWith(email: newEmail)); // Multiple notifications
/// ```
///
/// ### Selective Rebuilding
/// ```dart
/// // Good: Specific StateBuilder for each concern
/// Column(
///   children: [
///     StateBuilder<CounterState>(  // Only rebuilds on counter changes
///       builder: (state) => Text('Count: ${state.value}'),
///     ),
///     StateBuilder<UserState>(     // Only rebuilds on user changes
///       builder: (state) => Text('User: ${state.value.name}'),
///     ),
///   ],
/// )
/// ```
///
/// ## Testing
///
/// ### Unit Testing States
/// ```dart
/// void main() {
///   test('CounterState increments correctly', () {
///     final counter = CounterState();
///     expect(counter.value, 0);
///
///     counter.increment();
///     expect(counter.value, 1);
///   });
/// }
/// ```
///
/// ### Widget Testing
/// ```dart
/// testWidgets('Counter updates UI', (tester) async {
///   await tester.pumpWidget(MyApp());
///
///   expect(find.text('Count: 0'), findsOneWidget);
///
///   state<CounterState>().increment();
///   await tester.pump();
///
///   expect(find.text('Count: 1'), findsOneWidget);
/// });
/// ```
///
/// ## Error Handling
///
/// ### Common Error Messages
/// ```dart
/// // Error: StateBuilder must be used within an IStatelessWidget
/// // Solution: Ensure widget extends IStatelessWidget
///
/// // Error: State of type X not found
/// // Solution: Add X to states getter in IStatelessWidget
/// ```
///
/// ## Migration from Other Solutions
///
/// ### From setState
/// ```dart
/// // Before: StatefulWidget with setState
/// // After: IStatelessWidget with IState and StateBuilder
/// ```
///
/// ### From Provider
/// ```dart
/// // Before: Provider/Consumer pattern
/// // After: IStatelessWidget with StateBuilder and state<T>()
/// ```
library internalState;

import 'package:flutter/widgets.dart';

part 'core/state.dart';
part 'core/internal.dart';
part 'core/provider.dart';
part 'core/builder.dart';

part 'state/manager.dart';
part 'widgets/stateless.dart';

part 'core/storage.dart';
