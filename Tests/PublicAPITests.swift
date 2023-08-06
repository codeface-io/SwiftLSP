import SwiftLSP // Do not use @testable❗️ we wanna test public API here like a real client
import XCTest

final class PublicAPITests: XCTestCase {
    
    func testCreatingLSPTypes() {
        _ = LSP.Message.Request(method: "just do it!")
        _ = LSP.Message.Response(id: .value(.string(.randomID())),
                                 result: .success(.bool(true)))
        _ = LSP.Message.Notification(method: "just wanted to say hi")
        _ = LSP.ErrorResult(code: 1000, message: "some LSP error occured")
    }
}
