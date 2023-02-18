import Foundation

public enum NavAction<T> {
    case show(NavDestination<T>)
    case setStack([T])
    case dismiss
    case pop
    case popToCurrentRoot
}
