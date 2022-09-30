# SwiftLSP

... employs a quite dynamic Swift representation of the [LSP (Language Server Protocol)](https://microsoft.github.io/language-server-protocol) and helps with:

* Launching an LSP server executable
* Extracting LSP Packets from a data stream
* Encoding and decoding LSP messages
* Representing, creating and working with LSP messages
* Matching response messages to request messages
* Exchanging LSP Messages with an LSP Server
* Exchanging LSP Messages with an LSP Server via WebSocket

SwiftLSP is the basis for [LSPService](https://github.com/codeface-io/LSPService) and [LSPServiceKit](https://github.com/codeface-io/LSPServiceKit).

## Architecture

Some context and essential types:

![architecture](Documentation/architecture.jpg)

Internal architecture (composition and essential dependencies) of the top-level source folder:

![](Documentation/SwiftLSP.png)

The above image was generated with the [codeface.io app](https://codeface.io).







