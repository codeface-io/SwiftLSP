import XCTest
@testable import SwiftLSP

final class SwiftLSPTests: XCTestCase {
    
    func testDecodingMessageFromData() throws {
        let messageString = #"{"jsonrpc":"2.0","id":"C0DC9B39-5DCF-474A-BF78-7C18F37CFDEF","result":{"capabilities":{"hoverProvider":true,"implementationProvider":true,"colorProvider":true,"codeActionProvider":true,"foldingRangeProvider":true,"documentHighlightProvider":true,"definitionProvider":true,"documentSymbolProvider":true,"executeCommandProvider":{"commands":["semantic.refactor.command"]},"completionProvider":{"resolveProvider":false,"triggerCharacters":["."]},"referencesProvider":true,"textDocumentSync":{"willSave":true,"save":{"includeText":false},"openClose":true,"change":2,"willSaveWaitUntil":false},"workspaceSymbolProvider":true}}}"#
        
        _ = try LSP.Message(messageString.data!)
    }
}
