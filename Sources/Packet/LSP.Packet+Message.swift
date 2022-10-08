import Foundation

public extension LSP.Packet
{
    /**
     Creates an `LSP.Packet` that wraps an encoded `LSP.Message` for data transport
     
     - Parameter message: The LSP message to encode for data transport
     */
    init(_ message: LSP.Message) throws
    {
        try self.init(withContent: message.encode())
    }
    
    /**
     Extracts the `LSP.Message` encoded in the packet's `content` part
     
     See the [LSP content part specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#contentPart).
    
     - Returns: The `LSP.Message` encoded in the packet's `content` part
     */
    func message() throws -> LSP.Message
    {
        try LSP.Message(content)
    }
}
