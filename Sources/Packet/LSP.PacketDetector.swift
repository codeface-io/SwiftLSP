import FoundationToolz
import Foundation
import SwiftyToolz

extension LSP
{
    /**
     Parses ``LSP/Packet``s from `Data`
     */
    public class PacketDetector
    {
        // MARK: - Public API
        
        /**
         Creates a ``LSP/PacketDetector`` with a closure for handling detected ``LSP/Packet``s
         */
        public init(_ handleDetectedPacket: @escaping (Packet) -> Void)
        {
            didDetect = handleDetectedPacket
        }
        
        /**
         Reads another Byte from a `Data` stream. Calls the given handler for new ``LSP/Packet``s
         
         Calls the handler provided via the initializer if the stream contains a new `LSP.Packet` since the last call of the handler
         */
        public func read(_ byte: Byte)
        {
            read(Data([byte]))
        }
        
        /**
         Reads another chunk of a `Data` stream. Calls the given handler for new ``LSP/Packet``s
         
         Calls the handler provided via the initializer once for each `LSP.Packet` in the stream since the last call of the handler
         */
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
