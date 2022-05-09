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
                webSocket, error in webSocket.close(); log(error)
            }
        }
        
        // MARK: - Receive
        
        private func process(data: Data)
        {
            do
            {
                let message = try LSP.Message(data)

                switch message
                {
                case .request(_): throw "Received request from LSP server"
                case .response(let response): serverDidSendResponse(response)
                case .notification(let notification): serverDidSendNotification(notification)
                }
            }
            catch
            {
                log(error)
                log("Received data:\n" + (data.utf8String ?? "nil"))
            }
        }
        
        public var serverDidSendResponse: (LSP.Message.Response) -> Void = { _ in }
        public var serverDidSendNotification: (LSP.Message.Notification) -> Void = { _ in }
        public var serverDidSendErrorOutput: (String) -> Void = { _ in }
        
        // MARK: - Send
        
        public func sendToServer(_ message: LSP.Message) throws
        {
            webSocket.send(try message.packet().data)
            {
                $0.forSome { log($0) }
            }
        }
        
        // MARK: - WebSocket
        
        private let webSocket: WebSocket
    }
}
