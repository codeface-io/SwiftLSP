import FoundationToolz
import Foundation
import SwiftyToolz

extension LSP.ServerCommunicationHandler
{
    public func request<Value: Decodable>(_ request: LSP.Request) async throws -> Value
    {
        try await self.request(request).decode()
    }
}

extension LSP
{
    public typealias Server = ServerCommunicationHandler
    
    public actor ServerCommunicationHandler
    {
        // MARK: - Initialize
        
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
        
        public let languageIdentifier: LanguageIdentifier
        
        // MARK: - Observe the Connection
        
        private func connectionDidClose(with error: Error)
        {
            cancelAllPendingRequests(with: error)
            notifyClientThatConnectionDidShutDown(error)
        }
        
        // MARK: - Make Async Requests to LSP Server
        
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
        
        public func notify(_ notification: Message.Notification) async throws
        {
            try await connection.sendToServer(.notification(notification))
        }
        
        // MARK: - Receive Feedback from LSP Server and from Connection
        
        public func handleNotificationFromServer(_ handleNotification: @escaping (Message.Notification) -> Void)
        {
            notifyClientAboutNotificationFromServer = handleNotification
        }
        
        private var notifyClientAboutNotificationFromServer: (Message.Notification) -> Void =
        {
            _ in log(warning: "notification handler not set")
        }
        
        public func handleErrorOutputFromServer(_ handleErrorOutput: @escaping (String) -> Void)
        {
            notifyClientAboutErrorOutputFromServer = handleErrorOutput
        }
        
        private var notifyClientAboutErrorOutputFromServer: (String) -> Void =
        {
            _ in log(warning: "stdErr handler not set")
        }
        
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
