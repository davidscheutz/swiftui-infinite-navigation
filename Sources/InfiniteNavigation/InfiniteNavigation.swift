import SwiftUI
import Combine

public struct InfiniteNavigation {
    
    /// Creates an instance with an enviroment object
    public static func create<Root: SwiftUI.View, View>(
        initialStack: [View] = [],
        navAction: AnyPublisher<NavAction<View>, Never>,
        environments: any ObservableObject...,
        viewBuilder: @escaping (View) -> AnyView,
        root: @escaping () -> Root
    ) -> some SwiftUI.View {
        InfiniteNavContainer<Root, View>(
            initialStack: initialStack,
            navAction: navAction,
            environments: environments,
            viewBuilder: viewBuilder,
            root: root
        )
        .ignoresSafeArea()
    }
    
    /// Creates an instance with an empty enviroment object
    public static func create<Root: SwiftUI.View, View>(
        initialStack: [View] = [],
        navAction: AnyPublisher<NavAction<View>, Never>,
        viewBuilder: @escaping (View) -> AnyView,
        root: @escaping () -> Root
    ) -> some SwiftUI.View {
        InfiniteNavContainer<Root, View>(
            initialStack: initialStack,
            navAction: navAction,
            viewBuilder: viewBuilder,
            root: root
        )
        .ignoresSafeArea()
    }
}
