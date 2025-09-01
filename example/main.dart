/// A simple counter app demonstrating the iState library usage.
///
/// This example showcases the core features of the iState state management
/// library for Flutter applications. It demonstrates how to create reactive
/// UI components that automatically update when application state changes.
///
/// ## Features Demonstrated
///
/// 1. **Custom State Creation**: [CounterState] extends [IState] to manage counter logic
/// 2. **State Management Widget**: [Home] extends [IStatelessWidget] to declare and manage states
/// 3. **Reactive UI Updates**: [StateBuilder] widget automatically rebuilds when state changes
/// 4. **Global State Access**: [Float] widget accesses state globally using [state<T>()] function
/// 5. **Hot Reload Preservation**: Counter value persists during development hot reloads
/// 6. **Automatic Lifecycle Management**: States are created and disposed automatically
///
/// ## How to Run
///
/// 1. Ensure the iState package is added to your pubspec.yaml:
///    ```yaml
///    dependencies:
///      flutter:
///        sdk: flutter
///      istate: ^latest_version
///    ```
///
/// 2. Run the application:
///    ```bash
///    flutter run
///    ```
///
/// 3. Interact with the UI:
///    - Press the "+" FAB to increment the counter
///    - Press the "-" FAB to decrement the counter
///    - Press the "Reset" FAB to reset the counter to zero
///
/// ## Architecture Overview
///
/// ```
/// MyApp (StatelessWidget)
/// └── MaterialApp
///     └── Home (IStatelessWidget)
///         ├── CounterState (IState<int>)
///         ├── StateBuilder<CounterState> (Reactive UI)
///         └── Action Buttons (Global State Access)
/// ```
///
/// ## Hot Reload Benefits
///
/// The [CounterState] uses a [restorationId] which enables the counter value
/// to persist across hot reload sessions. This means during development,
/// you can modify the UI code and the counter will maintain its current value,
/// providing a seamless development experience.
///
/// ## Memory Management
///
/// The iState library automatically handles the complete lifecycle of states:
/// - Creation when the widget tree is built
/// - Registration for global access
/// - Listener management for reactive updates
/// - Proper disposal when widgets are removed from the tree
/// - Resource cleanup to prevent memory leaks
library;

import 'package:flutter/material.dart';
import 'package:istate/istate.dart';

/// Application state that manages a simple counter value.
///
/// [CounterState] extends [IState<int>] to provide type-safe management
/// of an integer counter. It includes increment, decrement, and reset
/// functionality, with automatic UI updates through the iState system.
///
/// ## Features
///
/// ### Reactive Updates
/// - Extends [IState<int>] for integer value management
/// - Uses [set()] method to update value and notify listeners
/// - Automatically triggers UI rebuilds for dependent widgets
///
/// ### Hot Reload Preservation
/// - Uses [restorationId] 'counter_state' to preserve value during hot reload
/// - Maintains development workflow continuity
/// - Transparent integration with Flutter development tools
///
/// ### Type Safety
/// - Generic type parameter ensures compile-time type checking
/// - IDE autocomplete support for methods and properties
/// - Clear error messages for incorrect usage
///
/// ## Usage Example
///
/// ```dart
/// // In IStatelessWidget states getter
/// @override
/// List<IState> get states => [CounterState()];
///
/// // In UI components
/// StateBuilder<CounterState>(
///   builder: (state) => Text('Count: ${state.value}'),
/// )
///
/// // In event handlers
/// onPressed: () => state<CounterState>().increase(),
/// ```
class CounterState extends IState<int> {
  /// Creates a new counter state initialized to zero.
  ///
  /// The [restorationId] parameter enables hot reload preservation,
  /// ensuring the counter value persists during development sessions.
  ///
  /// Example:
  /// ```dart
  /// final counter = CounterState(); // Initial value: 0
  /// ```
  CounterState() : super(0);

  /// Increments the counter value by 1.
  ///
  /// Updates the internal value and notifies all listeners,
  /// triggering automatic UI rebuilds for dependent widgets.
  ///
  /// Example:
  /// ```dart
  /// // Current value: 5
  /// state<CounterState>().increase();
  /// // New value: 6
  /// ```
  void increase() => set(value + 1);

  /// Decrements the counter value by 1.
  ///
  /// Updates the internal value and notifies all listeners,
  /// triggering automatic UI rebuilds for dependent widgets.
  ///
  /// Example:
  /// ```dart
  /// // Current value: 5
  /// state<CounterState>().decrease();
  /// // New value: 4
  /// ```
  void decrease() => set(value - 1);

