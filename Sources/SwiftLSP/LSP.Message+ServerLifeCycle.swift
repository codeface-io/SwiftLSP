import Foundation

public extension LSP.Message.Request
{
    // capabilities LSP type: ClientCapabilities
    static func initialize(folder: URL,
                           clientProcessID: Int,
                           capabilities: JSON = defaultClientCapabilities) -> Self
    {
        .init(method: "initialize",
              params: .dictionary(["rootUri": .string(folder.absoluteString),
                                   "processId": .int(clientProcessID),
                                   "capabilities": capabilities]))
    }
    
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

public extension LSP.Message.Notification
{
    static var initialized: Self
    {
        .init(method: "initialized", params: .dictionary([:]))
    }
}
