public extension LSPDocumentSymbol
{
    var kindName: String
    {
        symbolKind?.name ?? "Unknown kind of symbol"
    }
}

public extension LSPDocumentSymbol.SymbolKind
{
    var name: String
    {
        switch self
        {
        case .File: return "File"
        case .Module: return "Module"
        case .Namespace: return "Namespace"
        case .Package: return "Package"
        case .Class: return "Class"
        case .Method: return "Method"
        case .Property: return "Property"
        case .Field: return "Field"
        case .Constructor: return "Constructor"
        case .Enum: return "Enum"
        case .Interface: return "Interface"
        case .Function: return "Function"
        case .Variable: return "Variable"
        case .Constant: return "Constant"
        case .String: return "String"
        case .Number: return "Number"
        case .Boolean: return "Boolean"
        case .Array: return "Array"
        case .Object: return "Object"
        case .Key: return "Key"
        case .Null: return "Null"
        case .EnumMember: return "EnumMember"
        case .Struct: return "Struct"
        case .Event: return "Event"
        case .Operator: return "Operator"
        case .TypeParameter: return "TypeParameter"
        }
    }
}

/**
 https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#documentSymbol
 */
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
        public let start: LSPPosition

        /**
         * The range's end position.
         */
        public let end: LSPPosition
    }
    
    public let children: [Self]
}
