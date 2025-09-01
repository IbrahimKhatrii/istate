part of internalState;

/// Base class for all application states.
///
/// [IState] is an abstract base class that provides the foundation for
/// application state management. It extends [ChangeNotifier] to enable
/// reactive UI updates and includes built-in support for hot reload
/// state preservation.
///
/// ## Purpose
///
/// The primary purpose of [IState] is to:
/// - Provide a consistent interface for application states
/// - Enable reactive UI updates through [ChangeNotifier]
/// - Support hot reload state preservation
/// - Offer type-safe state management
/// - Include built-in state lifecycle management
///
/// ## Core Features
///
/// ### Reactive Updates
/// - Extends [ChangeNotifier] for listener management
/// - Provides [notifyListeners()] integration
/// - Supports automatic UI rebuilds through [StateBuilder]
///
/// ### Hot Reload Preservation
/// - Optional [restorationId] parameter for state persistence
/// - Automatic saving/loading during development
/// - Transparent integration with Flutter's hot reload
///
/// ### Type Safety
/// - Generic type parameter [T] for compile-time type safety
/// - Type-safe value access and modification
/// - IDE autocomplete support for state operations
///
/// ## Usage Pattern
///
/// ```dart
/// // Define custom state classes
/// class CounterState extends IState<int> {
///   CounterState() : super(0, restorationId: 'counter');
///
///   void increment() => set(value + 1);
///   void decrement() => set(value - 1);
/// }
///
/// // Use in UI
/// StateBuilder<CounterState>(
///   builder: (state) => Text('Count: ${state.value}'),
/// )
/// ```
///
/// ## State Lifecycle
///
/// ### Creation
/// 1. Initialize with [_initialValue]
/// 2. Optionally restore from storage using [restorationId]
/// 3. Set up internal state management
///
/// ### Usage
/// 1. Access current value through [value] getter
/// 2. Modify state using [set()] method
/// 3. Reset to initial value with [reset()]
/// 4. Notify listeners automatically on changes
///
/// ### Disposal
/// 1. Clean up resources in [dispose()] method
/// 2. Remove from global state storage
/// 3. Release any held references
///
/// ## Hot Reload Support
///
/// ### Restoration Process
/// 1. Check if [restorationId] is provided
/// 2. Look up saved value in [_stateStorage]
/// 3. Restore value if found and type-compatible
/// 4. Log restoration success or failure
///
/// ### Storage Management
/// 1. Automatically save values when [set()] is called
/// 2. Store values by [restorationId] key
/// 3. Preserve state across hot reload sessions
/// 4. Handle type conversion errors gracefully
///
/// ## Performance Characteristics
///
/// ### Memory Efficiency
/// - Minimal overhead per state instance
/// - Efficient listener management through [ChangeNotifier]
/// - Optional storage only when [restorationId] is used
///
/// ### Update Efficiency
/// - O(1) value access through [value] getter
/// - Direct assignment in [set()] method
/// - Automatic listener notification
///
/// ## Error Handling
///
/// ### Type Safety
/// - Compile-time type checking through generics
/// - Runtime type checking during restoration
/// - Graceful handling of type conversion failures
///
/// ### Restoration Failures
/// - Logs errors without crashing the application
/// - Falls back to initial value on restoration failure
/// - Continues normal operation despite restoration issues
///
/// ## Integration Points
///
/// ### With StateBuilder
/// - Provides the reactive foundation for [StateBuilder]
/// - Enables automatic UI updates through [notifyListeners()]
/// - Supports type-safe state access
///
/// ### With Global State Manager
/// - Integrates with [_GlobalStateManager] for global access
/// - Supports the [state<T>()] global accessor function
/// - Participates in global state lifecycle management
///
/// ### With ChangeNotifier
/// - Inherits all [ChangeNotifier] functionality
/// - Provides standard listener management
/// - Supports Flutter's reactive programming patterns
///
/// ## Best Practices
///
/// ### State Definition
/// ```dart
/// class UserState extends IState<User> {
///   UserState() : super(User.empty(), restorationId: 'user');
///
///   void login(User user) => set(user);
///   void logout() => reset();
///   bool get isLoggedIn => value.id.isNotEmpty;
/// }
/// ```
///
/// ### Value Updates
/// ```dart
/// // Good: Use set() method for updates
/// void increment() => set(value + 1);
///
/// // Avoid: Direct value modification
/// // value++; // This won't notify listeners
/// ```
///
/// ### Complex State Management
/// ```dart
/// class TodoListState extends IState<List<Todo>> {
///   TodoListState() : super([], restorationId: 'todos');
///
///   void addTodo(Todo todo) => set([...value, todo]);
///   void removeTodo(Todo todo) => set(value.where((t) => t.id != todo.id).toList());
/// }
/// ```
///
/// ## Testing Considerations
///
/// ### Unit Testing
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
/// ### Restoration Testing
/// - Test state preservation across hot reloads
/// - Verify restoration with different data types
/// - Handle restoration failure scenarios
///
/// ## Common Patterns
///
/// ### Simple Value State
/// ```dart
/// class CounterState extends IState<int> {
///   CounterState() : super(0, restorationId: 'counter');
///   void increment() => set(value + 1);
/// }
/// ```
///
/// ### Complex Object State
/// ```dart
/// class AppState extends IState<AppData> {
///   AppState() : super(AppData.initial(), restorationId: 'app');
///
///   void updateTheme(ThemeMode theme) => set(value.copyWith(theme: theme));
///   void updateLocale(Locale locale) => set(value.copyWith(locale: locale));
/// }
/// ```
///
/// ### Collection State
/// ```dart
/// class ShoppingCartState extends IState<List<Product>> {
///   ShoppingCartState() : super([], restorationId: 'cart');
///
///   void addItem(Product product) => set([...value, product]);
///   void removeItem(Product product) => set(value.where((p) => p.id != product.id).toList());
///   double get total => value.fold(0, (sum, product) => sum + product.price);
/// }
/// ```
abstract class IState<T> extends ChangeNotifier {
  /// The current value of the state.
  ///
  /// This is the actively managed value that represents the current
  /// state of the application. Changes to this value automatically
  /// trigger UI updates for widgets listening to this state.
  ///
  /// Access this value through the getter, never modify it directly.
  /// Use the [set()] method to update the value and notify listeners.
  T _value;

