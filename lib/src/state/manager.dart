part of '../istate.dart';

/// Robust global accessor that handles hot reload transitions.
///
/// [_GlobalStateManager] is a singleton-like class that manages active
/// state models and provides global access to states throughout the
/// application. It handles the complexities of hot reload transitions
/// and ensures proper state access across different lifecycle phases.
///
/// ## Purpose
///
/// The primary purpose of [_GlobalStateManager] is to:
/// - Provide global state access without context dependency
/// - Manage multiple active state models during transitions
/// - Handle hot reload scenarios gracefully
/// - Prevent memory leaks through model lifecycle management
/// - Enable robust state retrieval across complex widget hierarchies
///
/// ## Core Functionality
///
/// ### Model Registration
/// - Tracks active [_IStateModel] instances
/// - Manages model lifecycle during hot reload
/// - Prevents duplicate model registration
/// - Implements automatic cleanup mechanisms
///
/// ### State Access
/// - Provides global [getState<T>()] method
/// - Searches across multiple active models
/// - Handles missing state scenarios gracefully
/// - Ensures type-safe state retrieval
///
/// ## Hot Reload Handling
///
/// ### Transition Management
/// - Maintains multiple models during hot reload transitions
/// - Preserves state access continuity
/// - Handles temporary duplicate model scenarios
/// - Manages cleanup of obsolete models
///
/// ### Memory Management
/// - Limits active models to prevent memory leaks
/// - Automatically removes old models
/// - Ensures proper resource cleanup
/// - Maintains efficient storage patterns
///
/// ## Architecture
///
/// ### Singleton Pattern
/// - Uses static methods and properties
/// - Single point of access for global state
/// - Centralized model management
/// - Thread-safe operations (Dart single-threaded model)
///
/// ### Model Tracking
/// - Maintains list of [_activeModels]
/// - Tracks model registration/unregistration
/// - Implements FIFO cleanup for old models
/// - Provides debug information for development
///
/// ## Usage Pattern
///
/// Typically used internally by the [state<T>()] global function:
/// ```dart
/// // Internal usage through global accessor
/// final counterState = _GlobalStateManager.getState<CounterState>();
/// ```
///
/// ## Model Lifecycle Management
///
/// ### Registration Process
/// 1. Remove duplicate models with same state collections
/// 2. Add new model to active models list
/// 3. Enforce maximum model limit (5 models)
/// 4. Remove oldest model if limit exceeded
/// 5. Log registration for debugging
///
/// ### Unregistration Process
/// 1. Remove specified model from active list
/// 2. Log unregistration for debugging
/// 3. Allow natural garbage collection
///
/// ## Performance Characteristics
///
/// ### Memory Efficiency
/// - Limits active models to prevent unbounded growth
/// - Uses efficient list operations
/// - Implements automatic cleanup
/// - Minimizes memory footprint
///
/// ### Access Speed
/// - O(n) state retrieval where n is number of active models
/// - Reverse iteration for most recent models first
/// - Early exit on first successful match
/// - Minimal overhead for successful lookups
///
/// ## Error Handling
///
/// ### No Active Models
/// Throws [FlutterError] with helpful message when no models are registered:
/// ```dart
/// // Error: state<T>() must be called within IStatelessWidget context
/// ```
///
/// ### State Not Found
/// Throws [StateError] when requested state type isn't available:
/// ```dart
/// // Error: State of type MissingState not found in any active model
/// ```
///
/// ### Graceful Degradation
/// - Continues searching through available models
/// - Handles individual model failures gracefully
/// - Provides meaningful error messages
/// - Maintains system stability
///
/// ## Integration Points
///
/// ### With _IStateModel
/// - Manages registration/unregistration lifecycle
/// - Coordinates with model's [getState<T>()] method
/// - Handles multiple concurrent models
///
/// ### With IStatelessWidget
/// - Enables global state access pattern
/// - Supports hot reload transitions
/// - Provides seamless development experience
///
/// ### With state<\T>() Function
/// - Serves as the backend for global accessor
/// - Provides the actual implementation
/// - Handles all error scenarios
///
/// ## Best Practices
///
/// ### Model Management
/// ```dart
/// // Automatic management through _IStateProvider
/// _IStateProvider(
///   states: appStates,
///   builder: (context) => MyApp(),
/// )
/// // Registration/unregistration handled automatically
/// ```
///
/// ### State Access
/// ```dart
/// // Use through global accessor function
/// onPressed: () => state<CounterState>().increment(),
/// ```
///
/// ## Testing Considerations
///
/// ### Test Isolation
/// - Consider clearing active models between tests
/// - Mock model registration for controlled testing
/// - Verify error handling scenarios
/// - Test multiple model scenarios
///
/// ### Debug Information
/// - Provides detailed logging for development
/// - Helps diagnose registration issues
/// - Tracks model lifecycle events
/// - Assists in debugging hot reload scenarios
///
/// ## Limitations
///
/// ### Model Limit
/// - Maximum of 5 active models to prevent memory leaks
/// - May need adjustment for complex applications
/// - FIFO cleanup may remove needed models in edge cases
///
/// ### Context Dependency
/// - Still requires models to be properly registered
/// - No true global access without proper setup
/// - Dependent on widget tree initialization
///
/// ## Common Patterns
///
/// ### Standard Usage
/// ```dart
/// // In business logic or event handlers
/// void handleUserAction() {
///   final authState = state<AuthState>();
///   final counterState = state<CounterState>();
///
///   if (authState.isAuthenticated) {
///     counterState.increment();
///   }
/// }
/// ```
///
/// ### Multiple Model Scenarios
/// ```dart
/// // During hot reload transitions
/// // Old model: [CounterState(5), UserState("John")]
/// // New model: [CounterState(0), UserState("Jane"), ThemeState()]
/// // Global manager handles transition seamlessly
/// ```
class _GlobalStateManager {
  /// List of currently active state models.
  ///
  /// Maintains references to all registered [_IStateModel] instances
  /// to enable global state access. Limited to 5 models to prevent
  /// memory leaks during hot reload scenarios.
  ///
  /// Models are searched in reverse order (most recent first) to
  /// prioritize currently active states during transitions.
  static final List<_IStateModel> _activeModels = [];

