import SwiftyToolz

extension LSP.Message
{
    /**
     Creates an LSP message from JSON. Throws an error if the JSON does not form a valid LSP message according to the LSP specification.
     */
    public init(_ messageJSON: JSON) throws
    {
        // TODO: this func is super critical and should be covered by multiple unit tests ensuring it throws errors exactly when the JSON does not comply to the LSP specification
        
        guard let nullableID = Self.getNullableID(fromMessage: messageJSON) else
        {
            // if it has no id, it must be a notification
            self = try .notification(.init(method: messageJSON.string("method"),
                                           params: messageJSON.params))
            return
        }
        
        if let result = messageJSON.result // success response
        {
            self = .response(.init(id: nullableID, result: .success(result)))
        }
        else if let error = messageJSON.error  // error response
        {
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
                                      params: messageJSON.params))
        }
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
    
    public func json() -> JSON
    {
        var dictionary: [String : JSON] = ["jsonrpc": .string("2.0")]
        
        switch self
        {
        case .request(let request):
            dictionary["id"] = request.id.json
            dictionary["method"] = .string(request.method)
            dictionary["params"] = request.params
        case .response(let response):
            dictionary["id"] = response.id.json
            switch response.result
            {
            case .success(let jsonResult):
                dictionary["result"] = jsonResult
            case .failure(let errorResult):
                dictionary["error"] = errorResult.json()
            }
        case .notification(let notification):
            dictionary["method"] = .string(notification.method)
            dictionary["params"] = notification.params
        }
        
        return .dictionary(dictionary)
    }
}

extension LSP.Message.Response.ErrorResult
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
        
        return .dictionary(dictionary)
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
