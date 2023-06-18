import SwiftUI
import Combine

@available(iOS 16.0, *)
internal struct Sheet: Identifiable {
    let id = UUID().uuidString
    var path = NavigationPath()
    let style: SheetPresentationStlye
    let source: () -> AnyView
}

@available(iOS 16.0, *)
internal struct RootContainer<T: View> {
    var path: NavigationPath
    let source: () -> T
}

public typealias Environments = [any ObservableObject]

@available(iOS 16.0, *)
public struct InfiniteNavContainer<Destination: Hashable, Root: View>: View {

    public typealias NavDestinationPublisher = AnyPublisher<NavAction<Destination>, Never>
    public typealias NavDestinationBuilder = (Destination) -> AnyView
    
    private let navAction: NavDestinationPublisher
    private let viewBuilder: NavDestinationBuilder
    private let environments: Environments
    
    @State private var stack = [Sheet]()
    @State private var root: RootContainer<Root>
    
    init(
        initialStack: [Destination] = [],
        navAction: NavDestinationPublisher,
        environments: Environments = [],
        viewBuilder: @escaping NavDestinationBuilder,
        root: @escaping () -> Root
    ) {
        _root = .init(initialValue: .init(path: NavigationPath(initialStack), source: root))
        
        self.navAction = navAction
        self.viewBuilder = viewBuilder
        self.environments = environments
    }
    
    public var body: some View {
        render(root: $root)
            .onReceive(navAction.receiveOnMain()) {
                switch $0 {
                case .show(let action):
                    switch action {
                    case .sheet(let destination, let style): stack.append(.init(style: style) { viewBuilder(destination) })
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
    
    private func render(root: Binding<RootContainer<Root>>) -> some View {
        render(source: root.wrappedValue.source, path: root.path, id: nil)
    }
    
    private func render(sheet: Binding<Sheet>) -> AnyView {
        render(source: sheet.wrappedValue.source, path: sheet.path, id: sheet.wrappedValue.id)
            .toAnyView()
    }
    
    private func render(source: () -> some View, path: Binding<NavigationPath>, id: String?) -> some View {
        let nextSheetBinding = Binding<Sheet?>(
            get: { nextSheet(after: id) },
            set: {
                if $0 == nil && stack.last?.id == nextSheet(after: id)?.id {
                    dismiss()
                }
            }
        )
        
        let updatableSheet: (Sheet) -> Binding<Sheet> = { sheet in
            .init(
                get: { sheet },
                set: { if $0.id == sheet.id { update(sheet: $0) } }
            )
        }
        
        return NavigationStack(path: path) {
            let content = wrap(source())
                .navigationDestination(for: Destination.self) { wrap(viewBuilder($0)) }
            
            if let style = nextSheet(after: id)?.style {
                switch style {
                case .fullScreen:
                    content.fullScreenCover(item: nextSheetBinding) { render(sheet: updatableSheet($0)) }.id(id)
                case .modal:
                    content.sheet(item: nextSheetBinding) { render(sheet: updatableSheet($0)) }.id(id)
                }
            } else {
                content.id(id)
            }
        }
    }
    
    private func wrap(_ view: some View) -> some View {
        view
            .apply(environments: environments)
            .navigationBarHidden(true)
    }
    
    private func mutateCurrentPath(_ mutate: (inout NavigationPath) -> Void) {
        if stack.isEmpty {
            mutate(&root.path)
        } else {
            mutate(&stack[stack.count - 1].path)
        }
    }
    
    private func update(sheet: Sheet) {
        guard let index = stack.firstIndex(where: { $0.id == sheet.id }) else {
            return
        }
        stack[index] = sheet
    }
    
    private func nextSheet(after id: String? = nil) -> Sheet? {
        guard let id = id else { return stack.first }
        guard let index = stack.firstIndex(where: { $0.id == id }) else { return nil }
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
