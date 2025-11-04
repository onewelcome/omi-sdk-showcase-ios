//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

extension ShowcaseApp {
    class PersistenceStore: Persistence {
        var store: KeyValueStore
        var autoinitializeSDK: Bool {
            get {
                store.value(forKey: "autoinitialize", as: Bool.self) ?? false
            }
            set {
                store.set(newValue, forKey: "autoinitialize")
            }
        }
        
        init(store: KeyValueStore) {
            self.store = store
        }
    }
}
