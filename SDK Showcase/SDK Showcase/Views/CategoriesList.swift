//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI

struct CategoriesRepository {}

struct CategoriesList: View {
    @State private var categories = [Category]()
    @ObservedObject private var system: AppState.System = {
        @Injected var appState: AppState
        return appState.system
    }()
    @ObservedObject private var user: AppState.UserData = {
        @Injected var appState: AppState
        return appState.userData
    }()
    
    var body: some View {
        ForEach(interactor.loadCategories()) { category in
            NavigationLink {
                ContentView(system: system, userData: user, category: category)
            } label: {
                Text(category.name)
            }
        }
    }
}

//MARK: - Private
private extension CategoriesList {
    var interactor: CategoriesInteractor {
        @Injected var interactors: Interactors
        return interactors.categoriesInteractor
    }
}
