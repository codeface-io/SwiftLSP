import Foundation
import SwiftyToolz

public extension LSP.Message.Request
{
    /**
     https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_references
     */
    static func references(for symbol: LSPDocumentSymbol,
                           inFileAtPath filePath: String) throws -> Self
    {
        let uri: LSPDocumentUri = URL(fileURLWithPath: filePath).absoluteString
        
        let params = JSON.dictionary([
            /**
             * The text document.
             */
            "textDocument": try JSON(LSPTextDocumentIdentifier(uri: uri).encode()),
            
            /**
             * The position inside the text document.
             */
            "position": try JSON(symbol.range.start.encode()),
            
            "context": JSON.dictionary([
                /**
                 * Include the declaration of the current symbol.
                 */
                "includeDeclaration": .bool(false)
            ])
        ])
        
        return .init(method: "textDocument/references", params: params)
    }
}
