//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.
import SwiftUI

extension Binding {
    init<T>(isNotNil source: Binding<T?>, defaultValue: T?) where Value == String {
        self.init(get: { source.wrappedValue == nil ? defaultValue as? Value ?? String() : source.wrappedValue as? Value ?? String() },
                  set: { source.wrappedValue = ($0 as! T) })
    }
    
    init<T>(isNotNil source: Binding<T?>, defaultValue: T?) where Value == Bool {
        self.init(get: { source.wrappedValue == nil ? defaultValue as? Value ?? Bool() : source.wrappedValue as? Value ?? Bool() },
                  set: { source.wrappedValue = ($0 as! T)})
    }
    
    init<T>(isNotNil source: Binding<T?>, defaultValue: T?) where Value == Double {
        self.init(get: { source.wrappedValue == nil ? defaultValue as? Value ?? Double() : source.wrappedValue as? Value ?? Double() },
                  set: { source.wrappedValue = ($0 as! T)})
    }
}
