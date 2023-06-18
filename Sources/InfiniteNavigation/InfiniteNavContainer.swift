import SwiftUI
import Combine

@available(iOS 16.0, *)
internal struct Sheet: Identifiable {
    let id = UUID().uuidString
    var path = NavigationPath()
    let source: () -> AnyView
}

public typealias Environments = [any ObservableObject]

@available(iOS 16.0, *)
public struct InfiniteNavContainer<Destination: Hashable, Root: View>: View {

    public typealias NavDestinationPublisher = AnyPublisher<NavAction<Destination>, Never>
    public typealias NavDestinationBuilder = (Destination) -> AnyView
    
    private let navAction: NavDestinationPublisher
    private let viewBuilder: NavDestinationBuilder
    private let environments: Environments
    
    @State private var stack: [Sheet]
    
    init(
        initialStack: [Destination] = [],
        navAction: NavDestinationPublisher,
        environments: Environments = [],
        viewBuilder: @escaping NavDestinationBuilder,
        root: @escaping () -> Root
    ) {
        _stack = .init(initialValue: [
            .init(path: NavigationPath(initialStack), source: { root().toAnyView() })
        ])
        
        self.navAction = navAction
        self.viewBuilder = viewBuilder
        self.environments = environments
    }
    
    public var body: some View {
        root
            .onReceive(navAction.receiveOnMain()) {
                switch $0 {
                case .show(let action):
                    switch action {
                    case .sheet(let destination): stack.append(.init { viewBuilder(destination) })
                    case .detail(let destination): mutateCurrentPath { $0.append(destination) }
                    }
                case .setStack(let destinations): mutateCurrentPath { $0.append(contentsOf: destinations) }
                case .dismiss: dismiss()
                case .pop: mutateCurrentPath { $0.removeLastSafely() }
                case .popToCurrentRoot: mutateCurrentPath { $0.removeAll() }
                }
            }
    }
}

@available(iOS 16.0, *)
extension InfiniteNavContainer {
    
    private var root: some View {
        guard let root = $stack.first else {
            fatalError("Root view unexpectedly missing.")
        }
        return render(sheet: root)
    }
    
    private func render(sheet: Binding<Sheet>) -> AnyView {
        NavigationStack(path: sheet.path) {
            wrap(sheet.wrappedValue.source())
                .navigationDestination(for: Destination.self) { wrap(viewBuilder($0)) }
                .fullScreenCover(item: Binding<Sheet?>(
                    get: { next(after: sheet.wrappedValue) },
                    set: { if $0 == nil && stack.last?.id == next(after: sheet.wrappedValue)?.id { dismiss() } }
                )) { sheet in
                    render(sheet: .init(
                        get: { sheet },
                        set: { if $0.id == sheet.id { update(sheet: $0) } }
                    ))
                }
        }
        .toAnyView()
    }
    
    private func wrap(_ view: some View) -> some View {
        view
            .apply(environments: environments)
            .navigationBarHidden(true)
    }
    
    private func mutateCurrentPath(_ mutate: (inout NavigationPath) -> Void) {
        mutate(&stack[stack.count - 1].path)
    }
    
    private func update(sheet: Sheet) {
        guard let index = stack.firstIndex(where: { $0.id == sheet.id }) else {
            return
        }
        stack[index] = sheet
    }
    
    private func next(after sheet: Sheet) -> Sheet? {
        guard let index = stack.firstIndex(where: { $0.id == sheet.id }) else { return nil }
        return stack[safe: index + 1]
    }
    
    private func dismiss() {
        stack.removeLastSafely()
    }
}

// enable swipe back gesture when navigation bar is hidden
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
