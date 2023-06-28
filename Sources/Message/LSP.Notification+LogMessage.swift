import SwiftyToolz

public extension LSP.Notification {
    
    var logMessageParameters: LSP.LogMessageParams? {
        method == "window/logMessage" ? try? params?.json().decode() : nil
    }
}

public extension LSP.LogMessageParams {
    
    var logLevel: Log.Level {
        switch type {
        case 1: return .error
        case 2: return .warning
        case 3: return .info
        case 4: return .verbose
        default:
            log(error: "Unknown \(Self.self) message type code: \(type). See https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#messageType")
            return .info
        }
    }
}

public extension LSP {
    
    /// https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#logMessageParams
    struct LogMessageParams: Codable {
        /**
         The message type
         
         <https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#messageType>
         */
        public let type: Int // MessageType;
        
        /**
         * The actual message
         */
        public let message: String
    }
}
