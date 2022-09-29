import XCTest
@testable import SwiftLSP
import SwiftyToolz

final class SwiftLSPTests: XCTestCase {
    
    // MARK: - Message
    
    func testNewRequestMessageHasUUIDasID() throws {
        
        let message = LSP.Message.Request(method: "method", params: nil)
        
        guard case .string(let idString) = message.id else {
            throw "Message ID is not a String"
        }
        
        XCTAssertNotNil(UUID(uuidString: idString))
    }
    
    // MARK: - Message JSON
    
    func testGettingRequestMessageJSON() throws
    {
        let request = LSP.Message.Request(method: "someMethod",
                                          params: .object(["testBool": .bool(true)]))
        let requestMessage = LSP.Message.request(request)
        let requestMessageJSON = requestMessage.json()
        
        XCTAssertEqual(requestMessageJSON.jsonrpc, .string("2.0"))
        try testMessageJSONHasUUIDBasedID(requestMessageJSON)
        XCTAssertEqual(requestMessageJSON.method, .string("someMethod"))
        XCTAssertEqual(requestMessageJSON.params, .dictionary(["testBool": .bool(true)]))
        XCTAssertNil(requestMessageJSON.bullshit)
    }
    
    func testGettingResponseMessageJSON() throws
    {
        let response = LSP.Message.Response(id: .value(.string(UUID().uuidString)),
                                            result: .success(.string("42")))
        let responseMessage = LSP.Message.response(response)
        let responseMessageJSON = responseMessage.json()
        
        XCTAssertEqual(responseMessageJSON.jsonrpc, .string("2.0"))
        try testMessageJSONHasUUIDBasedID(responseMessageJSON)
        XCTAssertEqual(responseMessageJSON.result, .string("42"))
        XCTAssertNil(responseMessageJSON.method)
    }
    
    func testMessageJSONHasUUIDBasedID(_ messageJSON: JSON) throws
    {
        guard case .string(let idString) = messageJSON.id else
        {
            throw "Message JSON id is not a String"
        }
        
        XCTAssertNotNil(UUID(uuidString: idString))
    }
    
    func testGettingNotificationMessageJSON() throws
    {
        let notification = LSP.Message.Notification(method: "someMethod",
                                                    params: nil)
        let notificationMessage = LSP.Message.notification(notification)
        let notificationMessageJSON = notificationMessage.json()
        
        XCTAssertEqual(notificationMessageJSON.jsonrpc, .string("2.0"))
        XCTAssertNil(notificationMessageJSON.id)
        XCTAssertEqual(notificationMessageJSON.method, .string("someMethod"))
        XCTAssertNil(notificationMessageJSON.params)
    }
    
    func testMakingRequestMessageFromJSON() throws
    {
        let requestMessageJSON = JSON.dictionary([
            "id": .string("someID"),
            "method": .string("someMethod")
        ])
        
        let requestMessage = try LSP.Message(requestMessageJSON)
        
        guard case .request(let request) = requestMessage else
        {
            throw "Message from request message JSON is not a request message"
        }
        
        XCTAssertEqual(request.id, .string("someID"))
        XCTAssertEqual(request.method, "someMethod")
        XCTAssertNil(request.params)
    }
    
    func testMakingResponseMessageFromJSON() throws
    {
        let responseMessageJSON = JSON.dictionary([
            "id": .string("someID"),
            "result": .string("Some Result")
        ])
        
        let responseMessage = try LSP.Message(responseMessageJSON)
        
        guard case .response(let response) = responseMessage else
        {
            throw "Message from response message JSON is not a response message"
        }
        
        XCTAssertEqual(response.id, .value(.string("someID")))
        XCTAssertEqual(response.result, .success(.string("Some Result")))
    }
    
    func testMakingErrorResponseMessageFromJSON() throws
    {
        let errorResult = LSP.ErrorResult(code: 1,
                                          message: "Error Message",
                                          data: .string("Error Data"))
        
        let responseMessageJSON = JSON.dictionary([
            "id": .string("someID"),
            "error": errorResult.json()
        ])
        
        let responseMessage = try LSP.Message(responseMessageJSON)
        
        guard case .response(let response) = responseMessage else
        {
            throw "Message from response message JSON is not a response message"
        }
        
        XCTAssertEqual(response.id, .value(.string("someID")))
        XCTAssertEqual(response.result, .failure(errorResult))
    }
    
    func testMakingNotificationMessageFromJSON() throws
    {
        let notificationMessageJSON = JSON.dictionary([
            "method": .string("someMethod"),
            "params": .dictionary(["testNumber": .int(123)])
        ])
        
        let notificationMessage = try LSP.Message(notificationMessageJSON)
        
        guard case .notification(let notification) = notificationMessage else
        {
            throw "Message from notification message JSON is not a notification message"
        }
        
        XCTAssertEqual(notification.method, "someMethod")
        XCTAssertEqual(notification.params, .object(["testNumber": .int(123)]))
    }
    
    func testMakingMessageFromInvalidJSONFails()
    {
        XCTAssertThrowsError(try LSP.Message(JSON.dictionary([:])))
        XCTAssertThrowsError(try LSP.Message(JSON.dictionary(["id": .int(123)])))
        XCTAssertThrowsError(try LSP.Message(JSON.dictionary(["id": .null])))
        XCTAssertThrowsError(try LSP.Message(JSON.dictionary(["id": .null,
                                                              "method": .string("someMethod")])))
        
        // if it has id, method AND result, it's not clear whether it's a request or a response
        XCTAssertThrowsError(try LSP.Message(JSON.dictionary(["id": .int(123),
                                                              "method": .string("someMethod"),
                                                              "result": .dictionary(["resultInt": .int(42)])])))
    }
    
    // MARK: - Message Data
    
    func testDecodingMessageFromData() throws {
        
        let messageString = #"{"jsonrpc":"2.0","id":"C0DC9B39-5DCF-474A-BF78-7C18F37CFDEF","result":{"capabilities":{"hoverProvider":true,"implementationProvider":true,"colorProvider":true,"codeActionProvider":true,"foldingRangeProvider":true,"documentHighlightProvider":true,"definitionProvider":true,"documentSymbolProvider":true,"executeCommandProvider":{"commands":["semantic.refactor.command"]},"completionProvider":{"resolveProvider":false,"triggerCharacters":["."]},"referencesProvider":true,"textDocumentSync":{"willSave":true,"save":{"includeText":false},"openClose":true,"change":2,"willSaveWaitUntil":false},"workspaceSymbolProvider":true}}}"#
        
        _ = try LSP.Message(messageString.data!)
    }
}
