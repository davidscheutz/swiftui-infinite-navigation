import SwiftUI
import Combine

@available(iOS 16.0, *)
// TODO: add option to configure navigation bar title
internal struct Sheet: Identifiable {
    let id = UUID().uuidString
    var path = NavigationPath()
    let source: () -> AnyView
}

@available(iOS 16.0, *)
public struct InfiniteNavContainer<Destination: Hashable, Root: View>: View {

    public typealias NavDestinationPublisher = AnyPublisher<NavAction<Destination>, Never>
    public typealias NavDestinationBuilder = (Destination) -> AnyView
    
    private let navAction: NavDestinationPublisher
    private let viewBuilder: NavDestinationBuilder
    private let environments: [any ObservableObject]
    
    @State private var stack: [Sheet]
    
    init(
        initialStack: [Destination] = [],
        navAction: NavDestinationPublisher,
        environments: [any ObservableObject] = [],
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
        ZStack {
            if let root = $stack.first {
                render(sheet: root)
            }
        }
        .onReceive(navAction.receiveOnMain()) {
            // TODO: figure out 'stack[stack.count - 1].path'
            switch $0 {
            case .show(let action):
                switch action {
                case .sheet(let destination): stack.append(.init(source: { viewBuilder(destination) }))
                case .detail(let destination): stack[stack.count - 1].path.append(destination)
                }
            case .setStack(let destinations): destinations.forEach { stack[stack.count - 1].path.append($0) }
            case .dismiss: dismiss()
            case .pop: stack[stack.count - 1].path.removeLast() // TODO: safely
            case .popToCurrentRoot: stack[stack.count - 1].path.removeLast(stack[stack.count - 1].path.count) // TODO: convenient removeAll()
            }
        }
    }
}

@available(iOS 16.0, *)
extension InfiniteNavContainer {
    
    private func render(sheet: Binding<Sheet>) -> AnyView {
        NavigationStack(path: sheet.path) {
            wrap(sheet.wrappedValue.source())
                .navigationDestination(for: Destination.self) { wrap(viewBuilder($0)) }
//                .sheet(item: <#T##Binding<Identifiable?>#>, content: <#T##(Identifiable) -> View#>)
                .fullScreenCover(item: Binding<Sheet?>(
                    get: { next(after: sheet.wrappedValue) },
                    set: { if $0 == nil && stack.last?.id == next(after: sheet.wrappedValue)?.id { dismiss() } }
                )) { sheet in
                    render(sheet: .init(
                        get: { sheet },
                        set: { newValue in
                            guard newValue.id == sheet.id,
                                  let index = stack.firstIndex(where: { $0.id == sheet.id }) else {
                                return
                            }
                            stack[index] = newValue
                        }
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
    
    private func next(after sheet: Sheet) -> Sheet? {
        guard let index = stack.firstIndex(where: { $0.id == sheet.id }) else { return nil }
        return stack[safe: index + 1]
    }
    
    private func dismiss() {
        stack.removeLast() // TODO: safely
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}

// MARK: - Helper

extension View {
    func apply(environments: [any ObservableObject]) -> AnyView {
        var result: any SwiftUI.View = self
        environments.forEach { result = (result.environmentObject($0) as any SwiftUI.View) }
        return result.toAnyView()
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
