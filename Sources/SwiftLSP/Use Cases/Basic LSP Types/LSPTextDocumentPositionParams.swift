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

public typealias LSPDocumentUri = String

public struct LSPPosition: Codable
{
    /**
     * Line position in a document (zero-based).
     */
    public let line: Int // uinteger;

    /**
     * Character offset on a line in a document (zero-based). The meaning of this
     * offset is determined by the negotiated `PositionEncodingKind`.
     *
     * If the character value is greater than the line length it defaults back
     * to the line length.
     */
    public let character: Int // uinteger;
}
