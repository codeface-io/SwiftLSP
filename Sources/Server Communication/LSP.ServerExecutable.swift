import FoundationToolz
import SwiftyToolz

public extension LSP {

    /// This does not work in a sandboxed app!
    class ServerExecutable: Executable {
        
        // MARK: - Life Cycle
        
        public override init(config: Configuration) throws {
            try super.init(config: config)
            
            didSendOutput = { [weak self] in self?.packetDetector.read($0) }
        }
        
        // MARK: - LSP Packet Output
        
        private lazy var packetDetector: LSP.PacketDetector = {
            .init { [weak self] in self?.didSend($0) }
        }()
        
        public var didSend: (LSP.Packet) -> Void = { _ in
            log(warning: "LSP server did send lsp packet, but handler has not been set")
        }
    }
}
