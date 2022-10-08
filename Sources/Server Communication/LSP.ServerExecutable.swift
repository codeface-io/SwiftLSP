import FoundationToolz
import SwiftyToolz

public extension LSP {

    /// This does not work in a sandboxed app!
    class ServerExecutable: Executable {
        
        // MARK: - Life Cycle
        
        public init(config: Configuration,
                    handleLSPPacket: @escaping (LSP.Packet) -> Void) throws {
            packetDetector = PacketDetector(handleLSPPacket)
            try super.init(config: config)
            
            // TODO: output-, error- and termination handler should be passed to the Executable initializer directly! also to force they're being set or at least to force the client to make a conscious decision on wehther to set them
            didSendOutput = { [weak self] in self?.packetDetector.read($0) }
        }
        
        // MARK: - LSP Packet Output
        
        private let packetDetector: LSP.PacketDetector
    }
}
