import XCTest
@testable import SwiftLSP
import FoundationToolz
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
        XCTAssertEqual(requestMessageJSON.params, .object(["testBool": .bool(true)]))
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
        let requestMessageJSON = JSON.object([
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
        let responseMessageJSON = JSON.object([
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
        
        let responseMessageJSON = JSON.object([
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
        let notificationMessageJSON = JSON.object([
            "method": .string("someMethod"),
            "params": .object(["testNumber": .int(123)])
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
        XCTAssertThrowsError(try LSP.Message(JSON.object([:])))
        XCTAssertThrowsError(try LSP.Message(JSON.object(["id": .int(123)])))
        XCTAssertThrowsError(try LSP.Message(JSON.object(["id": .null])))
        XCTAssertThrowsError(try LSP.Message(JSON.object(["id": .null,
                                                          "method": .string("someMethod")])))
        
        // if it has id, method AND result, it's not clear whether it's a request or a response
        XCTAssertThrowsError(try LSP.Message(JSON.object(["id": .int(123),
                                                          "method": .string("someMethod"),
                                                          "result": .object(["resultInt": .int(42)])])))
    }
    
    // MARK: - Message Data
    
    func testConvertingBetweenMessageAndData() throws {
        let messageJSONString = #"{"jsonrpc":"2.0","id":"C0DC9B39-5DCF-474A-BF78-7C18F37CFDEF","result":{"capabilities":{"hoverProvider":true,"implementationProvider":true,"colorProvider":true,"codeActionProvider":true,"foldingRangeProvider":true,"documentHighlightProvider":true,"definitionProvider":true,"documentSymbolProvider":true,"executeCommandProvider":{"commands":["semantic.refactor.command"]},"completionProvider":{"resolveProvider":false,"triggerCharacters":["."]},"referencesProvider":true,"textDocumentSync":{"willSave":true,"save":{"includeText":false},"openClose":true,"change":2,"willSaveWaitUntil":false},"workspaceSymbolProvider":true}}}"#
        
        let message = try LSP.Message(messageJSONString.data!)
        let encodedMessage = try message.encode()
        let messageDecodedAgain = try LSP.Message(encodedMessage)
        XCTAssertEqual(message, messageDecodedAgain)
    }
    
    // MARK: - Packet
    
    func testPacket() throws {
        let messageJSONString = #"{"jsonrpc":"2.0", "method":"someMethod"}"#
        let packet1 = try LSP.Packet(withContent: messageJSONString.data!)
        _ = try LSP.Message(packet1)
        
        let packetBufferString = "Content-Length: 40\r\n\r\n" + messageJSONString + "Next packet or other data"
        let packet2 = try LSP.Packet(parsingPrefixOf: packetBufferString.data!)
        _ = try LSP.Message(packet2)
        
        XCTAssertThrowsError(try LSP.Packet(withContent: Data()))
        XCTAssertThrowsError(try LSP.Packet(withContent: (messageJSONString + "{}").data!))
        XCTAssertThrowsError(try LSP.Packet(withContent: messageJSONString.removing("}").data!))
        XCTAssertThrowsError(try LSP.Packet(parsingPrefixOf: messageJSONString.data!))
    }
    
    // MARK: - Packet Detector
    
    func testPacketDetector() {
        let detector = LSP.PacketDetector()
        var detectedPackets = [LSP.Packet]()
        detector.didDetect = { detectedPackets += $0 }
        
        let header = "Content-Length: 40".data!
        let separator = "\r\n\r\n".data!
        let messageJSON = #"{"jsonrpc":"2.0", "method":"someMethod"}"#.data!
        
        detector.read(header)
        XCTAssertEqual(detectedPackets.count, 0)
        
        detector.read(separator)
        XCTAssertEqual(detectedPackets.count, 0)
        
        detector.read(messageJSON)
        XCTAssertEqual(detectedPackets.count, 1)
        
        detector.read(header)
        XCTAssertEqual(detectedPackets.count, 1)
        
        detector.read(separator)
        XCTAssertEqual(detectedPackets.count, 1)
        
        detector.read(messageJSON + Data(count: 10))
        XCTAssertEqual(detectedPackets.count, 2)
    }
    
    // MARK: - LSP Language Identifier
    
    func testLanguageIdentifier() {
        XCTAssertEqual(LSP.LanguageIdentifier(languageName: "Swift").string, "swift")
        XCTAssertEqual(LSP.LanguageIdentifier(languageName: "python").string, "python")
        XCTAssertEqual(LSP.LanguageIdentifier(languageName: "C++").string, "cpp")
        XCTAssertEqual(LSP.LanguageIdentifier(languageName: "C#").string, "csharp")
    }
}
