import Foundation

public extension LSP.Packet
{
    init(_ message: LSP.Message) throws
    {
        try self.init(withContent: message.encode())
    }
    
    func message() throws -> LSP.Message
    {
        try LSP.Message(content)
    }
}
