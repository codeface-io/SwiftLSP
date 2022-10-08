import FoundationToolz
import Foundation
import SwiftyToolz

public extension LSP
{
    /// An ``LSPServerConnection`` that uses a `WebSocket` to talk to an LSP server
    ///
    /// The client should set the four handlers defined by the protocol ``LSPServerConnection``
    class WebSocketConnection: LSPServerConnection
    {
        // MARK: - Initialize
        
        /// Initialize with a WebSocket
        /// - Parameter webSocket: A WebSocket connected to an LSP server
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
            
            webSocket.didCloseWithError =
            {
                [weak self] _, error in self?.didCloseWithError(error)
            }
        }
        
        // MARK: - Talk to LSP Server
        
        private func process(data: Data)
        {
            do
            {
                let message = try LSP.Message(LSP.Packet(parsingPrefixOf: data).content)

                switch message
                {
                case .request:
                    throw "Received request from LSP server"
                case .response(let response):
                    serverDidSendResponse(response)
                case .notification(let notification):
                    serverDidSendNotification(notification)
                }
            }
            catch
            {
                log(error.readable)
                log("Received data:\n" + (data.utf8String ?? "<decoding error>"))
            }
        }
        
        public var serverDidSendResponse: (LSP.Message.Response) -> Void = { _ in }
        public var serverDidSendNotification: (LSP.Message.Notification) -> Void = { _ in }
        public var serverDidSendErrorOutput: (String) -> Void = { _ in }
        
        /// Send a ``LSP/Message`` via the data channel of the `WebSocket`
        /// - Parameter message: The `LSP.Message` to send
        public func sendToServer(_ message: LSP.Message) async throws
        {
            try await webSocket.send(try LSP.Packet(message).data)
        }
        
        // MARK: - Manage Connection
        
        public var didCloseWithError: (Error) -> Void =
        {
            _ in log(warning: "LSP WebSocket connection error handler not set")
        }
        
        // MARK: - WebSocket
        
        private let webSocket: WebSocket
    }
}
