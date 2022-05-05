# SwiftLSP

... employs a quite dynamic Swift representation of the [LSP (Language Server Protocol)](https://microsoft.github.io/language-server-protocol) and helps with:

* Extracting LSP Packets from a data stream
* Representing and working with LSP messages
* Matching response messages to request messages
* Creating specific LSP messages
* Exchanging LSP Messages with an LSP Server

SwiftLSP is the basis for [LSPService](https://github.com/flowtoolz/LSPService) and [LSPServiceKit](https://github.com/flowtoolz/LSPServiceKit).

Some essential types:

![architecture](Documentation/architecture.jpg)