import Foundation

public enum NavDestination<T> {
    case detail(T)
    case sheet(T)
}
