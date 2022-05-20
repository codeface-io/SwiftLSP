import Foundation
import SwiftyToolz

public extension LSP.Message.Request
{
    /**
     https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspace_symbol
     */
    static func workspaceSymbols(forQuery query: String = "") -> Self
    {
        .init(method: "workspace/symbol",
              params: .dictionary(["query": .string(query)]))
    }
    
    /**
     https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_documentSymbol
     */
    static func symbols(in document: LSPDocumentUri) throws -> Self
    {
        let docIdentifier = LSPTextDocumentIdentifier(uri: document)
        
        let params = JSON.dictionary(
        [
            "textDocument": try JSON(docIdentifier.encode())
        ])
        
        return .init(method: "textDocument/documentSymbol", params: params)
    }
}
