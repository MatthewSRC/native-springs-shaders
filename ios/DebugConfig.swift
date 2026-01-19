import Foundation

enum DebugConfig {

    static let enableDebugLogs = false

    static func log(_ message: String) {
        #if DEBUG
        if enableDebugLogs {
            print(message)
        }
        #endif
    }
}
