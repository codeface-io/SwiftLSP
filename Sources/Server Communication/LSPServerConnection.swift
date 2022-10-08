/// Interface defining the raw I/O capabilities of an LSP server
public protocol LSPServerConnection: AnyObject
{
    // MARK: - Communicate with the LSP Server
    
    func sendToServer(_ message: LSP.Message) async throws
    var serverDidSendResponse: (LSP.Message.Response) -> Void { get set }
    var serverDidSendNotification: (LSP.Message.Notification) -> Void { get set }
    var serverDidSendErrorOutput: (String) -> Void { get set }
    
    // MARK: - Manage the LSP Server Connection itself
    
    var didCloseWithError: (Error) -> Void { get set }
}
