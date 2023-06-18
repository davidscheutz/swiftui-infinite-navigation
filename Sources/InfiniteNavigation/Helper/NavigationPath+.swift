import SwiftUI

@available(iOS 16.0, *)
extension NavigationPath {
    mutating func append<T: Hashable>(contentsOf paths: any Sequence<T>) {
        paths.forEach { append($0) }
    }
    
    mutating func removeLastSafely() {
        guard !isEmpty else { return }
        removeLast()
    }
    
    mutating func removeAll() {
        guard !isEmpty else { return }
        removeLast(count)
    }
}
