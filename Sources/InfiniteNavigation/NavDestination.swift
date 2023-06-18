import Foundation

public enum SheetPresentationStlye {
    case fullScreen
    case modal
}

public enum NavDestination<T> {
    case detail(T)
    case sheet(T, style: SheetPresentationStlye)
}
