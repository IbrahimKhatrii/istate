part of '../istate.dart';

/// A widget that efficiently rebuilds UI when a specific state changes.
///
/// [StateBuilder] creates a direct connection between your application state
/// and UI components, allowing selective rebuilds without affecting unrelated widgets.
///
/// ## Purpose
///
/// The primary purpose is to optimize performance by rebuilding only the parts
/// of your UI that actually depend on a particular state object, rather than
/// rebuilding entire widget trees when any state changes.
///
/// ## Basic Usage
///
/// ```dart
/// StateBuilder<CounterState>(
///   builder: (state) => Text('Count: ${state.value}'),
/// )
/// ```
///
/// ## How It Works
///
/// 1. Looks up the requested state type from the nearest [_IStateModel] in the widget tree
/// 2. Automatically sets up a listener using [ListenableBuilder]
/// 3. Rebuilds only when the specific state's [notifyListeners()] is called
/// 4. Provides compile-time type safety through generic type parameters
///
/// ## Performance Benefits
///
/// - Only rebuilds widgets dependent on the changed state
/// - Uses [ListenableBuilder] for efficient listener management
/// - Avoids unnecessary parent widget rebuilds
/// - Reduces widget rebuild overhead
///
/// ## Type Safety Features
///
/// - Generic type parameter ensures correct state type usage
/// - Compile-time error detection for incorrect state access
/// - Full IDE autocomplete support for state properties/methods
///
/// ## Error Handling
///
/// Throws [FlutterError] if used outside of an [IStatelessWidget] context:
/// ```dart
/// // Error: StateBuilder must be used within an IStatelessWidget
/// ```
///
/// ## Best Practices
///
/// ### Keep Builders Lightweight
/// ```dart
/// // Good
/// StateBuilder<CounterState>(
///   builder: (state) => Text('Count: ${state.value}'),
/// )
///
/// // Avoid complex logic in builder
/// ```
///
/// ### Use Multiple StateBuilders for Different States
/// ```dart
/// Column(
///   children: [
///     StateBuilder<CounterState>(
///       builder: (state) => Text('Counter: ${state.value}'),
///     ),
///     StateBuilder<UserState>(
///       builder: (state) => Text('User: ${state.name}'),
///     ),
///   ],
/// )
/// ```
///
/// ## Integration Requirements
///
/// Requires an [_IStateModel] to be available in the widget tree,
/// typically provided by an [IStatelessWidget] or similar container.
///
/// ## Common Patterns
///
/// ### Simple Value Display
/// ```dart
/// StateBuilder<UserState>(
///   builder: (state) => Text(state.userName),
/// )
/// ```
///
/// ### Conditional UI
/// ```dart
/// StateBuilder<AuthState>(
///   builder: (state) => state.isAuthenticated
///     ? UserProfile()
///     : LoginButton(),
/// )
/// ```
///
/// ### List Rebuilding
/// ```dart
/// StateBuilder<ShoppingCartState>(
///   builder: (state) => Column(
///     children: state.items.map((item) => CartItem(item)).toList(),
///   ),
/// )
/// ```
///
/// ## Testing
///
/// ```dart
/// testWidgets('StateBuilder rebuilds on state change', (tester) async {
///   final counterState = CounterState();
///
///   await tester.pumpWidget(
///     MaterialApp(
///       home: YourStatefulWidget(
///         child: StateBuilder<CounterState>(
///           builder: (state) => Text('Count: ${state.value}'),
///         ),
///       ),
///     ),
///   );
///
///   expect(find.text('Count: 0'), findsOneWidget);
///
///   counterState.increment();
///   await tester.pump();
///
///   expect(find.text('Count: 1'), findsOneWidget);
/// });
/// ```
///
/// ## Troubleshooting
///
/// ### Widget Not Rebuilding
/// - Ensure [notifyListeners()] is called in your state
/// - Verify the state type matches exactly
/// - Confirm [StateBuilder] is within the correct context
///
/// ### Performance Issues
/// - Move heavy computations outside the builder
/// - Use [const] constructors where possible
/// - Profile to identify bottlenecks
///
/// See also:
/// - [ListenableBuilder] for the underlying rebuild mechanism
/// - [IState] for the base state class requirements
/// - [_IStateModel] for the state management context
class StateBuilder<T extends IState> extends StatelessWidget {
  /// Called to build the widget whenever the state changes.
  ///
  /// The [builder] function receives the current state of type [T] and
  /// should return a widget tree based on that state.
  ///
  /// This function is called every time the state's [notifyListeners()]
  /// method is invoked, so it should be fast and avoid heavy computations.
  final Widget Function(T state) builder;

  /// Creates a [StateBuilder] that rebuilds when state of type [T] changes.
  ///
  /// The [builder] parameter is required and must not be null.
  const StateBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final stateModel = _IStateModel.of(context);

    if (stateModel == null) {
      throw FlutterError(
        'StateBuilder must be used within an IStatelessWidget',
      );
    }

    T targetState = stateModel.getState<T>();

    return ListenableBuilder(
      listenable: targetState,
      builder: (context, child) {
        return builder(targetState);
      },
    );
  }
}
