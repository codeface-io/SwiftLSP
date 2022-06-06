/**
 https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocumentPositionParams
 */
struct LSPTextDocumentPositionParams: Codable
{
    /**
     * The text document.
     */
    let textDocument: LSPTextDocumentIdentifier

    /**
     * The position inside the text document.
     */
    let position: LSPPosition
}

struct LSPTextDocumentIdentifier: Codable
{
    /**
     * The text document's URI.
     */
    let uri: LSPDocumentUri
}
