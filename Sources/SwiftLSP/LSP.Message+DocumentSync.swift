public extension LSP.Message.Notification
{
    // textDocument LSP type: TextDocumentItem
    static func didOpen(doc: JSON) -> Self
    {
        .init(method: "textDocument/didOpen",
              params: .dictionary(["textDocument": doc]))
    }
}