  /// The initial value of the state.
  ///
  /// This represents the original value that the state was created with.
  /// It's used by the [reset()] method to restore the state to its
  /// initial condition. This value is immutable after construction.
  final T _initialValue;

  /// Optional identifier for hot reload state preservation.
  ///
  /// When provided, this ID is used to save and restore the state value
  /// during hot reload sessions. This enables seamless development
  /// experience by preserving state across code changes.
  ///
  /// If null, hot reload preservation is disabled for this state.
  final String? _restorationId;

  /// Creates a new state with an initial value.
  ///
  /// The [initialValue] parameter is required and sets the starting value
  /// for this state. The optional [restorationId] parameter enables hot
  /// reload state preservation.
  ///
  /// During construction, if [restorationId] is provided and a saved value
  /// exists in storage, the state will be restored to that saved value.
  ///
  /// Example:
  /// ```dart
  /// // Simple integer state with restoration
  /// class CounterState extends IState<int> {
  ///   CounterState() : super(0, restorationId: 'counter');
  /// }
  ///
  /// // Complex object state without restoration
  /// class UserState extends IState<User> {
  ///   UserState() : super(User.empty());
  /// }
  /// ```
  IState(this._initialValue, {String? restorationId})
    : _restorationId = restorationId ?? _generateAutoRestorationId(),
      _value = _initialValue {
    // Restore from storage if available
    if (_stateStorage.containsKey(_restorationId)) {
      try {
        _value = _stateStorage[_restorationId] as T;
        debugPrint('Restored $_restorationId = $_value');
      } catch (e) {
        debugPrint('Failed to restore $_restorationId: $e');
      }
    }
  }