  /// Resets the counter value to zero.
  ///
  /// Overrides the default [reset()] method to explicitly set
  /// the value to zero instead of using the initial value.
  /// Notifies all listeners to trigger UI updates.
  ///
  /// Example:
  /// ```dart
  /// // Current value: 42
  /// state<CounterState>().reset();
  /// // New value: 0
  /// ```
  @override
  void reset() => set(0);
}

/// The main application widget.
///
/// [MyApp] is a standard [StatelessWidget] that serves as the root
/// of the application. It creates the [MaterialApp] and sets up
/// the initial route to the [Home] screen.
///
/// ## Role in State Management
///
/// While [MyApp] itself doesn't manage states, it provides the
/// foundation for the state management system by:
/// - Creating the [MaterialApp] context
/// - Establishing the widget tree structure
/// - Enabling proper context propagation
///
/// ## Usage
///
/// ```dart
/// void main() {
///   runApp(const MyApp());
/// }
/// ```
class MyApp extends StatelessWidget {
  /// Creates a const instance of [MyApp].
  ///
  /// The [key] parameter is optional and follows Flutter's standard
  /// widget key system for widget identification and management.
  const MyApp({super.key});

  /// Builds the widget tree for the application.
  ///
  /// Creates a [MaterialApp] with the [Home] screen as the initial route.
  /// This establishes the foundation for the state management system
  /// by providing the necessary context and widget tree structure.
  ///
  /// Returns:
  /// A [MaterialApp] widget configured with the home screen.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iState Counter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Home(),
    );
  }
}

/// The main home screen that demonstrates iState functionality.
///
/// [Home] extends [IStatelessWidget] to automatically manage the
/// [CounterState] lifecycle. It declares the required states and
/// builds a reactive UI that updates when the counter changes.
///
/// ## State Management
///
/// ### State Declaration
/// The [states] getter declares [CounterState] as a dependency:
/// ```dart
/// @override
/// List<IState> get states => [CounterState()];
/// ```
///
/// ### Automatic Lifecycle
/// The iState system automatically:
/// - Creates the [CounterState] instance
/// - Registers it for global access
/// - Manages listener subscriptions
/// - Disposes resources when widget is removed
///
/// ## UI Components
///
/// ### StateBuilder
/// Uses [StateBuilder<CounterState>] for reactive text display:
/// ```dart
/// StateBuilder<CounterState>(
///   builder: (state) => Text('Count: ${state.value}'),
/// )
/// ```
///
/// ### Global State Access
/// Child widgets access state globally without context passing:
/// ```dart
/// onPressed: () => state<CounterState>().increase(),
/// ```
class Home extends IStatelessWidget {
  /// Creates a const instance of [Home].
  ///
  /// The [key] parameter is optional and follows Flutter's standard
  /// widget key system for widget identification and management.
  const Home({super.key});

  /// Declares the states required by this widget and its subtree.
  ///
  /// Returns a list containing [CounterState], which will be
  /// automatically managed by the iState system. The state is:
  /// - Created when the widget is built
  /// - Registered for global access
  /// - Made available to child widgets
  /// - Properly disposed when widget is removed
  ///
  /// Example:
  /// ```dart
  /// @override
  /// List<IState> get states => [CounterState()];
  /// ```
  @override
  List<IState> get states => [CounterState()];

  /// Builds the widget tree for the home screen.
  ///
  /// Creates a [Scaffold] with:
  /// - An app bar with title
  /// - A center-aligned counter display using [StateBuilder]
  /// - Floating action buttons for counter manipulation
  ///
  /// The [StateBuilder<CounterState>] automatically rebuilds
  /// whenever the counter value changes, providing reactive UI updates.
  ///
  /// Returns:
  /// A [Scaffold] widget containing the complete home screen UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("iState Counter Example"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: StateBuilder<CounterState>(
          builder: (state) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Counter Value:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "${state.value}",
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Press the buttons below to modify the counter',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: const Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatIncrement(),
          SizedBox(height: 10),
          FloatDecrement(),
          SizedBox(height: 10),
          FloatReset(),
        ],
      ),
    );
  }
}

