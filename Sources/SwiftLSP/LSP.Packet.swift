import Foundation
import SwiftyToolz

extension LSP
{
    public struct Packet
    {
        init(parsing data: Data) throws
        {
            guard !data.isEmpty else { throw "Data is empty" }
            
            guard let header = Self.header(fromBeginningOf: data) else
            {
                throw "Data doesn't start with header:\n\(data.utf8String!)"
            }
            
            guard let contentLength = Self.contentLength(fromHeader: header) else
            {
                throw "Header declares no content length"
            }
            
            let packetLength = header.count + Self.headerContentSeparator.count + contentLength
            
            guard packetLength <= data.count else { throw "Incomplete packet data" }
            
            self.data = data[0 ..< packetLength]
        }
        
        public init(content: Data)
        {
            let header = "Content-Length: \(content.count)\r\n\r\n".data!
            data = header + content
        }
        
        public func content() throws -> Data
        {
            guard let indexOfSeparator = Self.indexOfSeparator(in: data) else
            {
                throw "Invalid LSP packet data: No header/content separator"
            }
            
            let indexOfContent = indexOfSeparator + Self.headerContentSeparator.count
            
            guard data.indices.contains(indexOfContent) else
            {
                throw "Invalid LSP packet data: No content"
            }
            
            return data[indexOfContent...]
        }
        
        static func indexOfSeparator(in data: Data) -> Int?
        {
            guard !data.isEmpty else { return nil }
            let lastDataIndex = data.count - 1
            let lastPossibleSeparatorIndex = lastDataIndex - (headerContentSeparator.count - 1)
            guard lastPossibleSeparatorIndex >= 0 else { return nil }
            
            for index in 0 ... lastPossibleSeparatorIndex
            {
                let potentialSeparator = data[index ..< index + headerContentSeparator.count]
                if potentialSeparator == headerContentSeparator { return index }
            }

            return nil
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
        
        static let headerContentSeparator = Data([13, 10, 13, 10]) // ascii: "\r\n\r\n"
        
        public let data: Data
    }
}
