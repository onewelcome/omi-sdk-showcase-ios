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
        if system.isSDKInitialized {
            Text("initialized")
        } else {
            Text("not")
        }

        NavigationView {
            List(categories) { category in
                NavigationLink(destination: CategoryView(system: system, category: category)) {
                    Text(category.name)
                }
            }
            .onAppear {
                categories = interactor.loadCategories()
            }
            .onReceive(system.$isSDKInitialized) { output in
                print("CL output=\(output)")
            }
        }
    }
}

