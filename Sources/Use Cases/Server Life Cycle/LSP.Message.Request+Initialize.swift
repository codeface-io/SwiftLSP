import FoundationToolz
import Foundation
import SwiftyToolz

public extension LSP.Message.Request
{
    /**
     https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#initialize
     
     - Parameter clientProcessID: [We assume](https://github.com/ChimeHQ/ProcessService/pull/3) this is the process ID of the actual LSP **client**, which is not necessarily the same process as the server's parent process that technically launched the LSP server. This is important because the LSP client might interact with the LSP server via intermediate processes like [LSPService](https://github.com/codeface-io/LSPService) or XPC services. You may omit this parameter and SwiftLSP will use the current process's ID. This will virtually always be correct since the LSP client typically creates the initialize request.
     */
    static func initialize(folder: URL,
                           clientProcessID: Int = Int(ProcessInfo.processInfo.processIdentifier),
                           capabilities: JSON = defaultClientCapabilities) -> Self
    {
        .init(method: "initialize",
              params: .object(["rootUri": .string(folder.absoluteString),
                               "processId": .int(clientProcessID),
                               "capabilities": capabilities]))
    }
    
    /**
     https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#clientCapabilities
     */
    static var defaultClientCapabilities: JSON
    {
        .object(
        [
            "textDocument": .object( // TextDocumentClientCapabilities;
            [
                /**
                 * Capabilities specific to the `textDocument/documentSymbol` request.
                 */
                "documentSymbol": .object( //DocumentSymbolClientCapabilities;
                [
                    // https://github.com/microsoft/language-server-protocol/issues/884
                    "hierarchicalDocumentSymbolSupport": .bool(true)
                ])
            ])
        ])
    }
}

public func log(initializeResult: JSON) throws
{
    // https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#serverCapabilities
    guard let serverCapabilities = initializeResult.capabilities else
    {
        throw "LSP initialize result has no \"capabilities\" field"
    }
    
    log("LSP Server Capabilities:\n\(serverCapabilities.description)")
}
