//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI

struct CategoriesRepository {}

struct CategoriesList: View {
    private var interactor: CategoriesInteractor {
        @Injected var interactors: Interactors
        return interactors.categoriesInteractor
    }
    @State private var categories = [Category]()
    @ObservedObject private var system: AppState.System = {
        @Injected var appState: AppState
        return appState.system
    }()
    var body: some View {
        ForEach(interactor.loadCategories()) { category in
            NavigationLink {
                CategoryView(system: system, category: category)
            } label: {
                Text(category.name)
            }
        }
    }
}

