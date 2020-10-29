import Foundation
import SwiftyToolz

// MARK: - Readable Error

extension LSP.Message.Response.Error: ReadableErrorConvertible
{
    public var readableErrorMessage: String { description }
}

// MARK: - CustomStringConvertible

extension LSP.Message: CustomStringConvertible
{
    public var description: String
    {
        json().description
    }
}

extension LSP.Message.Response.Error: CustomStringConvertible
{
    public var description: String
    {
        var errorString = "LSP Error: \(message) (code \(code))"
        data.forSome { errorString += " data:\n\($0)" }
        return errorString
    }
}

extension LSP.Message.NullableID: CustomStringConvertible
{
    public var description: String
    {
        switch self
        {
        case .value(let id): return id.description
        case .null: return NSNull().description
        }
    }
}

extension LSP.Message.ID: CustomStringConvertible
{
    public var description: String
    {
        switch self
        {
        case .string(let string): return string.description
        case .int(let int): return int.description
        }
    }
}
