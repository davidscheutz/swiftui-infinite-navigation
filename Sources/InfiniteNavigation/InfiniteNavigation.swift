import SwiftUI
import Combine

public struct InfiniteNavigation {
    
    /// Creates an instance with an enviroment object
    @ViewBuilder
    public static func create<Root: SwiftUI.View, View: Hashable>(
        initialStack: [View] = [],
        navAction: AnyPublisher<NavAction<View>, Never>,
        environments: any ObservableObject...,
        viewBuilder: @escaping (View) -> AnyView,
        root: @escaping () -> Root
    ) -> some SwiftUI.View {
        if #available(iOS 16.0, *) {
            InfiniteNavContainer(
                initialStack: initialStack,
                navAction: navAction,
                environments: environments,
                viewBuilder: viewBuilder,
                root: root
            )
        } else {
            LegacyInfiniteNavContainer<Root, View>(
                initialStack: initialStack,
                navAction: navAction,
                environments: environments,
                viewBuilder: viewBuilder,
                root: root
            )
            .ignoresSafeArea()
        }
    }
    
    /// Creates an instance with an empty enviroment object
    @ViewBuilder
    public static func create<Root: SwiftUI.View, View: Hashable>(
        initialStack: [View] = [],
        navAction: AnyPublisher<NavAction<View>, Never>,
        viewBuilder: @escaping (View) -> AnyView,
        root: @escaping () -> Root
    ) -> some SwiftUI.View {
        if #available(iOS 16.0, *) {
            InfiniteNavContainer(
                initialStack: initialStack,
                navAction: navAction,
                viewBuilder: viewBuilder,
                root: root
            )
        } else {
            LegacyInfiniteNavContainer<Root, View>(
                initialStack: initialStack,
                navAction: navAction,
                viewBuilder: viewBuilder,
                root: root
            )
            .ignoresSafeArea()
        }
    }
}
