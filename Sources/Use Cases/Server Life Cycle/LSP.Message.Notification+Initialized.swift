public extension LSP.Message.Notification
{
    static var initialized: Self
    {
        .init(method: "initialized", params: .dictionary([:]))
    }
}
