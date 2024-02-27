import SwiftUI
import Combine

public protocol NavDestinable {
    func toAnyView() -> AnyView
}

extension InfiniteNavigation {
    @ViewBuilder
    public static func create<Root: View, Destination: NavDestinable>(
        initialStack: [Destination] = [],
        navAction: AnyPublisher<NavAction<Destination>, Never>,
        environments: Environment...,
        root: @escaping () -> Root
    ) -> some View {
        create(
            initialStack: initialStack.map { AnyViewDestination(destination: $0) },
            navAction: navAction.map { destination in destination.map { AnyViewDestination(destination: $0) } }.eraseToAnyPublisher(),
            environments: environments,
            viewBuilder: { $0.value.toAnyView() },
            root: root
        )
    }
}
