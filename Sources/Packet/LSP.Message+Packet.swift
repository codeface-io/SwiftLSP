import Foundation

extension LSP.Message
{
    public init(_ packet: LSP.Packet) throws
    {
        self = try Self(packet.content)
    }
    
    public func packet() throws -> LSP.Packet
    {
        LSP.Packet(withContent: try encode())
    }
}
