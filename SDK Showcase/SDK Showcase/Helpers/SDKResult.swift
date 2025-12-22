//  Copyright © 2025 Onewelcome Mobile Identity. All rights reserved.

import Foundation

typealias SDKResult = (Result<Void, Error>) -> ()

extension Result where Success == Void {
    public static var success: Result { .success(()) }
}
