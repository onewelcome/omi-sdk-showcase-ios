//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI

struct SheetViewForWebView: View {
    @State var urlString: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            LoadingWebView(url: URL(string: urlString))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
        .padding()
    }
}
