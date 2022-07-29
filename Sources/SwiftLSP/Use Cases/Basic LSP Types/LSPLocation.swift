/**
 https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#location
 */
public struct LSPLocation: Codable
{
    public let uri: LSPDocumentUri
    public let range: LSPRange
}

public typealias LSPDocumentUri = String

public extension LSPRange
{
    func contains(_ otherRange: LSPRange) -> Bool
    {
        if otherRange.start.line < start.line { return false }
        if otherRange.start.line == start.line,
           otherRange.start.character < start.character { return false }
        
        if otherRange.start.line > end.line { return false }
        if otherRange.start.line == end.line,
           otherRange.start.character > end.character { return false }
        
        if otherRange.end.line < start.line { return false }
        if otherRange.end.line == start.line,
           otherRange.end.character < start.character { return false }
        
        if otherRange.end.line > end.line { return false }
        if otherRange.end.line == end.line,
           otherRange.end.character > end.character { return false }
        
        return true
    }
}

public struct LSPRange: Codable
{
    /**
     * The range's start position.
     */
    public let start: LSPPosition

    /**
     * The range's end position.
     */
    public let end: LSPPosition
}

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
