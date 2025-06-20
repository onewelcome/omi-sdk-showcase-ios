//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI

struct SheetViewForWebView: View {
    @State private(set) var urlString: String
    var body: some View {
        VStack {
            SheetViewDismiss()
            LoadingWebView(url: URL(string: urlString))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .padding()
    }
}
