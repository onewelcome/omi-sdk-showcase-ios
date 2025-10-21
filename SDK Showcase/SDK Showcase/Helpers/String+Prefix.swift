//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

extension String {
    func truncated(_ length: Int = 200, with truncation: String = "…") -> String {
        guard length >= 0 else {
            return ""
        }
        return String(prefix(min(count, length))) + (count > length ? truncation : "")
    }
}
