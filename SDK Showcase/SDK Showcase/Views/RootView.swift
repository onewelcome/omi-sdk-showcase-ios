//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            List {
                VStack {
                    Image("thales-logo")
                        .resizable()
                        .scaledToFit()
                        .padding(-20)
                    Text("Welcome to the ShowCase app")
                        .bold()
                        .padding(.bottom, 15)
                    Text("An example of the usage of the SDK, a part of the Mobile Security")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                }
                
                Section(header: Text("Public API")) {
                    CategoriesList()
                }
                
                Section(header: Text("Other")) {
                    NavigationLink {
                        
                    } label: {
                        Image(systemName: "stethoscope.circle.fill")
                            .foregroundStyle(.green)
                        Text("SDK current status")
                    }
                    NavigationLink {
                        
                    } label: {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .foregroundStyle(.yellow)
                        Text("Search Public API")
                    }
                    
                }
                .hidden()
            }
            .listStyle(.insetGrouped)
        }
    }
}
