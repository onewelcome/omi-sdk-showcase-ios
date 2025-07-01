//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import SwiftUI

struct PinPad: View {
    @Injected private var interactor: PinPadInteractor
    @Injected private var appState: AppState
    @State private var errorText = ""
    @State private var pin = "" {
        didSet {
            if pin.count == interactor.pinLength {
                interactor.validate(pin: pin)
                
                if appState.system.isPinProvided {
                    reset()
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            Text(!appState.system.isPinProvided ? "Create PIN" : "Confirm PIN")
            Spacer()
            
            if appState.system.lastErrorDescription != nil {
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
        errorText = appState.system.lastErrorDescription ?? ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            errorText = ""
            appState.system.lastErrorDescription = nil
        }
    }
    
    var pinText: String {
        let maskedPin = pin.replacingOccurrences(of: "\\d", with: "*", options: .regularExpression)
        let text = maskedPin + String(repeating: "_", count: Int(interactor.pinLength) - pin.count)
        
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
