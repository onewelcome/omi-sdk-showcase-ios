//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct RootView: View {
    @State private var showAlert = false
    @State private var isProcessing = false
    @ObservedObject private var appstate: AppState = {
        @Injected var appState: AppState
        return appState
    }()
    @ObservedObject  var system: AppState.System = {
        @Injected var appState: AppState
        return appState.system
    }()
    private var interactor: CategoriesInteractor {
        @Injected var interactors: Interactors
        return interactors.categoriesInteractor
    }

    var body: some View {
        ZStack {
            NavigationStack(path: $appstate.routing.navPath) {
                HeaderView()
                List(interactor.loadCategories()) { category in
                    NavigationLink(value: category) {
                        Text(category.name)
                    }
                }
                .navigationDestination(for: Category.self) { category in
                    ContentView(category: category)
                }
            }
            
            if system.hasError {
                Alert(text: appstate.system.lastInfoDescription ?? "")
            }
            
            if system.isProcessing {
                Spinner()
            }
        }
    }
}
