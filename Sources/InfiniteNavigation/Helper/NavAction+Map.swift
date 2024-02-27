
extension NavAction {
    public func map<Result>(_ map: @escaping (T) -> Result) -> NavAction<Result> {
        switch self {
        case .show(let destination):
            switch destination {
            case .detail(let element):
                return .show(.detail(map(element)))
            case .sheet(let element):
                return .show(.sheet(map(element)))
            }
        case .setStack(let stack):
            return .setStack(stack.map(map))
        case .dismiss: return .dismiss
        case .pop: return .pop
        case .popToCurrentRoot: return .popToCurrentRoot
        }
    }
}
