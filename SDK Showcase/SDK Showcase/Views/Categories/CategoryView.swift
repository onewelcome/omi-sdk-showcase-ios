//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation
import SwiftUI

extension CategoryView {
    init(category: Category) {
        _system = StateObject(wrappedValue: AppState.System())    
    }
}

struct CategoryView: View {
    @StateObject var system: AppState.System
    
    var body: some View {
        Text("cat")
            .onAppear() {
                system.isEnrolled = true
            }
    }
}

