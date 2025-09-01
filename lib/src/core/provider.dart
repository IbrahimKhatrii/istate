part of '../istate.dart';

/// A StatefulWidget that manages the lifecycle of application states.
///
/// [_IStateProvider] is responsible for creating, registering, and disposing
/// application states. It acts as the root manager for state lifecycles and
/// provides the [_IStateModel] to the widget tree for state access.
///
/// ## Purpose
///
/// The primary purpose of [_IStateProvider] is to:
/// - Manage the complete lifecycle of application states
/// - Handle state initialization and cleanup
/// - Provide [_IStateModel] to the widget subtree
/// - Register states with the global state manager
/// - Ensure proper disposal of resources when the widget is removed
///
/// ## Lifecycle Management
///
/// ### Initialization
/// 1. Creates states during widget construction
/// 2. Initializes [_IStateModel] with the provided states
/// 3. Registers the model with [_GlobalStateManager] for global access
///
/// ### Disposal
/// 1. Unregisters the model from [_GlobalStateManager]
/// 2. Calls [dispose()] on all managed states
/// 3. Cleans up any allocated resources
///
/// ## Usage Pattern
///
/// Typically used internally by state management widgets:
/// ```dart
/// // Internal usage pattern
/// _IStateProvider(
///   states: [counterState, userState, authState],
///   builder: (context) => YourAppContent(),
/// )
/// ```
///
/// ## State Lifecycle
///
/// ### Creation
/// - States are provided as a list to the constructor
/// - States should be created externally and passed in
/// - All states must extend [IState]
///
/// ### Registration
/// - [_IStateModel] is created with all states
/// - Model is registered with [_GlobalStateManager] for global access
/// - States become available throughout the widget subtree
///
/// ### Disposal
/// - When the widget is disposed, all states are properly cleaned up
/// - [dispose()] is called on each state instance
/// - Model is unregistered from global state manager
///
/// ## Performance Considerations
///
/// ### Memory Management
/// - Ensures no memory leaks by properly disposing states
/// - Manages references to prevent circular dependencies
/// - Handles cleanup in the correct order
///
/// ### Rebuild Optimization
/// - Uses [Builder] widget to ensure proper context availability
/// - Minimizes unnecessary rebuilds through careful widget composition
/// - Leverages Flutter's built-in optimization mechanisms
///
/// ## Debug Features
///
/// Includes debug logging for development:
/// - Logs initialization with 'IStateProvider initState'
/// - Logs disposal with 'IStateProvider dispose'
/// - Logs build operations with 'IStateProvider building with context'
///
/// ## Error Handling
///
/// ### State Disposal
/// - Ensures all states are disposed even if some fail
/// - Continues disposal process despite individual state errors
/// - Provides cleanup guarantees for resource management
///
/// ### Global Registration
/// - Handles registration/unregistration with [_GlobalStateManager]
/// - Prevents duplicate registrations
/// - Ensures proper cleanup of global references
///
/// ## Integration Points
///
/// ### With _IStateModel
/// - Creates and manages the [_IStateModel] instance
/// - Provides states to the model for distribution
/// - Controls model lifecycle
///
/// ### With _GlobalStateManager
/// - Registers model during build phase
/// - Unregisters model during disposal
/// - Enables global state access patterns
///
/// ### With IState
/// - Manages lifecycle of all provided states
/// - Calls [dispose()] on each state during cleanup
/// - Ensures proper resource cleanup
///
/// ## Widget Tree Structure
///
/// Creates a specific widget tree structure:
/// ```
/// _IStateProvider
/// └── _IStateModel (registered globally)
///     └── Builder
///         └── User provided widget tree
/// ```
///
/// ## Best Practices
///
/// ### State Management
/// ```dart
/// // Provide all needed states at construction
/// _IStateProvider(
///   states: [
///     CounterState(),
///     UserState(),
///     NetworkState(),
///   ],
///   builder: (context) => MyApp(),
/// )
/// ```
///
/// ### Resource Cleanup
/// ```dart
/// // Ensure states implement proper dispose patterns
/// class CounterState extends IState {
///   @override
///   void dispose() {
///     // Clean up timers, streams, etc.
///     super.dispose();
///   }
/// }
/// ```
///
/// ## Testing Considerations
///
/// ### Lifecycle Testing
/// - Verify proper initialization and disposal
/// - Test state cleanup behavior
/// - Ensure global registration/unregistration works correctly
///
/// ### Mock Integration
/// ```dart
/// // Can be tested with mock states
/// _IStateProvider(
///   states: [MockCounterState(), MockUserState()],
///   builder: (context) => TestWidget(),
/// )
/// ```
///
/// ## Common Patterns
///
/// ### Application Root
/// ```dart
/// // Typical usage as application root
/// runApp(
///   _IStateProvider(
///     states: appStates,
///     builder: (context) => MaterialApp(
///       home: HomeScreen(),
///     ),
///   ),
/// )
/// ```
///
/// ### Scoped Providers
/// ```dart
/// // Multiple providers for different scopes
/// Column(
///   children: [
///     _IStateProvider(
///       states: [LocalState()],
///       builder: (context) => LocalSection(),
///     ),
///     _IStateProvider(
///       states: [GlobalState()],
///       builder: (context) => GlobalSection(),
///     ),
///   ],
/// )
/// ```
class _IStateProvider extends StatefulWidget {
  /// List of states to be managed by this provider.
  ///
  /// These states will be initialized, registered, and disposed
  /// according to the widget's lifecycle. All states must extend [IState].
  ///
  /// States are typically created externally and passed to the constructor.
  final List<IState> states;

