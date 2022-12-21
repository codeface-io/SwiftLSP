import FoundationToolz
import Foundation
import SwiftyToolz

extension LSP.ServerCommunicationHandler
{
    /**
     Requests a value of a generic type from the connected LSP server
     
     When the LSP server produces an LSP response error (see [its specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#responseError)), the thrown error is a ``LSP/Message/Response/ErrorResult`` a.k.a. `LSP.ErrorResult`. So the caller should check whether thrown errors are indeed `LSP.ErrorResult`s.
     
     - Parameter request: The LSP request message to send to the LSP server
     
     - Returns: The value returned from the LSP server when no error occured. The value's type must be generically determined by the caller.
     
     - Throws: If the LSP server sends a [response error message](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#responseError) in return, the error is a ``LSP/Message/Response/ErrorResult``, otherwise it's any `Error`.
     */
    public func request<Value: Decodable>(_ request: LSP.Request) async throws -> Value
    {
        try await self.request(request).decode()
    }
}

extension LSP
{
    // TODO: should this be named client??? ... the client sends request via its server connection to the server ...
    public typealias Server = ServerCommunicationHandler
    
    /// An actor for easy communication with an LSP server via an ``LSPServerConnection``
    public actor ServerCommunicationHandler
    {
        // MARK: - Initialize
        
        /**
         Create a ``LSP/ServerCommunicationHandler``
         
         - Parameters:
             - connection: An ``LSPServerConnection`` for talking to an LSP server
             - languageName: The name of the language whose identifier shall be set in requests
         */
        public init(connection: LSPServerConnection, languageName: String)
        {
            self.connection = connection
            self.languageIdentifier = .init(languageName: languageName)
            
            connection.serverDidSendResponse =
            {
                response in
                
                Task
                {
                    [weak self] in await self?.serverDidSend(response)
                }
            }
            
            connection.serverDidSendNotification =
            {
                notification in
                
                Task
                {
                    [weak self] in await self?.notifyClientAboutNotificationFromServer(notification)
                }
            }
            
            connection.serverDidSendErrorOutput =
            {
                errorOutput in
                
                Task
                {
                    [weak self] in await self?.notifyClientAboutErrorOutputFromServer(errorOutput)
                }
            }
            
            connection.didCloseWithError =
            {
                error in
                
                Task
                {
                    [weak self] in await self?.connectionDidClose(with: error)
                }
            }
        }
        
        /// The identifier of the language whose name was provided via the initializer
        public let languageIdentifier: LanguageIdentifier
        
        // MARK: - Observe the Connection
        
        private func connectionDidClose(with error: Error)
        {
            cancelAllPendingRequests(with: error)
            notifyClientThatConnectionDidShutDown(error)
        }
        
        // MARK: - Make Async Requests to LSP Server
        
        /**
         Makes a request to the connected LSP server
         
         When the LSP server produces an LSP response error (see [its specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#responseError)), the thrown error is a ``LSP/Message/Response/ErrorResult`` a.k.a. `LSP.ErrorResult`. So the caller should check whether thrown errors are indeed `LSP.ErrorResult`s.
         
         - Parameter request: The LSP request message to send to the LSP server
         
         - Returns: The `JSON` value returned by the LSP server when no error occured. It corresponds to the `result` property in  [the specification of the LSP response message](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#responseMessage)
         
         
         - Throws: If the LSP server sends a [response error message](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#responseError) in return, the error is a ``LSP/Message/Response/ErrorResult``, otherwise it's any `Error`.
         */
        public func request(_ request: Request) async throws -> JSON
        {
            async let json: JSON = withCheckedThrowingContinuation
            {
                continuation in
                
                Task
                {
                    [weak self] in await self?.save(continuation, for: request.id)
                }
            }
            
            do
            {
                try await connection.sendToServer(.request(request))
            }
            catch
            {
                removeContinuation(for: request.id)
                throw error
            }
            
            return try await json
        }
        
        private func serverDidSend(_ response: Response) async
        {
            switch response.id
            {
            case .value(let id):
                guard let continuation = removeContinuation(for: id) else
                {
                    log(error: "No matching continuation found")
                    break
                }
                
                switch response.result
                {
                case .success(let jsonResult):
                    continuation.resume(returning: jsonResult)
                case .failure(let errorResult):
                    // TODO: ensure clients actually try to cast thrown errors to LSP.ErrorResult
                    continuation.resume(throwing: errorResult)
                }
            case .null:
                switch response.result
                {
                case .success(let jsonResult):
                    log(error: "Server did respond with value but no request ID: \(jsonResult)")
                case .failure(let errorResult):
                    log(error: "Server did respond with error but no request ID: \(errorResult)")
                }
            }
        }
        
        private func cancelAllPendingRequests(with error: Error)
        {
            for continuation in continuationsByMessageID.values
            {
                continuation.resume(throwing: error)
            }
            
            continuationsByMessageID.removeAll()
        }
        
        private func save(_ continuation: Continuation, for id: Message.ID)
        {
            continuationsByMessageID[id] = continuation
        }
        
        @discardableResult
        private func removeContinuation(for id: Message.ID) -> Continuation?
        {
            continuationsByMessageID.removeValue(forKey: id)
        }
        
        private var continuationsByMessageID = [Message.ID: Continuation]()
        private typealias Continuation = CheckedContinuation<JSON, Error>
        
        // MARK: - Send Notification to LSP Server
        
        /**
         Sends a ``LSP/Message/Notification`` to the connected LSP server
         
         - Parameter notification: The ``LSP/Message/Notification`` to send to the LSP server
         */
        public func notify(_ notification: Message.Notification) async throws
        {
            try await connection.sendToServer(.notification(notification))
        }
        
        // MARK: - Receive Feedback from LSP Server and from Connection
        
        /// Sets the handler for LSP notifications sent by the LSP server
        public func handleNotificationFromServer(_ handleNotification: @escaping (Message.Notification) -> Void)
        {
            notifyClientAboutNotificationFromServer = handleNotification
        }
        
        private var notifyClientAboutNotificationFromServer: (Message.Notification) -> Void =
        {
            _ in log(warning: "notification handler not set")
        }
        
        /// Sets the handler for strings sent by the LSP server via `stdErr`
        public func handleErrorOutputFromServer(_ handleErrorOutput: @escaping (String) -> Void)
        {
            notifyClientAboutErrorOutputFromServer = handleErrorOutput
        }
        
        private var notifyClientAboutErrorOutputFromServer: (String) -> Void =
        {
            _ in log(warning: "stdErr handler not set")
        }
        
        /// Sets the handler for errors sent by the LSP server connection itself when it shuts down
        ///
        /// This indicates that the connection had to shut down. We never assume a connection still works when it has produced an error.
        public func handleConnectionShutdown(_ handleError: @escaping (Error) -> Void)
        {
            notifyClientThatConnectionDidShutDown = handleError
        }
        
        private var notifyClientThatConnectionDidShutDown: (Error) -> Void =
        {
            _ in log(warning: "connection close handler not set")
        }
        
        // MARK: - Server Connection
        
        private let connection: LSPServerConnection
    }
}
