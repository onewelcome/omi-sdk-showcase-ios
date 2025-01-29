//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI

extension CategoryView {
    init(category: Category) {
        _system = StateObject(wrappedValue: AppState.System())    
    }
}

struct CategoryView: View {
   // @State private var category: Category
    @StateObject var system: AppState.System
    
    var body: some View {
     //   Text(category.description)
      //  Text(category.name)
        Text("cat")
            .onAppear() {
                system.isEnrolled = true
                system
            }
    }
}