  /// Generates an automatic restoration ID based on the class type.
  static String _generateAutoRestorationId() {
    // This is a placeholder - we'll override this in the factory
    return 'auto_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// The current value of the state.
  ///
  /// Returns the actively managed value that reflects the current
  /// state of the application. This getter provides read-only access
  /// to the state value.
  ///
  /// Example:
  /// ```dart
  /// StateBuilder<CounterState>(
  ///   builder: (state) => Text('Count: ${state.value}'),
  /// )
  /// ```
  T get value => _value;

  /// The initial value of the state.
  ///
  /// Returns the original value that this state was initialized with.
  /// This value remains constant throughout the lifetime of the state
  /// and is used by the [reset()] method.
  ///
  /// Example:
  /// ```dart
  /// void resetToDefault() {
  ///   // Reset to the initial value
  ///   set(initialValue);
  /// }
  /// ```
  T get initialValue => _initialValue;

  /// Updates the state value and notifies listeners.
  ///
  /// This method updates the internal [_value] and automatically calls
  /// [notifyListeners()] to trigger UI rebuilds for dependent widgets.
  /// If [restorationId] was provided during construction, the new value
  /// is also saved to persistent storage for hot reload preservation.
  ///
  /// Example:
  /// ```dart
  /// class CounterState extends IState<int> {
  ///   CounterState() : super(0);
  ///
  ///   void increment() => set(value + 1);
  ///   void decrement() => set(value - 1);
  ///   void setValue(int newValue) => set(newValue);
  /// }
  /// ```
  ///
  /// Note: Always use this method instead of direct value assignment
  /// to ensure proper listener notification and state persistence.
  void set(T newValue) {
    _value = newValue;
    notifyListeners();
    // Save to storage
    if (_restorationId != null) {
      _stateStorage[_restorationId] = newValue;
      debugPrint('Saved $_restorationId = $newValue');
    }
  }

  /// Resets the state to its initial value.
  ///
  /// Convenience method that sets the current value back to the
  /// [_initialValue] using the [set()] method. This automatically
  /// notifies listeners and handles state persistence.
  ///
  /// Example:
  /// ```dart
  /// class FormState extends IState<Map<String, String>> {
  ///   FormState() : super({});
  ///
  ///   void clearForm() => reset(); // Reset to empty map
  /// }
  /// ```
  void reset() => set(_initialValue);
}

/// Global accessor function for state access.
///
/// Provides a convenient way to access any registered state from anywhere
/// within an [IStatelessWidget] without needing to pass context or use
/// [_IStateModel.of(context)].
///
/// ## Purpose
///
/// The [state] function enables:
/// - Quick access to states without context dependency
/// - Global state access within state management scope
/// - Simplified state interaction in callbacks and methods
/// - Type-safe state retrieval with generic parameters
///
/// ## Usage Pattern
///
/// ```dart
/// // In event handlers and callbacks
/// onPressed: () => state<CounterState>().increment(),
///
/// // In business logic methods
/// void processUserAction() {
///   final userState = state<UserState>();
///   final counterState = state<CounterState>();
///
///   if (userState.isLoggedIn) {
///     counterState.increment();
///   }
/// }
///
/// // In computed properties
/// bool get canProceed => state<AuthState>().isAuthenticated;
/// ```
///
/// ## How It Works
///
/// 1. Uses [_GlobalStateManager] to find the requested state type
/// 2. Provides type-safe access through generic type parameter [T]
/// 3. Returns the exact state instance registered in the current scope
/// 4. Throws if the requested state type is not available
///
/// ## Performance Considerations
///
/// - O(1) lookup through global state manager
/// - No widget tree traversal required
/// - Minimal overhead for state access
/// - Cached state references for fast retrieval
///
/// ## Error Handling
///
/// Throws [StateError] if the requested state type is not registered:
/// ```dart
/// // Throws: State of type MissingState not found
/// final missing = state<MissingState>();
/// ```
///
/// ## Best Practices
///
/// ### Event Handler Usage
/// ```dart
/// // Good: Direct usage in event handlers
/// ElevatedButton(
///   onPressed: () => state<CounterState>().increment(),
///   child: Text('Increment'),
/// )
/// ```
///
/// ### Method Integration
/// ```dart
/// class BusinessLogic {
///   void handleUserLogin(User user) {
///     state<AuthState>().login(user);
///     state<AnalyticsState>().logLogin();
///     state<NavigationState>().goToHome();
///   }
/// }
/// ```
///
/// ### Computed Properties
/// ```dart
/// class AppState extends IState<AppData> {
///   // Computed property using global state access
///   bool get hasUnreadMessages => state<MessageState>().unreadCount > 0;
///
///   bool get canSave => state<AuthState>().isAuthenticated &&
///                      state<NetworkState>().isConnected;
/// }
/// ```
///
/// ## Testing
///
/// Can be easily mocked or tested in isolation:
/// ```dart
/// void main() {
///   test('Global state access works correctly', () {
///     // Setup would involve registering states with GlobalStateManager
///     final counter = state<CounterState>();
///     expect(counter.value, 0);
///   });
/// }
/// ```
///
/// ## Limitations
///
/// - Only works within the scope of a registered [_IStateModel]
/// - Requires states to be properly registered before access
/// - No compile-time guarantee that states exist (runtime lookup)
/// - Potential for runtime errors if states are not available
///
/// ## Integration with State Management
///
/// Works seamlessly with:
/// - [_IStateModel] for state registration and access
/// - [_GlobalStateManager] for global state lookup
/// - [StateBuilder] for reactive UI updates
/// - [IState] for state definition and management
T state<T extends IState>() {
  return _GlobalStateManager.getState<T>();
}
