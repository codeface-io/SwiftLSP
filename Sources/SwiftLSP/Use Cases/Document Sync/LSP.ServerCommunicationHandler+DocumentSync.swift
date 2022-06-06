import FoundationToolz
import SwiftyToolz

public extension LSP.ServerCommunicationHandler
{
    func notifyDidOpen(_ document: LSPDocumentUri,
                       containingText text: String) throws
    {
        let docJSONObject: [String: JSONObject] =
        [
            "uri": document,
            "languageId": language,
            "version": 1,
            "text": text
        ]
        
        try notify(.didOpen(doc: JSON(jsonObject: docJSONObject)))
    }
}
