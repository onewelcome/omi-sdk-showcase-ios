//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

class UserDefaultsStore: KeyValueStore {
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func value<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        // Native types first
        if T.self == String.self      { return defaults.string(forKey: key) as? T }
        if T.self == Bool.self        { return (defaults.object(forKey: key) as? Bool) as? T }
        if T.self == Int.self         { return (defaults.object(forKey: key) as? Int) as? T }
        if T.self == Double.self      { return (defaults.object(forKey: key) as? Double) as? T }
        if T.self == Float.self       { return (defaults.object(forKey: key) as? Float) as? T }
        if T.self == Data.self        { return defaults.data(forKey: key) as? T }
        if T.self == Date.self        { return defaults.object(forKey: key) as? T }
        if T.self == [String].self    { return defaults.stringArray(forKey: key) as? T }

        // Codable fallback via Data
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    func set<T: Codable>(_ value: T?, forKey key: String) {
        if value == nil {
            defaults.removeObject(forKey: key)
            return
        }
        switch value {
        case let v as String:  defaults.set(v, forKey: key)
        case let v as Bool:    defaults.set(v, forKey: key)
        case let v as Int:     defaults.set(v, forKey: key)
        case let v as Double:  defaults.set(v, forKey: key)
        case let v as Float:   defaults.set(v, forKey: key)
        case let v as Data:    defaults.set(v, forKey: key)
        case let v as Date:    defaults.set(v, forKey: key)
        case let v as [String]:defaults.set(v, forKey: key)
        default:
            let data = try? encoder.encode(value)
            defaults.set(data, forKey: key)
        }
    }

    func removeValue(forKey key: String) {
        defaults.removeObject(forKey: key)
    }

    func contains(_ key: String) -> Bool {
        defaults.object(forKey: key) != nil
    }
}
