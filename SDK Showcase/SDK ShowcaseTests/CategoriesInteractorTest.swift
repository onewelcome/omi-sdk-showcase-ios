//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Testing
@testable import SDK_Showcase

struct CategoriesInteractorTest {
    @Test func loadCategories() {
        let interactor: CategoriesInteractor = CategoriesInteractorMock()
        #expect(interactor.loadCategories().count == 2)
    }
    
    @Test func loadEmptyCategories() {
        let interactor: CategoriesInteractor = CategoriesInteractorEmptyMock()
        #expect(interactor.loadCategories().count == 0)
        #expect(interactor.loadCategories() != nil)
    }
}
