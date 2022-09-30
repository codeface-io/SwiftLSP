import Foundation

extension LSP.Message
{
    public init(_ packet: LSP.Packet) throws
    {
        self = try Self(packet.content)
    }
    
    public func packet() throws -> LSP.Packet
    {
        try LSP.Packet(withContent: encode())
    }
}