  /// Registers a state model for global access.
  ///
  /// Adds the provided [_IStateModel] to the list of active models,
  /// making its states available through global access. Implements
  /// several safety measures:
  ///
  /// 1. **Duplicate Prevention**: Removes any existing models with
  ///    the same state collection to prevent duplicates
  ///
  /// 2. **Memory Management**: Limits total active models to 5,
  ///    removing the oldest when the limit is exceeded
  ///
  /// 3. **Debug Tracking**: Logs registration events for development
  ///
  /// This method is typically called automatically by [_IStateProvider]
  /// during widget build operations.
  ///
  /// Example:
  /// ```dart
  /// // Automatic registration through _IStateProvider
  /// _IStateProvider(
  ///   states: [counterState, userState],
  ///   builder: (context) => MyApp(),
  /// )
  /// ```
  static void registerModel(_IStateModel model) {
    // Remove any existing models to prevent duplicates
    _activeModels.removeWhere((m) => m.states == model.states);
    _activeModels.add(model);

    // Keep only recent models (prevent memory leaks)
    if (_activeModels.length > 5) {
      _activeModels.removeAt(0);
    }

    debugPrint('Registered model. Active models: ${_activeModels.length}');
  }

  /// Unregisters a state model from global access.
  ///
  /// Removes the specified [_IStateModel] from the list of active models,
  /// making its states no longer accessible through global access. This
  /// is typically called during widget disposal to prevent memory leaks
  /// and ensure proper resource cleanup.
  ///
  /// This method is typically called automatically by [_IStateProvider]
  /// during widget disposal operations.
  ///
  /// Example:
  /// ```dart
  /// // Automatic unregistration through _IStateProvider disposal
  /// @override
  /// void dispose() {
  ///   _GlobalStateManager.unregisterModel(_stateModel);
  ///   // ... other cleanup
  /// }
  /// ```
  static void unregisterModel(_IStateModel model) {
    _activeModels.remove(model);
    debugPrint('Unregistered model. Active models: ${_activeModels.length}');
  }

  /// Retrieves a state of the specified type from active models.
  ///
  /// Searches through all currently active models (most recent first)
  /// to find a state of the requested type [T]. This approach handles
  /// hot reload scenarios where multiple models might be temporarily
  /// active during transitions.
  ///
  /// The search process:
  /// 1. Checks if any models are registered, throws [FlutterError] if none
  /// 2. Iterates through models in reverse order (newest first)
  /// 3. Attempts to retrieve state from each model
  /// 4. Returns first successful match
  /// 5. Throws [StateError] if no model contains the requested state
  ///
  /// This method is typically accessed through the global [state<T>()] function.
  ///
  /// Example:
  /// ```dart
  /// // Through global accessor
  /// final counterState = state<CounterState>();
  ///
  /// // Internally calls:
  /// // _GlobalStateManager.getState<CounterState>();
  /// ```
  ///
  /// Throws:
  /// - [FlutterError] if no active models are registered
  /// - [StateError] if requested state type is not found in any model
  static T getState<T extends IState>() {
    if (_activeModels.isEmpty) {
      throw FlutterError(
        'state<T>() must be called within IStatelessWidget context.\n'
        'Make sure you are calling this from within an IStatelessWidget or its children.',
      );
    }

    // Try to get state from active models (most recent first)
    for (final model in _activeModels.reversed) {
      try {
        return model.getState<T>();
      } catch (e) {
        continue;
      }
    }

    throw StateError('State of type $T not found in any active model');
  }
}