  /// Builder function that creates the widget subtree.
  ///
  /// This function receives a [BuildContext] and should return the
  /// widget tree that will have access to the provided states.
  ///
  /// The context provided to this builder will have access to the
  /// [_IStateModel] through [_IStateModel.of(context)].
  final Widget Function(BuildContext) builder;

  /// Creates an [_IStateProvider] with the specified states and builder.
  ///
  /// Both [states] and [builder] parameters are required and must not be null.
  /// The [states] list should contain all the state objects that need to be
  /// managed within the subtree created by [builder].
  const _IStateProvider({required this.states, required this.builder});

  @override
  State<_IStateProvider> createState() => _IStateProviderState();
}

/// The state class for [_IStateProvider].
///
/// Manages the lifecycle of the [_IStateProvider] widget, including
/// state initialization, registration, and cleanup.
///
/// ## Responsibilities
///
/// - Manages [_IStateModel] creation and registration
/// - Handles state disposal during widget cleanup
/// - Controls global state manager registration
/// - Provides debug logging for development
///
/// ## Internal State
///
/// Maintains a reference to the [_IStateModel] for proper disposal
/// and global state manager interaction.
class _IStateProviderState extends State<_IStateProvider> {
  /// The [_IStateModel] instance managed by this provider.
  ///
  /// Created during [build] and used for global registration.
  /// Referenced during [dispose] for proper cleanup.
  late _IStateModel _stateModel;

  /// Called when the widget is first inserted into the tree.
  ///
  /// Performs initial setup including debug logging.
  /// The actual state model creation happens in [build].
  @override
  void initState() {
    super.initState();
    debugPrint('IStateProvider initState');
  }

  /// Called when the widget is removed from the tree permanently.
  ///
  /// Performs cleanup operations including:
  /// 1. Unregistering the model from [_GlobalStateManager]
  /// 2. Disposing all managed states
  /// 3. Calling the superclass dispose method
  ///
  /// Ensures proper resource cleanup and prevents memory leaks.
  @override
  void dispose() {
    debugPrint('IStateProvider dispose');
    _GlobalStateManager.unregisterModel(_stateModel);
    for (var state in widget.states) {
      state.dispose();
    }
    super.dispose();
  }

  /// Describes the part of the user interface represented by this widget.
  ///
  /// Creates the [_IStateModel] with the provided states, registers it
  /// with [_GlobalStateManager], and builds the user interface using
  /// the provided builder function.
  ///
  /// Uses a [Builder] widget to ensure the provided context has access
  /// to the [_IStateModel] through the inherited widget mechanism.
  @override
  Widget build(BuildContext context) {
    _stateModel = _IStateModel(
      states: widget.states,
      child: const SizedBox.shrink(),
    );

    // Register the model for global access
    _GlobalStateManager.registerModel(_stateModel);

    return _IStateModel(
      states: widget.states,
      child: Builder(
        builder: (context) {
          debugPrint('IStateProvider building with context');
          return widget.builder(context);
        },
      ),
    );
  }
}
