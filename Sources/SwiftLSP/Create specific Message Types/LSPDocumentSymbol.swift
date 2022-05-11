public struct LSPDocumentSymbol: Codable
{
    public let name: String
    
    public var symbolKind: SymbolKind?
    {
        .init(rawValue: kind)
    }
    
    public enum SymbolKind: Int
    {
        case File = 1
        case Module = 2
        case Namespace = 3
        case Package = 4
        case Class = 5
        case Method = 6
        case Property = 7
        case Field = 8
        case Constructor = 9
        case Enum = 10
        case Interface = 11
        case Function = 12
        case Variable = 13
        case Constant = 14
        case String = 15
        case Number = 16
        case Boolean = 17
        case Array = 18
        case Object = 19
        case Key = 20
        case Null = 21
        case EnumMember = 22
        case Struct = 23
        case Event = 24
        case Operator = 25
        case TypeParameter = 26
    }
    
    public let kind: Int
    
    public let range: Range
    
    public struct Range: Codable
    {
        /**
         * The range's start position.
         */
        public let start: Position

        /**
         * The range's end position.
         */
        public let end: Position
        
        public struct Position: Codable
        {
            /**
             * Line position in a document (zero-based).
             */
            public let line: Int

            /**
             * Character offset on a line in a document (zero-based). The meaning of this
             * offset is determined by the negotiated `PositionEncodingKind`.
             *
             * If the character value is greater than the line length it defaults back
             * to the line length.
             */
            public let character: Int
        }
    }
    
    public let children: [Self]
}
