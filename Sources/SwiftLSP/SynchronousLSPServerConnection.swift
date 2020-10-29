public protocol SynchronousLSPServerConnection: class
{
    func send(_ message: LSP.Message) throws
    var serverDidSendResponse: (LSP.Message.Response) -> Void { get set }
    var serverDidSendNotification: (LSP.Message.Notification) -> Void { get set }
    var serverDidSendErrorOutput: (String) -> Void { get set }
}
