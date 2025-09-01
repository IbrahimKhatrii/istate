part of '../istate.dart';

/// Base class for widgets that manage state.
///
/// [IStatelessWidget] is the foundation for state-managed widgets in this
/// state management system. It provides a clean, declarative way to define
/// which states a widget subtree needs while automatically handling state
/// lifecycle management, registration, and disposal.
///
/// ## Purpose
///
/// The primary purpose of [IStatelessWidget] is to:
/// - Provide a declarative API for state management
/// - Automatically handle state lifecycle (creation, registration, disposal)
/// - Enable global state access through the [state<T>()] function
/// - Support hot reload state preservation
/// - Integrate seamlessly with Flutter's widget system
///
/// ## Key Differences from StatelessWidget
///
/// Unlike [StatelessWidget], [IStatelessWidget]:
/// - Manages state lifecycle automatically
/// - Provides global state access
/// - Supports hot reload preservation
/// - Integrates with [_IStateModel] system
/// - Enables [StateBuilder] and [state<T>()] patterns
///
/// ## Usage Pattern
///
/// ```dart
/// class MyApp extends IStatelessWidget {
///   @override
///   List<IState> get states => [CounterState(), UserState()];
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
///
/// class CounterDisplay extends IStatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return StateBuilder<CounterState>(
///       builder: (state) => Text('Count: ${state.value}'),
///     );
///   }
/// }
/// ```
///
/// ## State Management Lifecycle
///
/// ### Declaration
/// 1. Override [states] getter to declare needed states
/// 2. States are automatically created and managed
/// 3. No manual state instantiation required in most cases
///
/// ### Registration
/// 1. States are registered with [_GlobalStateManager]
/// 2. Made available through [_IStateModel] to widget subtree
/// 3. Global access enabled via [state<T>()] function
///
/// ### Usage
/// 1. Access states through [StateBuilder] for reactive UI
/// 2. Access states globally using [state<T>()] function
/// 3. Modify states through their public methods
///
/// ### Disposal
/// 1. Automatic cleanup when widget is disposed
/// 2. States' [dispose()] methods called
/// 3. Global references removed
/// 4. Resources properly released
///
/// ## Integration with Flutter Widget System
///
/// ### Element Creation
/// - Uses custom [_IStatelessElement] for specialized behavior
/// - Integrates with Flutter's element system
/// - Handles build operations through [_IStateProvider]
///
/// ### Build Process
/// 1. Creates [_IStateProvider] with declared states
/// 2. Wraps user's [build] method in provider context
/// 3. Enables state access throughout subtree
///
/// ## Performance Characteristics
///
/// ### Memory Management
/// - Automatic state lifecycle management
/// - Prevents memory leaks through proper disposal
/// - Efficient state registration/unregistration
/// - Scoped state availability
///
/// ### Rebuild Efficiency
/// - Leverages [StateBuilder] for selective rebuilds
/// - Uses [ListenableBuilder] for efficient updates
/// - Minimizes unnecessary widget rebuilds
/// - Optimized inherited widget usage
///
/// ## Hot Reload Support
///
/// ### State Preservation
/// - Automatically preserves states with [restorationId]
/// - Maintains state values across hot reloads
/// - Seamless development experience
/// - No manual intervention required
///
/// ### Transition Handling
/// - Manages model transitions during hot reload
/// - Preserves state access continuity
/// - Handles temporary duplicate states gracefully
/// - Cleans up obsolete models automatically
///
/// ## Error Handling
///
/// ### State Access Errors
/// - Clear error messages for missing states
/// - Helpful debugging information
/// - Graceful degradation when possible
/// - Type-safe state retrieval
///
/// ### Lifecycle Management
/// - Proper cleanup even if individual states fail
/// - Continued operation despite partial failures
/// - Resource leak prevention
/// - Robust disposal handling
///
/// ## Best Practices
///
/// ### State Declaration
/// ```dart
/// class AppState extends IStatelessWidget {
///   @override
///   List<IState> get states => [
///     CounterState(),
///     UserState(),
///     ThemeState(),
///   ];
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: HomeScreen(),
///     );
///   }
/// }
/// ```
///
/// ### State Usage
/// ```dart
/// class CounterWidget extends IStatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: [
///         // Reactive UI with StateBuilder
///         StateBuilder<CounterState>(
///           builder: (state) => Text('Count: ${state.value}'),
///         ),
///         // Global access with state<T>() function
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
/// ## Testing Considerations
///
/// ### Unit Testing
/// ```dart
/// void main() {
///   testWidgets('IStatelessWidget manages states correctly', (tester) async {
///     await tester.pumpWidget(
///       MaterialApp(
///         home: MyApp(), // Extends IStatelessWidget
///       ),
///     );
///
///     // Test state interactions
///     state<CounterState>().increment();
///     // Verify UI updates...
///   });
/// }
/// ```
///
/// ### Mock Integration
/// ```dart
/// class TestWidget extends IStatelessWidget {
///   @override
///   List<IState> get states => [MockCounterState()];
///
///   @override
///   Widget build(BuildContext context) {
///     return TestContent();
///   }
/// }
/// ```
///
/// ## Common Patterns
///
/// ### Application Root
/// ```dart
/// class MyApp extends IStatelessWidget {
///   @override
///   List<IState> get states => [
///     AppState(),
///     UserPreferencesState(),
///     ThemeState(),
///   ];
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       builder: (context, child) => StateBuilder<ThemeState>(
///         builder: (themeState) => Theme(
///           data: themeState.value,
///           child: child!,
///         ),
///       ),
///     );
///   }
/// }
/// ```
///
/// ### Feature-Specific Widgets
/// ```dart
/// class CounterFeature extends IStatelessWidget {
///   @override
///   List<IState> get states => [CounterState()];
///
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
abstract class IStatelessWidget extends Widget {
  /// Creates an [IStatelessWidget].
  ///
  /// The [key] parameter is optional and follows Flutter's standard
  /// widget key system. It's passed to the superclass constructor.
  const IStatelessWidget({super.key});

  /// States managed by this widget.
  ///
  /// Override this getter to provide the list of states that this widget
  /// and its subtree will need access to. These states will be automatically
  /// created, registered, and disposed as part of the widget's lifecycle.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// List<IState> get states => [
  ///   CounterState(),
  ///   UserState(),
  ///   NetworkState(),
  /// ];
  /// ```
  ///
  /// Note: States should typically be instantiated here rather than
  /// passed in from outside, to ensure proper lifecycle management.
  List<IState> get states => const [];

  /// Describes the part of the user interface represented by this widget.
  ///
  /// This method is called whenever the state changes or the widget needs
  /// to be rebuilt. The provided [context] has access to all declared states
  /// through [_IStateModel] and can be used with [StateBuilder] or [state<T>()].
  ///
  /// The framework calls this method in a number of different situations:
  /// - After calling [initState]
  /// - After calling [didUpdateWidget]
  /// - After receiving a call to [markNeedsBuild]
  /// - After a dependency of this widget changes
  ///
  /// Example:
  /// ```dart
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Scaffold(
  ///     body: StateBuilder<CounterState>(
  ///       builder: (state) => Text('Count: ${state.value}'),
  ///     ),
  ///   );
  /// }
  /// ```
  Widget build(BuildContext context);

  @override
  Element createElement() => _IStatelessElement(this);
}

/// The element class for [IStatelessWidget].
///
/// [_IStatelessElement] is a specialized [ComponentElement] that provides
/// the integration between [IStatelessWidget] and the Flutter framework.
/// It handles the creation of [_IStateProvider] and manages the build process.
///
/// ## Purpose
///
/// The primary purpose of [_IStatelessElement] is to:
/// - Bridge [IStatelessWidget] with Flutter's element system
/// - Handle the build process through [_IStateProvider]
/// - Manage state lifecycle integration
/// - Enable proper context propagation
///
/// ## Integration Points
///
/// ### With IStatelessWidget
/// - Accesses widget's [states] and [build] method
/// - Provides the execution context for widget operations
/// - Handles framework integration
///
/// ### With IStateProvider
/// - Creates and manages the [_IStateProvider] instance
/// - Enables state lifecycle management
/// - Provides state access to widget subtree
///
/// ### With Flutter Framework
/// - Integrates with element lifecycle methods
/// - Participates in build scheduling
/// - Handles widget update notifications
class _IStatelessElement extends ComponentElement {
  /// Creates an element that uses the given widget as its configuration.
  ///
  /// The [widget] parameter must be an [IStatelessWidget] and is used
  /// to configure this element's behavior.
  _IStatelessElement(IStatelessWidget super.widget);

  /// The widget for this element.
  ///
  /// Provides strongly-typed access to the [IStatelessWidget] configuration,
  /// enabling access to states and build methods without casting.
  @override
  IStatelessWidget get widget => super.widget as IStatelessWidget;

  /// Describes the part of the user interface represented by this element.
  ///
  /// Creates a [_IStateProvider] that manages the widget's states and
  /// wraps the user's [build] method. This enables:
  /// - State lifecycle management
  /// - Global state access
  /// - Proper context propagation
  /// - Integration with [StateBuilder] and [state<T>()]
  ///
  /// The returned widget tree:
  /// ```
  /// _IStateProvider (manages states)
  /// └── Builder (user's build method)
  ///     └── User defined widget tree
  /// ```
  @override
  Widget build() {
    return _IStateProvider(
      states: widget.states,
      builder: (ctx) => widget.build(ctx),
    );
  }
}
