//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

//MARK: - Protocol
protocol CategoriesInteractor {
    func loadCategories() -> [Category]
    func category(id: UUID) -> Category?
}

//MARK: - Real methods
struct CategoriesInteractorReal: CategoriesInteractor {
    func category(id: UUID) -> Category? {
        loadCategories().first { $0.id == id }
    }
    
    @Injected var appState: AppState

    func loadCategories() -> [Category] {
        //TODO: Load from a universal JSON for both platforms.
        return []
    }
}

//MARK: - Stubbed methods
struct CategoriesInteractorStub: CategoriesInteractor {
    func category(id: UUID) -> Category? {
        loadCategories().first
    }
    
    func loadCategories() -> [Category] {[
        Category(name: "SDK Initialization", 
                 description: "Description of SDK Initialization...",
                 options: [],
                 requiredActions: [],
                 optionalActions: [Action(name: "Initialize", description: "Initializes the SDK")]),
        Category(name: "User registration", 
                 description: "Description of User registration...",
                 options: [],
                 requiredActions: [],
                 optionalActions: []),
        Category(name: "User deregistration", 
                 description: "Description of User deregistration...",
                 options: [],
                 requiredActions: [],
                 optionalActions: []),
        /*
         
         ... other categories
         
         */
    ]}
}
