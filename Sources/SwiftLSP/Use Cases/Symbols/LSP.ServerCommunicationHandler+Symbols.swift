import Foundation

extension LSP.ServerCommunicationHandler
{
    public func requestDocumentSymbols(inFile file: LSPDocumentUri) async throws -> [LSPDocumentSymbol]
    {
        try await request(.docSymbols(inFile: file))
    }
}
