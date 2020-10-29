import Foundation

extension LSP.Message
{
    public init(_ json: JSON) throws
    {
        guard let nullableID = Self.getID(fromMessage: json) else
        {
            self = try .notification(.init(method: json.string("method"),
                                           params: json.params))
            return
        }
        
        if let result = json.result // success response
        {
            self = .response(.init(id: nullableID, result: .success(result)))
        }
        else if let error = json.error  // error response
        {
            self = .response(.init(id: nullableID,
                                   result: .failure(try .init(error))))
        }
        else // request
        {
            guard case .value(let id) = nullableID else
            {
                throw "Invalid message JSON: Either it's a response with no error and no result, or it's a request/notification with a <null> id"
            }
            
            self = try .request(.init(id: id,
                                      method: json.string("method"),
                                      params: json.params))
        }
    }
    
    private static func getID(fromMessage json: JSON) -> NullableID?
    {
        guard let idJSON = json.id else { return nil }
        
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
            case .success(let resultJSON):
                dictionary["result"] = resultJSON
            case .failure(let error):
                dictionary["error"] = error.json()
            }
        case .notification(let notification):
            dictionary["method"] = .string(notification.method)
            dictionary["params"] = notification.params
        }
        
        return .dictionary(dictionary)
    }
}

extension LSP.Message.Response.Error
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
