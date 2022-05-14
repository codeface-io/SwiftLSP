import Foundation
import SwiftyToolz

public extension LSP.Message.Request
{
    /**
     https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#initialize
     */
    static func initialize(folder: URL,
                           clientProcessID: Int,
                           capabilities: JSON = defaultClientCapabilities) -> Self
    {
        .init(method: "initialize",
              params: .dictionary(["rootUri": .string(folder.absoluteString),
                                   "processId": .int(clientProcessID),
                                   "capabilities": capabilities]))
    }
    
    /**
     https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#clientCapabilities
     */
    static var defaultClientCapabilities: JSON
    {
        .dictionary(
        [
            "textDocument": .dictionary( // TextDocumentClientCapabilities;
            [
                "documentSymbol": .dictionary( //DocumentSymbolClientCapabilities;
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

public extension LSP.Message.Notification
{
    static var initialized: Self
    {
        .init(method: "initialized", params: .dictionary([:]))
    }
}
