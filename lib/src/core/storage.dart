part of '../istate.dart';

/// Global storage map for state persistence during hot reload.
///
/// [_stateStorage] is a top-level map that provides temporary storage
/// for state values that need to be preserved across hot reload sessions.
/// It uses string keys (typically [restorationId] values) to store
/// dynamic state values, enabling seamless development experience.
///
/// ## Purpose
///
/// The primary purpose of [_stateStorage] is to:
/// - Preserve state values during Flutter hot reload
/// - Enable seamless development workflow
/// - Maintain application state across code changes
/// - Provide transparent state persistence for developers
///
/// ## How Hot Reload Preservation Works
///
/// 1. **Storage Registration**: States with [restorationId] automatically
///    save their values to [_stateStorage] when [set()] is called
///
/// 2. **Value Restoration**: During state construction, if a [restorationId]
///    exists in [_stateStorage], the saved value is restored
///
/// 3. **Transparent Operation**: The process is automatic and requires
///    no manual intervention from developers
///
/// ## Storage Characteristics
///
/// ### Key-Value Structure
/// - **Keys**: String identifiers (restoration IDs)
/// - **Values**: Dynamic values of any type
/// - **Access**: Direct map operations with O(1) average complexity
///
/// ### Lifecycle
/// - **Creation**: Initialized as empty map at application startup
/// - **Population**: Populated during state [set()] operations
/// - **Persistence**: Maintained across hot reload sessions
/// - **Clearing**: Automatically cleared when app is fully restarted
///
/// ## Performance Considerations
///
/// ### Memory Usage
/// - Stores only states with explicit [restorationId]
/// - Uses efficient map data structure
/// - Minimal memory overhead for non-preserved states
///
/// ### Access Speed
/// - O(1) average lookup time
/// - Direct map operations without additional processing
/// - No serialization/deserialization overhead
///
/// ## Type Safety
///
/// While the storage uses [dynamic] values for flexibility:
/// - Type casting is performed during restoration
/// - Errors are caught and logged gracefully
/// - Fallback to initial values on type mismatches
///
/// ## Error Handling
///
/// ### Type Conversion Errors
/// ```dart
/// // If restoration fails due to type mismatch:
/// // Logs: "Failed to restore counter: type 'String' is not a subtype of type 'int'"
/// // Continues operation with initial value
/// ```
///
/// ### Missing Keys
/// - Silently continues without restoration
/// - Uses initial state values
/// - No error thrown for missing restoration data
///
/// ## Usage Examples
///
/// ### Automatic Usage
/// ```dart
/// class CounterState extends IState<int> {
///   CounterState() : super(0, restorationId: 'counter');
///   // [_stateStorage] is automatically used for persistence
/// }
/// ```
///
/// ### Manual Interaction (Rare)
/// ```dart
/// // Generally not recommended, but possible:
/// _stateStorage['custom_key'] = someValue;
/// final value = _stateStorage['custom_key'];
/// ```
///
/// ## Development Workflow Benefits
///
/// ### Hot Reload Preservation
/// - Counter values maintained during UI tweaks
/// - Form data preserved while adjusting layouts
/// - User session state kept during development
///
/// ### Productivity Gains
/// - No need to manually re-enter test data
/// - Faster iteration on UI components
/// - Reduced development friction
///
/// ## Limitations
///
/// ### Scope Restrictions
/// - Only works during development hot reload
/// - Not persisted across full application restarts
/// - Not suitable for production data storage
///
/// ### Type Constraints
/// - Relies on Dart's type system for safety
/// - May fail with complex custom types
/// - Requires compatible types across reloads
///
/// ## Best Practices
///
/// ### State Design
/// ```dart
/// // Good: Use simple, serializable types
/// class CounterState extends IState<int> {
///   CounterState() : super(0, restorationId: 'counter');
/// }
///
/// // Caution: Complex objects may have restoration issues
/// class ComplexState extends IState<CustomObject> {
///   ComplexState() : super(CustomObject(), restorationId: 'complex');
/// }
/// ```
///
/// ### Restoration ID Management
/// ```dart
/// // Use unique, descriptive IDs
/// class UserState extends IState<User> {
///   UserState() : super(User.empty(), restorationId: 'user_profile_v1');
/// }
/// ```
///
/// ## Testing Considerations
///
/// ### Test Environment
/// - Storage persists across test runs in same session
/// - May affect test isolation if not properly managed
/// - Consider clearing storage between tests
///
/// ### Mock Scenarios
/// ```dart
/// // For testing restoration behavior:
/// _stateStorage['test_counter'] = 42;
/// // Create state with restorationId: 'test_counter'
/// // Verify it restores to 42 instead of initial value
/// ```
///
/// ## Integration Points
///
/// ### With IState
/// - Automatically integrated through [restorationId]
/// - Used in constructor for value restoration
/// - Updated during [set()] method calls
///
/// ### With Development Tools
/// - Works seamlessly with Flutter DevTools
/// - Integrates with IDE hot reload features
/// - Supports command-line hot reload operations
///
/// ## Common Patterns
///
/// ### Simple Value Preservation
/// ```dart
/// class CounterState extends IState<int> {
///   CounterState() : super(0, restorationId: 'app_counter');
///   // Value automatically preserved during hot reload
/// }
/// ```
///
/// ### Multiple State Types
/// ```dart
/// // Different states with unique restoration IDs
/// class CounterState extends IState<int> {
///   CounterState() : super(0, restorationId: 'counter');
/// }
///
/// class NameState extends IState<String> {
///   NameState() : super('', restorationId: 'user_name');
/// }
///
/// class FlagsState extends IState<List<bool>> {
///   FlagsState() : super([], restorationId: 'feature_flags');
/// }
/// ```
final _stateStorage = <String, dynamic>{};
