import FoundationToolz
import Foundation
import SwiftyToolz

extension LSP
{
    public class PacketDetector
    {
        // MARK: - Public API
        
        public init(_ handleDetectedPacket: @escaping (Packet) -> Void)
        {
            didDetect = handleDetectedPacket
        }
        
        public func read(_ byte: Byte)
        {
            read(Data([byte]))
        }
        
        public func read(_ data: Data)
        {
            buffer += data
            
            while !buffer.isEmpty, let lspPacket = removeLSPPacketFromBuffer()
            {
                didDetect(lspPacket)
            }
        }
        
        private let didDetect: (Packet) -> Void

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
