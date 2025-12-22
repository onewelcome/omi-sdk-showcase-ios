//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct RootView: View {
    @State private var showAlert = false
    @State private var isProcessing = false
    @ObservedObject private var appstate: ShowcaseApp = {
        @Injected var appState: ShowcaseApp
        return appState
    }()
    @ObservedObject  var system: ShowcaseApp.System = {
        @Injected var appState: ShowcaseApp
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
//                LoadingWebView(url: URL(string: "https://mobile.in.test.onewelcome.net/mobile/"))
            }
            .onAppear {
                if UserDefaults.standard.bool(forKey: "autoinitialize") {
                    appstate.system.isProcessing = true
                    appstate.routing.navigate(to: .initialization)
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
