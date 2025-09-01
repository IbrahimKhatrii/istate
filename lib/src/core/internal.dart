part of '../istate.dart';

/// State manager using InheritedWidget for efficient state access.
///
/// [_IStateModel] is an [InheritedWidget] that provides efficient access to
/// multiple state objects throughout the widget tree. It acts as a central
/// repository for application states and enables widgets to access specific
/// states without passing them through constructor parameters.
///
/// ## Purpose
///
/// The primary purpose of [_IStateModel] is to:
/// - Provide a centralized location for managing multiple application states
/// - Enable efficient state access through the inherited widget mechanism
/// - Support type-safe state retrieval
/// - Minimize rebuild overhead by controlling when widgets should update
///
/// ## How It Works
///
/// 1. **State Registration**: Accepts a list of [IState] objects during construction
/// 2. **Internal Mapping**: Creates a type-to-instance map for fast lookup
/// 3. **Inherited Access**: Uses Flutter's inherited widget system for efficient access
/// 4. **Type Safety**: Provides generic methods for type-safe state retrieval
///
/// ## Usage Pattern
///
/// Typically used within a state management widget like [IStatelessWidget]:
/// ```dart
/// // In your state management widget
/// _IStateModel(
///   states: [counterState, userState, authState],
///   child: YourAppContent(),
/// )
/// ```
///
/// ## State Access
///
/// Widgets can access states through the [of] method and [getState]:
/// ```dart
/// // Access the state model
/// final stateModel = _IStateModel.of(context);
///
/// // Get specific state
/// final counterState = stateModel.getState<CounterState>();
/// ```
///
/// ## Performance Characteristics
///
/// - **Fast Lookup**: O(1) state retrieval using internal map
/// - **Efficient Inheritance**: Leverages Flutter's optimized inherited widget system
/// - **Minimal Rebuilds**: Returns `false` from [updateShouldNotify] to prevent
///   unnecessary rebuilds of dependent widgets
/// - **Memory Efficient**: Single map structure for all state objects
///
/// ## Internal Architecture
///
/// ### State Storage
/// - Maintains a list of all states in [states]
/// - Creates a [Map<Type, IState>] in [_statesMap] for fast type-based lookup
/// - Uses [runtimeType] for mapping state instances to their types
///
/// ### Access Methods
/// - [of] - Static method to retrieve the nearest [_IStateModel] in the tree
/// - [getState] - Generic method to retrieve specific state types
///
/// ## Error Handling
///
/// Throws [StateError] when requesting a state type that hasn't been registered:
/// ```dart
/// // Throws: State of type MissingState not found
/// stateModel.getState<MissingState>();
/// ```
///
/// ## Type Safety
///
/// Provides compile-time type safety through generic methods:
/// ```dart
/// // Type-safe state access
/// final CounterState counter = stateModel.getState<CounterState>();
/// // IDE provides autocomplete for CounterState methods/properties
/// ```
///
/// ## Integration with StateBuilder
///
/// Works seamlessly with [StateBuilder] widgets:
/// ```dart
/// // StateBuilder automatically finds and uses _IStateModel
/// StateBuilder<CounterState>(
///   builder: (state) => Text('Count: ${state.value}'),
/// )
/// ```
///
/// ## Memory Management
///
/// - Holds references to all registered state objects
/// - Does not create additional copies of states
/// - Relies on Flutter's widget system for proper disposal
///
/// ## Best Practices
///
/// ### State Registration
/// ```dart
/// // Register all needed states at initialization
/// _IStateModel(
///   states: [
///     CounterState(),
///     UserState(),
///     AuthState(),
///   ],
///   child: MyApp(),
/// )
/// ```
///
/// ### State Retrieval
/// ```dart
/// // Cache the state model reference when possible
/// final stateModel = _IStateModel.of(context);
/// final userState = stateModel.getState<UserState>();
/// final counterState = stateModel.getState<CounterState>();
/// ```
///
/// ## Limitations
///
/// - States must be registered at construction time
/// - Cannot dynamically add/remove states after creation
/// - All states are kept in memory for the lifetime of the widget
/// - Single instance per type (no support for multiple instances of same type)
///
/// ## Testing
///
/// Can be easily mocked for testing purposes:
/// ```dart
/// // In tests
/// final mockStateModel = _IStateModel(
///   states: [MockCounterState(), MockUserState()],
///   child: Container(),
/// );
/// ```
///
/// ## Relationship with Flutter Framework
///
/// Inherits from [InheritedWidget] which provides:
/// - Automatic dependency tracking
/// - Efficient rebuild propagation
/// - Context-based access patterns
/// - Integration with Flutter's widget lifecycle
///
/// ## Common Patterns
///
/// ### Multiple State Management
/// ```dart
/// _IStateModel(
///   states: [
///     AppState(),
///     UserPreferencesState(),
///     NetworkState(),
///     ThemeState(),
///   ],
///   child: MaterialApp(
///     // Entire app can access these states
///     home: HomeScreen(),
///   ),
/// )
/// ```
///
/// ### Scoped State Management
/// ```dart
/// // Different _IStateModel instances for different scopes
/// Column(
///   children: [
///     _IStateModel(
///       states: [LocalCounterState()],
///       child: CounterSection(),
///     ),
///     _IStateModel(
///       states: [GlobalAppState()],
///       child: GlobalSection(),
///     ),
///   ],
/// )
/// ```
class _IStateModel extends InheritedWidget {
  /// List of all registered state objects.
  ///
  /// Contains all [IState] instances that this model manages.
  /// States are registered at construction time and cannot be
  /// dynamically added or removed.
  final List<IState> states;