/// Floating action button that increments the counter.
///
/// [FloatIncrement] is a standard [StatelessWidget] that demonstrates
/// global state access without requiring BuildContext for state retrieval.
/// It uses the [state<T>()] function to access [CounterState] directly.
///
/// ## Global State Access
///
/// Uses the global [state<CounterState>()] function to access the
/// counter state without passing context or dependencies:
/// ```dart
/// onPressed: () => state<CounterState>().increase(),
/// ```
///
/// ## Design Benefits
///
/// ### Decoupling
/// - No dependency on parent widget structure
/// - No need to pass state through constructor parameters
/// - Independent of widget tree position
///
/// ### Simplicity
/// - Minimal code required for state interaction
/// - Clear, readable event handling
/// - Consistent API across the application
class FloatIncrement extends StatelessWidget {
  /// Creates a const instance of [FloatIncrement].
  ///
  /// The [key] parameter is optional and follows Flutter's standard
  /// widget key system for widget identification and management.
  const FloatIncrement({super.key});

  /// Builds the increment floating action button.
  ///
  /// Creates a [FloatingActionButton] with:
  /// - Plus icon indicating increment operation
  /// - OnPressed handler that calls [CounterState.increase()]
  /// - Tooltip for accessibility
  ///
  /// The button uses global state access through [state<CounterState>()]
  /// to modify the counter value without requiring context.
  ///
  /// Returns:
  /// A [FloatingActionButton] configured for incrementing the counter.
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => state<CounterState>().increase(),
      tooltip: 'Increment Counter',
      child: const Icon(Icons.add),
    );
  }
}

/// Floating action button that decrements the counter.
///
/// [FloatDecrement] demonstrates global state access for decrementing
/// the counter value. Like [FloatIncrement], it uses the [state<T>()]
/// function for direct state manipulation.
///
/// ## Usage Pattern
///
/// ```dart
/// onPressed: () => state<CounterState>().decrease(),
/// ```
///
/// This pattern enables clean separation between UI components and
/// state management logic while maintaining type safety and performance.
class FloatDecrement extends StatelessWidget {
  /// Creates a const instance of [FloatDecrement].
  ///
  /// The [key] parameter is optional and follows Flutter's standard
  /// widget key system for widget identification and management.
  const FloatDecrement({super.key});

  /// Builds the decrement floating action button.
  ///
  /// Creates a [FloatingActionButton] with:
  /// - Minus icon indicating decrement operation
  /// - OnPressed handler that calls [CounterState.decrease()]
  /// - Tooltip for accessibility
  ///
  /// Uses global state access to modify the counter without context.
  ///
  /// Returns:
  /// A [FloatingActionButton] configured for decrementing the counter.
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => state<CounterState>().decrease(),
      tooltip: 'Decrement Counter',
      child: const Icon(Icons.remove),
    );
  }
}

/// Floating action button that resets the counter.
///
/// [FloatReset] provides a way to reset the counter to zero using
/// the global state access pattern. It demonstrates how multiple
/// UI components can interact with the same state independently.
///
/// ## State Interaction
///
/// ```dart
/// onPressed: () => state<CounterState>().reset(),
/// ```
///
/// This approach allows any widget in the application to interact
/// with the counter state without tight coupling or complex wiring.
class FloatReset extends StatelessWidget {
  /// Creates a const instance of [FloatReset].
  ///
  /// The [key] parameter is optional and follows Flutter's standard
  /// widget key system for widget identification and management.
  const FloatReset({super.key});

  /// Builds the reset floating action button.
  ///
  /// Creates a [FloatingActionButton] with:
  /// - Refresh icon indicating reset operation
  /// - OnPressed handler that calls [CounterState.reset()]
  /// - Tooltip for accessibility
  ///
  /// Utilizes global state access for counter reset functionality.
  ///
  /// Returns:
  /// A [FloatingActionButton] configured for resetting the counter.
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => state<CounterState>().reset(),
      tooltip: 'Reset Counter',
      child: const Icon(Icons.refresh),
    );
  }
}

/// Entry point for the iState counter example application.
///
/// Initializes the Flutter framework and runs the [MyApp] widget,
/// which sets up the complete state management system and UI.
///
/// ## Application Flow
///
/// 1. Flutter framework initializes
/// 2. [MyApp] creates the [MaterialApp]
/// 3. [Home] extends [IStatelessWidget] to manage [CounterState]
/// 4. [CounterState] is created and registered automatically
/// 5. UI components use [StateBuilder] and [state<T>()] for interaction
/// 6. State changes trigger automatic UI updates
///
/// ## Development Workflow
///
/// During development with hot reload:
/// - Counter value persists due to [restorationId]
/// - UI changes are reflected immediately
/// - State remains consistent across reloads
/// - No loss of application state during iterations
void main() {
  runApp(const MyApp());
}
