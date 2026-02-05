# Architecture Overview

## Purpose & Scope

The SDK Showcase app demonstrates the OMI SDK for iOS using a modern SwiftUI architecture. This document explains the architectural patterns, design decisions, and component relationships that make up the application.

**Scope:**  
- SwiftUI-based declarative UI architecture
- Dependency injection pattern using Swinject
- State management with ObservableObject and @Published properties
- Interactor pattern for business logic separation
- Integration with OMI SDK

**Target Audience:** Developers new to the project who want to understand how the app is structured and how to extend it.

---

## SwiftUI Architecture

The app follows a **declarative UI paradigm** where the user interface is a pure function of the application state. This means:

- **Views** describe what the UI should look like based on current state
- **State changes** automatically trigger UI updates
- **Data flows unidirectionally** from state to views

### Architecture Diagram

```mermaid
graph TD
    A[Views] -->|User Actions| B[Interactors]
    B -->|Business Logic| C[OMI SDK]
    C -->|Callbacks/Delegates| B
    B -->|Update State| D[ShowcaseApp State]
    D -->|@Published| A
    
    E[Dependency Injection Container] -.->|Provides| B
    E -.->|Provides| D
    
    style A fill:#e1f5fe
    style B fill:#fff3e0
    style C fill:#f3e5f5
    style D fill:#e8f5e9
    style E fill:#fce4ec
```

---

## Dependency Injection Pattern

The app uses **Swinject** for dependency injection, centralizing object creation and lifetime management.

### Container Setup

All dependencies are registered in a single container (`Injection.swift`):

```swift
final class Injection {
    static let shared = Injection()
    private var internalContainer: Container?
    
    var container: Container {
        get { internalContainer ?? buildContainer() }
    }
}
```

### Registration Pattern

Components are registered with their dependencies:

```swift
container.register(SDKInteractor.self) { resolver in
    SDKInteractorReal(app: resolver.resolve(ShowcaseApp.self)!)
}.inObjectScope(.container)
```

### Injection via Property Wrapper

Dependencies are injected using the `@Injected` property wrapper:

```swift
@propertyWrapper
struct Injected<Dependency> {
    var wrappedValue: Dependency
    
    init() {
        wrappedValue = Injection.shared.container.resolve(Dependency.self)!
    }
}

// Usage in code:
@Injected var interactors: Interactors
```

**Benefits:**
- Loose coupling between components
- Easy testing (mock dependencies)
- Centralized configuration
- Single source of truth for object lifetimes

---

## State Management

State is managed through **ObservableObject** classes that publish changes to SwiftUI views.

### Core State Classes

| State Class | Responsibility | Key Properties |
|------------|----------------|----------------|
| `ShowcaseApp` | Root application state | `system`, `routing`, `deviceData`, `registeredUsers`, `pendingTransactions` |
| `System` | SDK and user state | `isSDKInitialized`, `userState`, `enrollmentState`, `pinPadState`, `scannerState` |
| `DeviceData` | Device configuration | `deviceId`, `model`, `certs`, `publicKey` |
| `ViewRouting` | Navigation state | `navPath`, `navCategory` |

### State Publishing Pattern

```swift
class System: Equatable, ObservableObject {
    @Published var isSDKInitialized = false
    @Published var isProcessing = false
    @Published private(set) var userState: UserState = .notRegistered
    @Published private(set) var enrollmentState: EnrollmentState = .unenrolled
    
    // State mutations with validation
    func setUserState(_ newState: UserState) {
        userState = newState
    }
}
```

**Key Patterns:**
- Use `@Published` for properties that trigger UI updates
- Use `private(set)` for controlled state mutations
- Provide setter methods that encapsulate state transition logic
- Keep state classes `Equatable` for change detection

---

## Key Components

### 1. ShowcaseApp (Root State)

**File:** `ShowcaseApp.swift`

The main application state container that holds all global state:

```swift
class ShowcaseApp: ObservableObject {
    @Published var system = System()
    @Published var routing = ViewRouting()
    @Published var deviceData = DeviceData()
    @Published var registeredUsers = Set<UserData>()
    @Published var pendingTransactions = Set<PendingMobileAuthRequestEntity>()
}
```

### 2. Interactors (Business Logic Layer)

**Directory:** `SDK Showcase/SDK Showcase/Interactors/`

Interactors encapsulate all SDK-related business logic:

