import FoundationToolz
import Foundation
import SwiftyToolz

extension LSP
{
    public class PacketDetector
    {
        // MARK: - Public API
        
        public init() {}
        
        public func read(_ data: Data)
        {
            buffer += data
            
            while !buffer.isEmpty, let lspPacket = removeLSPPacketFromBuffer()
            {
                didDetect(lspPacket)
            }
        }
        
        public var didDetect: (Packet) -> Void = { _ in }

        // MARK: - Data Buffer
        
        private func removeLSPPacketFromBuffer() -> Packet?
        {
            guard !buffer.isEmpty,
                  let packet = try? Packet(parsingPrefixOf: buffer)
            else { return nil }
            
            buffer.removeFirst(packet.length)
            buffer.resetIndices()
            
            return packet
        }
        
        private var buffer = Data()
    }
}

extension Data
{
    mutating func resetIndices()
    {
        self = Data(self)
    }
}
