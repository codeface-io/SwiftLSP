import Foundation
import SwiftyToolz

extension LSP.Message
{
    /// Create a ``LSP/Message`` from a valid LSP `JSON` encoding
    /// - Parameter data: JSON encoded LSP message. See <https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#contentPart>
    public init(_ data: Data) throws
    {
        self = try Self(JSON(data))
    }
    
    /// Create a valid LSP `JSON` encoding of the message
    /// - Returns: Valid LSP `JSON` encoding. See <https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#contentPart>
    public func encode() throws -> Data
    {
        try json().encode()
    }
}
