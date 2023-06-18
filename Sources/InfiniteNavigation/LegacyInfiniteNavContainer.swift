import Combine
import SwiftUI
import UIKit

public struct LegacyInfiniteNavContainer<Root: SwiftUI.View, View>: UIViewControllerRepresentable {
    
    public typealias UIViewControllerType = UINavigationController
    public typealias NavDestinationPublisher = AnyPublisher<NavAction<View>, Never>
    public typealias NavDestinationBuilder = (View) -> AnyView
    
    private let coordinator: Coordinator
    private let rootResolver: () -> Root
    private let root: Root
    private let initialStack: [View]
    private let viewBuilder: NavDestinationBuilder
    
    internal init(
        initialStack: [View] = [],
        navAction: NavDestinationPublisher,
        environments: [any ObservableObject] = [],
        viewBuilder: @escaping NavDestinationBuilder,
        root: @escaping () -> Root
    ) {
        self.initialStack = initialStack
        self.rootResolver = root
        self.root = root()
        self.viewBuilder = viewBuilder
        coordinator = .init(navAction: navAction, environments: environments, viewBuilder: viewBuilder)
    }
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        let vc = UIViewControllerType()
        context.coordinator.resolver = { vc }
        vc.navigationBar.isHidden = true
        vc.viewControllers = [context.coordinator.wrap(root)] + initialStack.map { context.coordinator.wrap(viewBuilder($0)) }
        return vc
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // TODO: figure out if it's still needed...
    }
    
    public func makeCoordinator() -> Coordinator {
        coordinator
    }
    
    public final class Coordinator: NSObject {
        
        typealias Resolver = () -> UINavigationController
        
        var resolver: Resolver?
        
        private let environments: [any ObservableObject]
        private let viewBuilder: NavDestinationBuilder
        private var navSubscription: AnyCancellable?
        
        init(navAction: NavDestinationPublisher, environments: [any ObservableObject], viewBuilder: @escaping NavDestinationBuilder) {
            self.environments = environments
            self.viewBuilder = viewBuilder
            
            super.init()
            
            navSubscription = subscribe(to: navAction)
        }
        
        func wrap<T: SwiftUI.View>(_ view: T) -> UIHostingController<AnyView> {
            UIHostingController(rootView: view.apply(environments: environments))
        }
        
        // MARK: Helper
        
        private func subscribe(to navAction: NavDestinationPublisher) -> AnyCancellable {
            navAction
                .receiveOnMain()
                .sink { [weak self] navAction in
                    guard let self = self else { return }
                    switch navAction {
                    case .show(let destination):
                        switch destination {
                        case .detail(let detail):
                            let vc = self.wrap(self.viewBuilder(detail))
                            self.navigationController?.pushViewController(vc, animated: true)
                        case .sheet(let sheet):
                            let vc = self.wrap(self.viewBuilder(sheet))
                            let navVc = UINavigationController(rootViewController: vc)
                            navVc.navigationBar.isHidden = true
                            navVc.modalPresentationStyle = .fullScreen
                            self.navigationController?.present(navVc, animated: true)
                        }
                    case .setStack(let stack):
                        let vcs = stack.map { self.wrap(self.viewBuilder($0)) }
                        self.navigationController?.setViewControllers(vcs, animated: true)
                    case .dismiss:
                        if let currentSheet = self.currentSheet {
                            currentSheet.dismiss(animated: true)
                        } else {
                            print("⚠️ No sheet exists to dismiss.")
                        }
                    case .pop:
                        // avoid the app from crashing
                        if self.navigationController?.viewControllers.isEmpty == false {
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            print("⚠️ No detail exists to pop.")
                        }
                    case .popToCurrentRoot:
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
        }
        
        private var currentSheet: UIViewController? {
            var sheet = resolver?().presentedViewController
            
            while sheet?.presentedViewController != nil {
                sheet = sheet?.presentedViewController
            }
            
            return sheet
        }
        
        private var navigationController: UINavigationController? {
            currentSheet as? UINavigationController ?? resolver?()
        }
    }
}

extension LegacyInfiniteNavContainer {
    func barTint(color: Color) -> some SwiftUI.View {
        if #available(iOS 15.0, *) {
            return tint(color).toAnyView()
        } else {
            // TODO: Fallback on earlier versions
            return EmptyView().toAnyView()
        }
    }
}
