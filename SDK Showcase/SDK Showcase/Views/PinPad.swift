//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct PinPad: View {
    @Injected private var interactor: PinPadInteractor
    @ObservedObject private var system: AppState.System = {
        @Injected var appState: AppState
        return appState.system
    }()
    @State private var errorText = ""
    @State private var pin = "" {
        didSet {
            if pin.count == interactor.pinLength {
                interactor.validate(pin: pin)
                reset()
            }
        }
    }
    
    var body: some View {
        VStack {
            switch system.pinPadState {
            case .creating:
                Text("Create PIN")
            case .created:
                Text("Confirm PIN")
            case .changing:
                Text("Provide the current PIN")
            case .hidden:
                Spacer()
            }
            
            Spacer()
            if system.hasError {
                Text(errorText)
                    .foregroundColor(.red)
                    .monospaced()
                    .frame(width: 300, height: 80, alignment: .center)
                    .onAppear() {
                        reset()
                    }
            } else {
                Text(pinText)
                    .font(.largeTitle)
                    .monospaced()
                    .frame(width: 300, height: 80, alignment: .center)
            }
            Spacer()
            
            HStack {
                Button("1") {
                    pin.append("1")
                }.buttonStyle(PinPadStyle())
                Button("2") {
                    pin.append("2")
                }.buttonStyle(PinPadStyle())
                Button("3") {
                    pin.append("3")
                }.buttonStyle(PinPadStyle())
            }
            HStack {
                Button("4") {
                    pin.append("4")
                }.buttonStyle(PinPadStyle())
                Button("5") {
                    pin.append("5")
                }.buttonStyle(PinPadStyle())
                Button("6") {
                    pin.append("6")
                }.buttonStyle(PinPadStyle())
                
            }
            HStack {
                Button("7") {
                    pin.append("7")
                }.buttonStyle(PinPadStyle())
                Button("8") {
                    pin.append("8")
                }.buttonStyle(PinPadStyle())
                Button("9") {
                    pin.append("9")
                }.buttonStyle(PinPadStyle())
                
            }
            HStack {
                Button("<") {
                    if !pin.isEmpty { pin.removeLast() }
                }.buttonStyle(PinPadStyle())
                Button("0") {
                    pin.append("0")
                }.buttonStyle(PinPadStyle())
                Button("X") {
                    pin.removeAll()
                }.buttonStyle(PinPadStyle())
            }
            Spacer()
        }
    }

}

//MARK: - Private
private extension PinPad {
    func reset() {
        pin.removeAll()
        errorText = system.lastInfoDescription ?? ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            errorText = ""
            system.unsetInfo()
        }
    }
    
    var pinText: String {
        let maskedPin = pin.replacingOccurrences(of: "\\d", with: "*", options: .regularExpression)
        let text = maskedPin + String(repeating: "_", count: max(Int(interactor.pinLength) - pin.count, 0))
        
        return text
    }
}

//MARK: - Button Style
struct PinPadStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .font(.title).bold()
            .padding(EdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30))
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.gray))
            .compositingGroup()
            .shadow(radius:configuration.isPressed ? 0 : 5,
                    x: 0,
                    y: configuration.isPressed ? 0 : 5)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut, value: configuration.isPressed)
    }
}
