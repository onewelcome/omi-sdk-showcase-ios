//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Testing
@testable import SDK_Showcase

struct CategoriesInteractorMock: CategoriesInteractor {
    func loadCategories() -> [SDK_Showcase.Category] {
        [Category(name: "Test", description: "Test description", options: [], selection: [], requiredActions: [], optionalActions: []),
         Category(name: "Test2", description: "Test2 description", options: [], selection: [], requiredActions: [], optionalActions: [])]
    }
}

struct CategoriesInteractorEmptyMock: CategoriesInteractor {
    func loadCategories() -> [SDK_Showcase.Category] {
        []
    }
}
