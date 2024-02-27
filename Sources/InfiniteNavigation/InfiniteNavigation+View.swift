import SwiftUI
import Combine

extension InfiniteNavigation {
    @ViewBuilder
    public static func create<Root: View>(
        initialStack: [some View] = [],
        navAction: AnyPublisher<NavAction<some View>, Never>,
        environments: Environment...,
        root: @escaping () -> Root
    ) -> some View {
        create(
            initialStack: initialStack.map { AnyViewDestination(value: $0) },
            navAction: navAction.map { destination in destination.map { AnyViewDestination(value: $0) } }.eraseToAnyPublisher(),
            environments: environments,
            viewBuilder: { $0.value },
            root: root
        )
    }
}
