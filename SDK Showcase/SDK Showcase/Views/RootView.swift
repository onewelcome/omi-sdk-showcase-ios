//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct RootView: View {
    @ObservedObject private var appstate: AppState = {
        @Injected var appState: AppState
        return appState
    }()
    @ObservedObject  var system: AppState.System = {
        @Injected var appState: AppState
        return appState.system
    }()
    
    @State private var showAlert = false
    @State private var isProcessing = false
    
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
            
            if showAlert {
                Alert(text: appstate.system.lastInfoDescription ?? "")
            }
            
            if isProcessing {
                Spinner()
            }
        }
        .onChange(of: system.hasError) {
            showAlert = appstate.system.hasError
        }
        .onChange(of: system.isProcessing) {
            isProcessing = appstate.system.isProcessing
        }
    }
}
