
import SwiftUI

struct PinPad: View {
    @Injected private var interactor: PinPadInteractor
    @Injected private var appState: AppState
    
    @State private var pin: String = "" {
        didSet {
            if pin.count == interactor.pinLength {
                interactor.validate(pin: pin)
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("Create PIN")
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
                Button("0") {
                    pin.append("0")
                }.buttonStyle(PinPadStyle())
                Button("<") {
                    if !pin.isEmpty { pin.removeLast() }
                }.buttonStyle(PinPadStyle())
                Button("X") {
                    pin.removeAll()
                }.buttonStyle(PinPadStyle())
            }
            Spacer()
            
            if let error = appState.system.lastErrorDescription {
                Text(error)
                    .foregroundColor(.red)
                    .monospaced()
                    .frame(width: 300, height: 80, alignment: .center)
            } else {
                let maskedPin = pin.replacingOccurrences(of: "\\d", with: "*", options: .regularExpression)
                Text(maskedPin)
                    .font(.largeTitle)
                    .monospaced()
                    .frame(width: 300, height: 80, alignment: .center)
            }
        }
    }
}

/// Button Style
struct PinPadStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(EdgeInsets(top: 20, leading: 30, bottom: 30, trailing: 30))
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.gray))
            .compositingGroup()
            .shadow(radius:configuration.isPressed ? 0 : 5,
                    x: 0,
                    y: configuration.isPressed ? 0 : 3)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.smooth(), value: configuration.isPressed)
            .monospaced()
    }
}
