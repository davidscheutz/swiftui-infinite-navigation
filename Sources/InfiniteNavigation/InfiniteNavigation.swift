import SwiftUI
import Combine

public struct InfiniteNavigation {
    
    @ViewBuilder
    public static func create<Root: View, Destination: Hashable>(
        initialStack: [Destination] = [],
        navAction: AnyPublisher<NavAction<Destination>, Never>,
        environments: any ObservableObject...,
        viewBuilder: @escaping (Destination) -> some View,
        @ViewBuilder root: @escaping () -> Root
    ) -> some View {
        create(
            initialStack: initialStack,
            navAction: navAction,
            environments: environments,
            viewBuilder: viewBuilder,
            root: root
        )
    }
    
    @ViewBuilder
    public static func create<Root: View, Destination: Hashable>(
        initialStack: [Destination] = [],
        navAction: AnyPublisher<NavAction<Destination>, Never>,
        environments: Environments = [],
        viewBuilder: @escaping (Destination) -> some View,
        @ViewBuilder root: @escaping () -> Root
    ) -> some View {
        if #available(iOS 16.0, *) {
            InfiniteNavContainer(
                initialStack: initialStack,
                navAction: navAction,
                environments: environments,
                viewBuilder: viewBuilder,
                root: root
            )
        } else {
            LegacyInfiniteNavContainer<Root, Destination>(
                initialStack: initialStack,
                navAction: navAction,
                environments: environments,
                viewBuilder: viewBuilder,
                root: root
            )
            .ignoresSafeArea()
        }
    }
}
