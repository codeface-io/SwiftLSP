extension LSP.ServerCommunicationHandler
{
    /// This just adds the knowledge of what result type the server returns
    public func requestReferences(for symbol: LSPDocumentSymbol,
                                  in document: LSPDocumentUri) async throws -> [LSPLocation]
    {
        try await request(.references(for: symbol, in: document))
    }
}
