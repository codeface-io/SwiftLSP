import FoundationToolz
import Foundation
import SwiftyToolz

public extension LSP
{
    class WebSocketConnection: LSPServerConnection
    {
        // MARK: - Initialize
        
        public init(webSocket: WebSocket)
        {
            self.webSocket = webSocket
            
            webSocket.didReceiveData =
            {
                [weak self] data in self?.process(data: data)
            }
            
            webSocket.didReceiveText =
            {
                [weak self] text in self?.serverDidSendErrorOutput(text)
            }
            
            webSocket.didReceiveError =
            {
                [weak self] _, error in self?.connectionDidSendError(error)
            }
        }
        
        // MARK: - Receive
        
        private func process(data: Data)
        {
            do
            {
                let message = try LSP.Message(LSP.Packet(parsing: data).content())

                switch message
                {
                case .request: throw "Received request from LSP server"
                case .response(let response): serverDidSendResponse(response)
                case .notification(let notification): serverDidSendNotification(notification)
                }
            }
            catch
            {
                log(error)
                log("Received data:\n" + (data.utf8String ?? "<decoding error>"))
            }
        }
        
        public var serverDidSendResponse: (LSP.Message.Response) -> Void = { _ in }
        public var serverDidSendNotification: (LSP.Message.Notification) -> Void = { _ in }
        public var serverDidSendErrorOutput: (String) -> Void = { _ in }
        public var connectionDidSendError: (Error) -> Void = { _ in }
        
        // MARK: - Send
        
        public func sendToServer(_ message: LSP.Message) async throws
        {
            try await webSocket.send(try message.packet().data)
        }
        
        // MARK: - WebSocket
        
        public let webSocket: WebSocket
    }
}
