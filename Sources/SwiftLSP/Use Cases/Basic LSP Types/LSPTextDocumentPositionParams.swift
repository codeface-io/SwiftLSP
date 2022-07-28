/**
 https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocumentPositionParams
 */
public struct LSPTextDocumentPositionParams: Codable
{
    /**
     * The text document.
     */
    public let textDocument: LSPTextDocumentIdentifier

    /**
     * The position inside the text document.
     */
    public let position: LSPPosition
}

public struct LSPTextDocumentIdentifier: Codable
{
    /**
     * The text document's URI.
     */
    public let uri: LSPDocumentUri
}
