import SwiftUI
import Combine

public struct InfiniteNavigation {
    
    /// Creates an instance with an enviroment object
    public static func create<Root: SwiftUI.View, View, Environment: ObservableObject>(
        initialStack: [View] = [],
        navAction: AnyPublisher<NavAction<View>, Never>,
        environment: Environment,
        viewBuilder: @escaping (View) -> AnyView,
        root: @escaping () -> Root
    ) -> some SwiftUI.View {
        InfiniteNavContainer<Root, View, Environment>(
            initialStack: initialStack,
            navAction: navAction,
            environment: environment,
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
        InfiniteNavContainer<Root, View, EmptyEnvironment>(
            initialStack: initialStack,
            navAction: navAction,
            environment: EmptyEnvironment(),
            viewBuilder: viewBuilder,
            root: root
        )
        .ignoresSafeArea()
    }
}
