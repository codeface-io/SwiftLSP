import SwiftyToolz

public extension LSP.Message.Notification
{
    /**
     https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_didOpen
     */
    static func didOpen(doc: JSON) -> Self
    {
        .init(method: "textDocument/didOpen",
              params: .dictionary(["textDocument": doc]))
    }
}
