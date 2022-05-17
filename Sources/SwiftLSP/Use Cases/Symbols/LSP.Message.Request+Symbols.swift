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
    static func docSymbols(inFile fileUri: LSPDocumentUri) throws -> Self
    {
        let docIdentifier = LSPTextDocumentIdentifier(uri: fileUri)
        
        let docIdentifierJSON = try JSON(docIdentifier.encode())
        
        let params = JSON.dictionary(
        [
            "textDocument": docIdentifierJSON
        ])
        
        return .init(method: "textDocument/documentSymbol", params: params)
    }
}
