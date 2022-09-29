import Foundation
import SwiftyToolz

public extension LSP
{
    struct Packet
    {
        public init(parsingPrefixOf data: Data) throws
        {
            (header, content) = try Parser.parseHeaderAndContent(fromPrefixOf: data)
        }
        
        public init(withContent content: Data)
        {
            self.header = "Content-Length: \(content.count)".data!
            self.content = content
        }
        
        public var data: Data { header + separator + content }
        public var length: Int { header.count + separator.count + content.count }
        
        public let header: Data
        public var separator: Data { Parser.separator }
        public let content: Data
        
        enum Parser
        {
            static func parseHeaderAndContent(fromPrefixOf data: Data) throws -> (Data, Data)
            {
                guard !data.isEmpty else { throw "Data is empty" }
                
                guard let header = Parser.header(fromBeginningOf: data) else
                {
                    throw "Data doesn't start with header:\n\(data.utf8String!)"
                }
                
                guard let contentLength = Parser.contentLength(fromHeader: header) else
                {
                    throw "Header declares no content length"
                }
                
                let headerPlusSeparatorLength = header.count + separator.count
                let packetLength = headerPlusSeparatorLength + contentLength
                
                guard packetLength <= data.count else { throw "Incomplete packet data" }
                
                return (header, data[headerPlusSeparatorLength ..< packetLength])
            }
            
            static func header(fromBeginningOf data: Data) -> Data?
            {
                guard !data.isEmpty else { return nil }
                
                guard let separatorIndex = indexOfSeparator(in: data) else
                {
                    log(warning: "Data contains no header/content separator:\n\(data.utf8String!)")
                    return nil
                }
                
                guard separatorIndex > 0 else
                {
                    log(error: "Empty header")
                    return nil
                }
                
                return data[0 ..< separatorIndex]
            }
            
            static func indexOfSeparator(in data: Data) -> Int?
            {
                guard !data.isEmpty else { return nil }
                let lastDataIndex = data.count - 1
                let lastPossibleSeparatorIndex = lastDataIndex - (separator.count - 1)
                guard lastPossibleSeparatorIndex >= 0 else { return nil }
                
                for index in 0 ... lastPossibleSeparatorIndex
                {
                    let potentialSeparator = data[index ..< index + separator.count]
                    if potentialSeparator == separator { return index }
                }

                return nil
            }
            
            static func contentLength(fromHeader header: Data) -> Int?
            {
                let headerString = header.utf8String!
                let headerLines = headerString.components(separatedBy: "\r\n")
                
                for headerLine in headerLines
                {
                    if headerLine.hasPrefix("Content-Length")
                    {
                        guard let lengthString = headerLine.components(separatedBy: ": ").last
                        else { return nil }
                        
                        return Int(lengthString)
                    }
                }
                
                return nil
            }
            
            static let separator = Data([13, 10, 13, 10]) // ascii: "\r\n\r\n"
        }
    }
}
