import Foundation
import SwiftyToolz

extension LSP
{
    public typealias Request = Message.Request
    public typealias Response = Message.Response
    public typealias ErrorResult = Message.Response.ErrorResult
    public typealias Notification = Message.Notification
    
    /**
     An LSP Message is either a request, a response or a notification.
     
     See <https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#abstractMessage>
     */
    public enum Message: Equatable
    {
        case response(Response)
        case request(Request)
        case notification(Notification)
        
        /**
         An LSP response message sent from an LSP server t a client in response to an LSP request message.
         
         Its `id` should match the `id` of the corresponding `Request` that triggered this response.
         
         See <https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#responseMessage>
         */
        public struct Response: Equatable
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
        
        /// An LSP message ID that can also be null
        public enum NullableID: Equatable
        {
            case value(ID), null
        }
        
        /**
         An LSP request message sent from a client to an LSPServer
         
         See <https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#requestMessage>
         */
        public struct Request: Equatable
        {
            public init(id: ID = ID(), method: String, params: JSON.Container?)
            {
                self.id = id
                self.method = method
                self.params = params
            }
            
            public let id: ID
            public let method: String
            public let params: JSON.Container?
        }
        
        /// A basic LSP message ID is either a string or an integer
        public enum ID: Hashable
        {
            public init() { self = .string(UUID().uuidString) }
            
            case string(String), int(Int)
        }
        
        /**
         An LSP notification message is sent between an LSPServer and its client
         
         See <https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#notificationMessage>
         */
        public struct Notification: Equatable
        {
            public init(method: String, params: JSON.Container?)
            {
                self.method = method
                self.params = params
            }
            
            public let method: String
            public let params: JSON.Container?
        }
    }
}
