public extension LSP
{
    /**
     https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocumentItem
     */
    struct LanguageIdentifier
    {
        public init(languageName: String)
        {
            string = Self.string(forLanguageName: languageName)
        }
        
        public let string: String
        
        private static func string(forLanguageName languageName: String) -> String
        {
            let lowercasedLanguageName = languageName.lowercased()
            return stringByLowercasedLanguageName[lowercasedLanguageName] ?? lowercasedLanguageName
        }
        
        private static let stringByLowercasedLanguageName: [String : String] = [
            "objective-c++": "objective-cpp",
            "c++": "cpp",
            "c#": "csharp",
            "visual basic": "vb"
        ]
    }
}
