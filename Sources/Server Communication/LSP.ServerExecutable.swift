import FoundationToolz
import SwiftyToolz

public extension LSP {

    /// This does not work in a sandboxed app!
    class ServerExecutable: Executable {
        
        // MARK: - Life Cycle
        
        public override init(config: Configuration) throws {
            try super.init(config: config)
            
            setupPacketOutput()
        }
        
        // MARK: - LSP Packet Output
        
        private func setupPacketOutput() {
            didSendOutput = { [weak self] in self?.packetDetector.read($0) }
            packetDetector.didDetect = { [weak self] in self?.didSend($0) }
        }
        
        private let packetDetector = LSP.PacketDetector()
        
        public var didSend: (LSP.Packet) -> Void = { _ in
            log(warning: "LSP server did send lsp packet, but handler has not been set")
        }
    }
}
