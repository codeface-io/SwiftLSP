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
    public class ServerCommunicationHandler
    {
        // MARK: - Initialize
        
        public init(connection: LSPServerConnection,
                    language: String)
        {
            self.connection = connection
            self.language = language
            
            connection.serverDidSendResponse =
            {
                [weak self] response in self?.serverDidSend(response)
            }
            
            connection.serverDidSendNotification =
            {
                [weak self] notification in self?.serverDidSendNotification(notification)
            }
            
            connection.serverDidSendErrorOutput =
            {
                [weak self] errorOutput in self?.serverDidSendErrorOutput(errorOutput)
            }
            
            connection.connectionDidSendError =
            {
                [weak self] error in self?.connectionDidSendError(error)
            }
        }
        
        // MARK: - Process Requests and Responses
        
        public func request(_ request: Message.Request) async throws -> JSON
        {
            async let json: JSON = withCheckedThrowingContinuation
            {
                continuation in
                
                saveResultHandler(for: request.id)
                {
                    [weak self] in
                    
                    self?.removeResultHandler(for: request.id)
                    
                    switch $0
                    {
                    case .success(let jsonResult):
                        continuation.resume(returning: jsonResult)
                    case .failure(let errorResult):
                        log(error: errorResult.description)
                        continuation.resume(throwing: errorResult)
                    }
                }
            }
            
            do
            {
                try await connection.sendToServer(.request(request))
            }
            catch
            {
                removeResultHandler(for: request.id)
                throw error
            }
            
            return try await json
        }
        
        private func serverDidSend(_ response: Message.Response)
        {
            switch response.id
            {
            case .value(let id):
                guard let handleResult = resultHandler(for: id) else
                {
                    log(error: "No result handler found")
                    break
                }
                handleResult(response.result)
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
        
        // MARK: - Manage Result Handlers
        
        private func saveResultHandler(for id: Message.ID,
                                       resultHandler: @escaping ResultHandler)
        {
            switch id
            {
            case .string(let idString):
                resultHandlersString[idString] = resultHandler
            case .int(let idInt):
                resultHandlersInt[idInt] = resultHandler
            }
        }
        
        private func removeResultHandler(for id: Message.ID)
        {
            switch id
            {
            case .string(let idString):
                resultHandlersString[idString] = nil
            case .int(let idInt):
                resultHandlersInt[idInt] = nil
            }
        }
        
        private func resultHandler(for id: Message.ID) -> ResultHandler?
        {
            switch id
            {
            case .string(let idString):
                return resultHandlersString[idString]
            case .int(let idInt):
                return resultHandlersInt[idInt]
            }
        }
        
        private var resultHandlersInt = [RequestIDInt: ResultHandler]()
        private typealias RequestIDInt = Int
        
        private var resultHandlersString = [RequestIDString: ResultHandler]()
        private typealias RequestIDString = String
        
        public typealias ResultHandler = (Result<JSON, ErrorResult>) -> Void
        public typealias ErrorResult = Message.Response.ErrorResult
        
        // MARK: - Forward to Connection
        
        public func notify(_ notification: Message.Notification) async throws
        {
            try await connection.sendToServer(.notification(notification))
        }
        
        public var serverDidSendNotification: (Message.Notification) -> Void = { _ in }
        public var serverDidSendErrorOutput: (String) -> Void = { _ in }
        public var connectionDidSendError: (Error) -> Void = { _ in }
        
        private let connection: LSPServerConnection
        public let language: String
    }
}
