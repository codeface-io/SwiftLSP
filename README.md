# SwiftLSP

... employs a quite dynamic Swift representation of the [LSP (Language Server Protocol)](https://microsoft.github.io/language-server-protocol) and helps with:

* Launching an LSP server executable
* Extracting LSP Packets from a data stream
* Encoding and decoding LSP messages
* Representing, creating and working with LSP messages
* Matching response messages to request messages
* Exchanging LSP Messages with an LSP Server
* Exchanging LSP Messages with an LSP Server via WebSocket

SwiftLSP is the basis for [LSPService](https://github.com/flowtoolz/LSPService) and [LSPServiceKit](https://github.com/flowtoolz/LSPServiceKit).

Some essential types:

![architecture](Documentation/architecture.jpg)