  /// Internal map for fast type-based state lookup.
  ///
  /// Maps each state's runtime type to its instance for O(1) retrieval.
  /// Created once during construction and remains immutable.
  final Map<Type, IState> _statesMap;

  /// Creates an [_IStateModel] with the specified states.
  ///
  /// The [states] parameter must not be null and should contain
  /// all the state objects that need to be accessible within the [child] subtree.
  ///
  /// The [child] parameter must not be null and represents the widget
  /// subtree that will have access to these states.
  _IStateModel({required this.states, required super.child})
    : _statesMap = _createStatesMap(states);

  /// Creates a type-to-instance map from a list of states.
  ///
  /// Internal helper method that builds the [_statesMap] by iterating
  /// through all states and mapping their [runtimeType] to the instance.
  ///
  /// This allows for fast O(1) lookup of states by their type.
  static Map<Type, IState> _createStatesMap(List<IState> states) {
    final map = <Type, IState>{};
    for (var state in states) {
      map[state.runtimeType] = state;
    }
    return map;
  }

  /// Retrieves the nearest [_IStateModel] in the widget tree.
  ///
  /// Uses Flutter's inherited widget mechanism to find the closest
  /// [_IStateModel] ancestor. Returns null if no [_IStateModel] is found.
  ///
  /// This method is typically called by widgets that need to access states,
  /// such as [StateBuilder].
  ///
  /// Example:
  /// ```dart
  /// final stateModel = _IStateModel.of(context);
  /// if (stateModel != null) {
  ///   final counterState = stateModel.getState<CounterState>();
  /// }
  /// ```
  static _IStateModel? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_IStateModel>();
  }

  /// Retrieves a state of the specified type.
  ///
  /// Provides type-safe access to registered states. The generic type
  /// parameter [T] must extend [IState].
  ///
  /// Throws [StateError] if no state of the requested type has been registered.
  ///
  /// Example:
  /// ```dart
  /// final CounterState counter = stateModel.getState<CounterState>();
  /// final int currentValue = counter.value;
  /// ```
  T getState<T extends IState>() {
    final state = _statesMap[T];
    if (state == null) {
      throw StateError('State of type $T not found');
    }
    return state as T;
  }

  /// Controls whether dependent widgets should rebuild.
  ///
  /// Always returns `false` to prevent automatic rebuilds of widgets
  /// that depend on this inherited widget. This is because state changes
  /// are handled individually by each state's listeners (typically through
  /// [StateBuilder] or similar mechanisms), not by replacing the entire
  /// state model.
  ///
  /// This approach provides better performance by avoiding unnecessary
  /// rebuilds of the entire widget subtree when individual states change.
  @override
  bool updateShouldNotify(_IStateModel oldWidget) => false;
}
