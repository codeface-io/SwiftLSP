import Foundation
import SwiftyToolz

extension LSP
{
    typealias ErrorResult = Message.Response.ErrorResult
    
    /**
     https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#abstractMessage
     */
    public enum Message
    {
        case response(Response)
        case request(Request)
        case notification(Notification)
        
        /**
         https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#responseMessage
         */
        public struct Response
        {
            public init(id: NullableID, result: Result<JSON, ErrorResult>)
            {
                self.id = id
                self.result = result
            }
            
            public let id: NullableID
            
            /**
             Here are 2 minor deviations from the LSP specification: According to LSP 1) a result value can NOT be an array and 2) when an error is returned, there COULD still also be a result
             */
            public let result: Result<JSON, ErrorResult>
            
            public struct ErrorResult: Error, Equatable
            {
                public let code: Int
                public let message: String
                public let data: JSON?
            }
        }
        
        public enum NullableID: Equatable
        {
            case value(ID), null
        }
        
        /**
         https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#requestMessage
         */
        public struct Request
        {
            public init(id: ID = ID(), method: String, params: Parameters?)
            {
                self.id = id
                self.method = method
                self.params = params
            }
            
            public let id: ID
            public let method: String
            public let params: Parameters?
        }
        
        public enum ID: Hashable
        {
            public init() { self = .string(UUID().uuidString) }
            
            case string(String), int(Int)
        }
        
        /**
         https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#notificationMessage
         */
        public struct Notification
        {
            public init(method: String, params: Parameters?)
            {
                self.method = method
                self.params = params
            }
            
            public let method: String
            public let params: Parameters?
        }
        
        public enum Parameters: Equatable
        {
            case object([String: JSON]), array([JSON])
        }
    }
}
