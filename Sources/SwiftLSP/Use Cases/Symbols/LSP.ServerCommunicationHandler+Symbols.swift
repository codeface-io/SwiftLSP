extension LSP.ServerCommunicationHandler
{
    /// This just adds the knowledge of what result type the server returns
    public func requestSymbols(in document: LSPDocumentUri) async throws -> [LSPDocumentSymbol]
    {
        try await request(.symbols(in: document))
    }
}
