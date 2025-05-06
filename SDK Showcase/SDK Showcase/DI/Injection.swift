//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import Swinject

final class Injection {
    static let shared = Injection()
    private var internalContainer: Container?
    var container: Container {
        get { internalContainer ?? buildContainer() }
    }
}

//MARK: - Private extension
private extension Injection {
    func buildContainer() -> Container {
        let container = Container()
        internalContainer = container
        
        container.register(AppState.self) { _ in AppState() }
            .inObjectScope(.container)
        
        container.register(Interactors.self) { resolver in
            Interactors(categoriesInteractor: resolver.resolve(CategoriesInteractor.self)!,
                        sdkInteractor: resolver.resolve(SDKInteractor.self)!,
                        browserInteractor: resolver.resolve(BrowserRegistrationInteractor.self)!)
        }.inObjectScope(.container)
        
        container.register(CategoriesInteractor.self)  { _ in CategoriesInteractorReal() }
            .inObjectScope(.container)
        
        container.register(SDKInteractor.self)  { resolver in
            SDKInteractorReal(appState: resolver.resolve(AppState.self)!)
        }.inObjectScope(.container)
        
        container.register(BrowserRegistrationInteractor.self)  { resolver in
            BrowserRegistrationInteractorReal(appState: resolver.resolve(AppState.self)!)
        }.inObjectScope(.container)
        
        return container
    }
}

//MARK: - Property wrapper
@propertyWrapper
struct Injected<Dependency> {
    var wrappedValue: Dependency
    
    init() {
        wrappedValue = Injection.shared.container.resolve(Dependency.self)!
    }
}
