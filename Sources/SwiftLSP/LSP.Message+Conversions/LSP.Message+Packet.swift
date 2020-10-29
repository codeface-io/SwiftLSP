import Foundation

extension LSP.Message
{
    public init(packet: Data) throws
    {
        let data = try Self.getMessageData(fromPacket: packet)
        self = try Self(data)
    }
    
    public static func getMessageData(fromPacket packet: Data) throws -> Data
    {
        guard let contentIndex = indexOfContent(in: packet) else
        {
            throw "Invalid LSP Packet"
        }
        
        return packet[contentIndex...]
    }
    
    private static func indexOfContent(in packet: Data) -> Int?
    {
        let separatorLength = 4
        
        guard packet.count > separatorLength else { return nil }
        
        let lastIndex = packet.count - 1
        let lastSearchIndex = lastIndex - separatorLength
        
        for index in 0 ... lastSearchIndex
        {
            if packet[index] == 13,
               packet[index + 1] == 10,
               packet[index + 2] == 13,
               packet[index + 3] == 10
            {
                return index + separatorLength
            }
        }
        
        return nil
    }
    
    public func packet() throws -> Data
    {
        try Self.makePacket(withMessageData: encode())
    }
    
    public static func makePacket(withMessageData message: Data) -> Data
    {
        let header = "Content-Length: \(message.count)\r\n\r\n".data!
        return header + message
    }
}
