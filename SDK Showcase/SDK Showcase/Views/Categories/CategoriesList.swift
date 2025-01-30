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
    @Injected private var appState: AppState

    var body: some View {
        NavigationView {
            List(categories) { category in
                NavigationLink(destination: CategoryView(category: category)) {
                    Text(category.name)
                }
            }
            .environmentObject(appState.system)
            .onAppear {
                categories = interactor.loadCategories()
            }
        }
    }
}

