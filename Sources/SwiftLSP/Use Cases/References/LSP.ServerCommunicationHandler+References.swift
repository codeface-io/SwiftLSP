extension LSP.ServerCommunicationHandler
{
    /// This just adds the knowledge of what result type the server returns
    public func requestReferences(forSymbolSelectionRange selectionRange: LSPRange,
                                  in document: LSPDocumentUri) async throws -> [LSPLocation]
    {
        try await request(.references(forSymbolSelectionRange: selectionRange, in: document))
    }
}
