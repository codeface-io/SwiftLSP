import FoundationToolz
import SwiftyToolz

public extension LSP.ServerCommunicationHandler
{
    func notifyDidOpen(_ document: LSPDocumentUri,
                       containingText text: String) async throws
    {
        let docJSONObject: [String: JSONObject] =
        [
            "uri": document,
            "languageId": language,
            "version": 1,
            "text": text
        ]
        
        try await notify(.didOpen(doc: JSON(jsonObject: docJSONObject)))
    }
}