| Interactor | Responsibility |
|-----------|----------------|
| `SDKInteractor` | SDK initialization, configuration, reset |
| `RegistrationInteractor` | User registration flows (browser, custom) |
| `AuthenticatorInteractor` | User authentication, logout, SSO |
| `AuthenticatorRegistrationInteractor` | Authenticator registration/management |
| `MobileAuthRequestInteractor` | Mobile auth enrollment, push handling |
| `PinPadInteractor` | PIN creation, validation, changes |
| `QRScannerInteractor` | QR code scanning for registration/auth |
| `ResourceInteractor` | API resource requests |
| `PushNotitificationsInteractor` | Push notification registration |

**Pattern:**

```swift
protocol AuthenticatorInteractor {
    func authenticateUser(profileName: String, optionName: String)
    func logout(optionName: String)
    // ... other methods
}

class AuthenticatorInteractorReal: AuthenticatorInteractor {
    @ObservedObject var app: ShowcaseApp
    private let userClient = SharedUserClient.instance
    
    // Implementation delegates to SDK and updates app state
}
```

### 3. States (UI State Enums)

**Directory:** `SDK Showcase/SDK Showcase/States/`

Type-safe enums representing UI states:

```swift
enum UserState: Equatable {
    case notRegistered
    case registered
    case authenticated(String)  // with userId
    case unauthenticated
    case stateless
}

enum PinPadState {
    case hidden
    case createPin
    case validatePin
    case changePin
}
```

### 4. Models (Data Structures)

**Directory:** `SDK Showcase/SDK Showcase/Model/`

Data models conforming to `AppModel` protocol:

```swift
protocol AppModel: Identifiable, Hashable {}

struct Category: AppModel {
    let name: String
    let description: String
    let options: [Option]
    var selections: [Selection]
    let requiredActions: [Action]
    let optionalActions: [Action]
}
```

### 5. Views (SwiftUI UI Layer)

**Directory:** `SDK Showcase/SDK Showcase/Views/`

SwiftUI views that render the UI based on state:

- `ContentView` - Main application view
- `RootView` - Navigation root
- `ActionView` - Action execution views
- `PinPad` - PIN entry interface
- `QRScannerPresenter` - QR scanning interface
- Sheet views for modals (authenticators, transactions, prompts)

---

## Data Flow Example

### User Authentication Flow

1. **User Action:** User taps "Authenticate" button in `ActionView`
2. **View calls Interactor:**
   ```swift
   authenticatorInteractor.authenticateUser(profileName: userId, optionName: "PIN")
   ```
3. **Interactor delegates to SDK:**
   ```swift
   userClient.authenticate(userProfile: profile, authenticator: authenticator)
   ```
4. **SDK triggers delegate callback:**
   ```swift
   func userClient(_ userClient: UserClient, didReceivePinChallenge challenge: PinChallenge)
   ```
5. **Interactor updates app state:**
   ```swift
   app.system.setPinPadState(.validatePin)
   ```
6. **SwiftUI re-renders:** `@Published` property change triggers view update
7. **User enters PIN:** `PinPad` view shown
8. **PIN validated:** Interactor handles validation
9. **Success:** State updated to `.authenticated(userId)`
10. **View updates:** Authentication complete, UI reflects new state

---

## Operational Notes

### Thread Safety

- All UI state updates occur on the **main thread** via `@MainActor` or `DispatchQueue.main`
- SDK callbacks may arrive on background threads - always dispatch state changes to main thread
- Use `@Published` properties which automatically publish on the main thread

### State Synchronization

- The `ShowcaseApp` instance is the single source of truth
- Child views receive state via SwiftUI's environment or direct injection
- Use `@ObservedObject` for externally owned state
- Use `@StateObject` for view-owned state

### Error Handling

- Errors are captured in interactors and converted to user-friendly messages
- System state includes `lastInfoDescription` for displaying error/info messages
- Critical errors reset relevant state to safe defaults

### Memory Management

- Dependency injection container uses `.container` scope (singleton-like)
- Views are value types (structs) - no retain cycles
- Interactors hold weak references to delegates where appropriate
- Use `[weak self]` in closures to prevent retain cycles

---

## Assumptions Made

- Developers understand SwiftUI basics (`@State`, `@Published`, `ObservableObject`)
- Familiarity with delegate pattern and protocol-oriented programming
- Basic understanding of dependency injection concepts
- iOS development environment is properly configured

## Open Questions

- Should we add Combine publishers for complex event streams?
- Consider adopting Swift Concurrency (async/await) for SDK operations?
- Evaluate replacing Swinject with native Swift dependency injection?

**Last Reviewed:** 2026-02-05
