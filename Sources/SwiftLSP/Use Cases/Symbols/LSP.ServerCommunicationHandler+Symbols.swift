import Foundation

extension LSP.ServerCommunicationHandler
{
    public func requestDocumentSymbols(inFile file: URL) async throws -> [LSPDocumentSymbol]
    {
        try await request(.docSymbols(inFile: file))
    }
}
