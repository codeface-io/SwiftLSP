import Foundation

public extension LSP.Message.Request
{
    static func workspaceSymbols(forQuery query: String = "") -> Self
    {
        .init(method: "workspace/symbol",
              params: .dictionary(["query": .string(query)]))
    }
    
    static func docSymbols(inFile file: URL) throws -> Self
    {
        let params = JSON.dictionary(
        [
            "textDocument": .dictionary(
            [
                "uri": .string(file.absoluteString)
            ])
        ])
        
        return .init(method: "textDocument/documentSymbol", params: params)
    }
}

public struct LSPDocumentSymbol: Codable
{
    public let name: String
    public let kind: Int
    public let children: [Self]
}
