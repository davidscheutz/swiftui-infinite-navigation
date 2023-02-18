import SwiftUI
import InfiniteNavigation

struct ContentView: View {
    
    @StateObject private var coordinator = AppCoordinator()
    
    var body: some View {
        InfiniteNavigation.create(
            navAction: coordinator.navigation.publisher,
            environment: coordinator.environment,
            viewBuilder: coordinator.build(for:)
        ) {
            coordinator.home
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
