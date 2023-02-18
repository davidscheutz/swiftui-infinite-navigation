import Foundation
import Combine
import InfiniteNavigation

final class MyNavigation: HomeNavigation, SheetNavigation, DetailNavigation {
    
    private(set) lazy var publisher = navigateTo.eraseToAnyPublisher()
    
    private let navigateTo = PassthroughSubject<NavAction<MyDestination>, Never>()

    // MARK: - HomeNavigation
    
    func showSheet() {
        navigateTo.send(.show(.sheet(.sheet)))
    }
    
    func showDetail() {
        navigateTo.send(.show(.detail(.detail)))
    }
    
    // MARK: - SheetViewNavigation
    
    func close() {
        navigateTo.send(.dismiss)
    }
    
    // MARK: - DetailViewNavigation
    
    func back() {
        navigateTo.send(.pop)
    }
    
    func popDetails() {
        navigateTo.send(.popToCurrentRoot)
    }
}
