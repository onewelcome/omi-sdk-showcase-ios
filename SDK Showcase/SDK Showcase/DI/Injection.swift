//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import Swinject

final class Injection {
    static let shared = Injection()
    
    var container: Container {
        get {
            _container ?? buildContainer()
        }
        set {
            _container = newValue
        }
    }

    private var _container: Container?
    private func buildContainer() -> Container {
        let container = Container()
        
        // Global objects
        container.register(AppState.self) { _ in AppState() }
        container.register(Interactors.self) { resolver in
            Interactors(categoriesInteractor: resolver.resolve(CategoriesInteractor.self)!,
                        sdkInteractor: resolver.resolve(SDKInteractor.self)!)
        }

        // Objects require network connection. For test purposes should be mocked
        #if DEBUG
            container.register(CategoriesInteractor.self)  { _ in StubCategoriesInteractor() }
            container.register(SDKInteractor.self)  { _ in StubSDKInteractor() }
        #else
            container.register(CategoriesInteractor.self)  { _ in RealCategoriesInteractor() }
            container.register(SDKInteractor.self)  { _ in RealSDKInteractor() }
        #endif
        
        return container
    }
}

@propertyWrapper 
struct Injected<Dependency> {
    var wrappedValue: Dependency

    init() {
        wrappedValue = Injection.shared.container.resolve(Dependency.self)!
    }
}
