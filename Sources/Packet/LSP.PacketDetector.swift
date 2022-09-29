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
            queue += data
            
            while !queue.isEmpty, let lspPacket = removeLSPPacketFromQueue()
            {
                didDetect(lspPacket)
            }
        }
        
        public var didDetect: (Packet) -> Void = { _ in }

        // MARK: - Data Buffer Queue (Instance State)
        
        private func removeLSPPacketFromQueue() -> Packet?
        {
            guard !queue.isEmpty,
                  let packet = try? Packet(parsingPrefixOf: queue)
            else { return nil }
            
            queue.removeFirst(packet.length)
            queue.resetIndices()
            
            return packet
        }
        
        private var queue = Data()
    }
}

extension Data
{
    mutating func resetIndices()
    {
        self = Data(self)
    }
}
