import FoundationToolz
import Foundation
import SwiftyToolz

extension LSP.ServerCommunicationHandler
{
    public func request<Value: Decodable>(_ req: LSP.Message.Request,
                                          as type: Value.Type) async throws -> Result<Value, ErrorResult>
    {
        let result = try await request(req)
        
        return result.flatMap
        {
            valueJSON in
            
            do
            {
                return .success(try valueJSON.decode())
            }
            catch
            {
                log(error)
                return .failure(.init(code: -32603,
                                      message: "Failed to decode result as \(Value.self)",
                                      data: valueJSON))
            }
        }
    }
}

extension LSP
{
    public class ServerCommunicationHandler
    {
        // MARK: - Initialize
        
        public init(connection: LSPServerConnection)
        {
            self.connection = connection
            
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
        }
        
        // MARK: - Process Requests and Responses
        
        public func request(_ request: Message.Request) async throws -> Result<JSON, ErrorResult>
        {
            try await withCheckedThrowingContinuation
            {
                continuation in
                
                saveResultHandler(for: request.id)
                {
                    continuation.resume(with: .success($0))
                }
            
                do
                {
                    try connection.sendToServer(.request(request))
                }
                catch
                {
                    removeResultHandler(for: request.id)
                    continuation.resume(throwing: error)
                }
            }
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
        
        public func notify(_ notification: Message.Notification) throws
        {
            try connection.sendToServer(.notification(notification))
        }
        
        public var serverDidSendNotification: (Message.Notification) -> Void = { _ in }
        public var serverDidSendErrorOutput: (String) -> Void = { _ in }
        
        private let connection: LSPServerConnection
    }
}
