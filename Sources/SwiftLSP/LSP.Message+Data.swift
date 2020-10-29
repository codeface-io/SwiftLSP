import Foundation

extension LSP.Message
{
    public init(_ data: Data) throws
    {
        self = try Self(JSON(data))
    }
    
    public func encode() throws -> Data
    {
        try json().encode()
    }
}
