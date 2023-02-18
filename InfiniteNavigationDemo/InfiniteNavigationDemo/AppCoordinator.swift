import SwiftUI
import Combine
import InfiniteNavigation

final class AppCoordinator: ObservableObject {
    
    let navigation = MyNavigation()
    
    var home: some View {
        HomeView(navigation: navigation)
    }
    
    func build(for destination: MyDestination) -> AnyView {
        switch destination {
        case .detail:
            return DetailView(navigation: navigation).toAnyView()
        case .sheet:
            return SheetView(navigation: navigation).toAnyView()
        }
    }
}
