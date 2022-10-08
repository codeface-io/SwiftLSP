public extension LSP
{
    /**
     An LSP-conform language identifier created from a language name
     
     See [the corresponding specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocumentItem)
     */
    struct LanguageIdentifier
    {
        /**
         Create an LSP-conform language identifier from a language name
         
         See [the corresponding specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocumentItem)
         
         - Parameter languageName: The (more casual) name of the language
         */
        public init(languageName: String)
        {
            string = Self.string(forLanguageName: languageName)
        }
        
        /**
         `String` representation of an LSP language identifier
         
         See [the corresponding specification](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocumentItem)
         */
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
