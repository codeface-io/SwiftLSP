import FoundationToolz
import Foundation
import SwiftyToolz

extension LSP.ServerCommunicationHandler
{
    public func request<Value: Decodable>(_ req: LSP.Message.Request) async throws -> Value
    {
        try await request(req).decode()
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
        
        public func request(_ requestMessage: Message.Request) async throws -> JSON
        {
            async let json: JSON = withCheckedThrowingContinuation
            {
                request in
                
                Task
                {
                    [weak self] in await self?.save(request, for: requestMessage.id)
                }
            }
            
            do
            {
                try await connection.sendToServer(.request(requestMessage))
            }
            catch
            {
                removeRequest(for: requestMessage.id)
                throw error
            }
            
            return try await json
        }
        
        private func serverDidSend(_ response: Message.Response) async
        {
            switch response.id
            {
            case .value(let id):
                guard let request = removeRequest(for: id) else
                {
                    log(error: "No matching request found")
                    break
                }
                
                switch response.result
                {
                case .success(let jsonResult):
                    request.resume(returning: jsonResult)
                case .failure(let errorResult):
                    // TODO: ensure clients actually try to cast thrown errors to LSP.Message.Response.ErrorResult
                    request.resume(throwing: errorResult)
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
            for request in resquestsByMessageID.values
            {
                request.resume(throwing: error)
            }
            
            resquestsByMessageID.removeAll()
        }
        
        private func save(_ request: Request, for id: Message.ID)
        {
            resquestsByMessageID[id] = request
        }
        
        @discardableResult
        private func removeRequest(for id: Message.ID) -> Request?
        {
            resquestsByMessageID.removeValue(forKey: id)
        }
        
        private var resquestsByMessageID = [Message.ID: Request]()
        private typealias Request = CheckedContinuation<JSON, Error>
        
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
