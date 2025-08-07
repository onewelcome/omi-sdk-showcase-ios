//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

extension AppState {
    class ViewRouting: ObservableObject {
        @Injected var categoriesInteractor: CategoriesInteractor
        @Published var navPath = [Category]()
        private var navCategory: Category?

        func navigate(to category: Categories) {
            guard let navCategory = categoriesInteractor.category(of: category) else {
                // Should never happen :)
                fatalError("Navigation to category \(category) failed!")
            }

            guard !navPath.contains(navCategory) else {
                // We are on the path already!
                return
            }
            
            navPath.append(navCategory)
        }
    }
}
