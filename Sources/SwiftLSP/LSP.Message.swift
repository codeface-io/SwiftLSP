import FoundationToolz
import Foundation

extension LSP
{
    public enum Message
    {
        case response(Response)
        case request(Request)
        case notification(Notification)
        
        public struct Response
        {
            public init(id: NullableID, result: Result<JSON, Error>)
            {
                self.id = id
                self.result = result
            }
            
            public let id: NullableID
            public let result: Result<JSON, Error>
            
            public struct Error: Swift.Error
            {
                public let code: Int
                public let message: String
                public let data: JSON?
            }
        }
        
        public enum NullableID
        {
            case value(ID), null
        }
        
        public struct Request
        {
            public init(id: ID = ID(), method: String, params: JSON?)
            {
                self.id = id
                self.method = method
                self.params = params
            }
            
            public let id: ID
            public let method: String
            public let params: JSON?
        }
        
        public enum ID
        {
            public init() { self = .string(UUID().uuidString) }
            
            case string(String), int(Int)
        }
        
        public struct Notification
        {
            public init(method: String, params: JSON?)
            {
                self.method = method
                self.params = params
            }
            
            public let method: String
            public let params: JSON?
        }
    }
}
