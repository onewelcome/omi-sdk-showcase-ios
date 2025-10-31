//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

protocol KeyValueStore {
    func value<T: Codable>(forKey key: String, as type: T.Type) -> T?
    func set<T: Codable>(_ value: T?, forKey key: String)
    func removeValue(forKey key: String)
    func contains(_ key: String) -> Bool
}
