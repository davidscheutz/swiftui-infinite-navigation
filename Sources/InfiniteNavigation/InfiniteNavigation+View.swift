import SwiftUI
import Combine

extension InfiniteNavigation {
    
    @ViewBuilder
    public static func create<Root: View>(
        initialStack: [some View] = [],
        navAction: AnyPublisher<NavAction<some View>, Never>,
        environments: any ObservableObject...,
        root: @escaping () -> Root
    ) -> some View {
        create(
            initialStack: initialStack.map { ViewDestination(value: $0) },
            navAction: navAction.map { destination in destination.map { ViewDestination(value: $0) } }.eraseToAnyPublisher(),
            environments: environments,
            viewBuilder: { $0.value.toAnyView() },
            root: root
        )
    }
}

// MARK: - Internal

internal struct ViewDestination: Hashable {
    static func == (lhs: ViewDestination, rhs: ViewDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID().uuidString
    let value: any View
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension NavAction {
    fileprivate func map<U>(_ map: @escaping (T) -> U) -> NavAction<U> {
        switch self {
        case .show(let destination):
            switch destination {
            case .detail(let element):
                return .show(.detail(map(element)))
            case .sheet(let element, let style):
                return .show(.sheet(map(element), style: style))
            }
        case .setStack(let stack):
            return .setStack(stack.map(map))
        case .dismiss: return .dismiss
        case .pop: return .pop
        case .popToCurrentRoot: return .popToCurrentRoot
        }
    }
}
