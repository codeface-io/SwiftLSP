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
        
        public struct Response
        {
            public init(id: NullableID, result: Result<JSON, ErrorResult>)
            {
                self.id = id
                self.result = result
            }
            
            public let id: NullableID
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
            case object([String: JSON])
            case array([JSON])
        }
    }
}
