import SwiftyToolz

extension LSP.Message
{
    /**
     Create a ``LSP/Message`` from `JSON`
     
     Throws an error if the JSON does not form a valid LSP message according to the LSP specification.
     
     See <https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#contentPart>
     */
    public init(_ messageJSON: JSON) throws
    {
        // TODO: this func is super critical and should be covered by multiple unit tests ensuring it throws errors exactly when the JSON does not comply to the LSP specification
        
        guard let nullableID = Self.getNullableID(fromMessage: messageJSON) else
        {
            // if it has no id, it must be a notification
            self = try .notification(.init(method: messageJSON.string("method"),
                                           params: Self.params(fromMessageJSON: messageJSON)))
            return
        }
        
        // it's not a notification. if it has result or error, it's a response
        
        if let result = messageJSON.result // success response
        {
            guard messageJSON.method == nil else
            {
                throw "LSP message JSON has an id, a result and a method, so the message type is unclear."
            }
            
            self = .response(.init(id: nullableID, result: .success(result)))
        }
        else if let error = messageJSON.error  // error response
        {
            guard messageJSON.method == nil else
            {
                throw "LSP message JSON has an id, an error and a method, so the message type is unclear."
            }
            
            self = .response(.init(id: nullableID,
                                   result: .failure(try .init(error))))
        }
        else // request
        {
            guard case .value(let id) = nullableID else
            {
                throw "Invalid LSP message JSON: It contains neither an error nor a result (so it's not a response) and has a <null> id (so it's neither a notification nor a request)."
            }
            
            self = try .request(.init(id: id,
                                      method: messageJSON.string("method"),
                                      params: try Self.params(fromMessageJSON: messageJSON)))
        }
    }
    
    private static func params(fromMessageJSON messageJSON: JSON) throws -> JSON.Container?
    {
        guard let paramsJSON = messageJSON.params else { return nil }
        return try .init(paramsJSON)
    }
    
    private static func getNullableID(fromMessage messageJSON: JSON) -> NullableID?
    {
        guard let idJSON = messageJSON.id else { return nil }
        
        switch idJSON
        {
        case .null: return .null
        case .int(let int): return .value(.int(int))
        case .string(let string): return .value(.string(string))
        default: return nil
        }
    }
    
    /**
     Create a valid LSP JSON of the message
     
     See <https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#contentPart>
     */
    public func json() -> JSON
    {
        .object(["jsonrpc": JSON.string("2.0")] + caseJSONDictionary())
    }
    
    internal func caseJSONDictionary() -> [String: JSON]
    {
        switch self
        {
        case .request(let request): return request.jsonDictionary()
        case .response(let response): return response.jsonDictionary()
        case .notification(let notification): return notification.jsonDictionary()
        }
    }
}

extension LSP.Message.Request
{
    func jsonDictionary() -> [String : JSON]
    {
        var dictionary = [ "id": id.json, "method": .string(method) ]
        dictionary["params"] = params?.json()
        return dictionary
    }
}

extension LSP.Message.Response
{
    func jsonDictionary() -> [String : JSON]
    {
        var dictionary = ["id": id.json]
        
        switch result
        {
        case .success(let jsonResult): dictionary["result"] = jsonResult
        case .failure(let errorResult): dictionary["error"] = errorResult.json()
        }
        
        return dictionary
    }
}

extension LSP.Message.Notification
{
    func jsonDictionary() -> [String : JSON]
    {
        var dictionary = ["method": JSON.string(method)]
        dictionary["params"] = params?.json()
        return dictionary
    }
}

extension LSP.ErrorResult
{
    init(_ json: JSON) throws
    {
        self.code = try json.int("code")
        self.message = try json.string("message")
        data = json.data
    }
    
    func json() -> JSON
    {
        var dictionary: [String: JSON] =
        [
            "code": .int(code),
            "message": .string(message)
        ]
        
        dictionary["data"] = data
        
        return .object(dictionary)
    }
}

extension LSP.Message.NullableID
{
    var json: JSON
    {
        switch self
        {
        case .value(let id): return id.json
        case .null: return .null
        }
    }
}

extension LSP.Message.ID
{
    var json: JSON
    {
        switch self
        {
        case .string(let string): return .string(string)
        case .int(let int): return .int(int)
        }
    }
}
