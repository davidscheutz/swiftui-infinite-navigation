import Foundation

extension Collection {
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension Array {
    mutating func removeLastSafely() {
        guard !isEmpty else { return }
        removeLast()
    }
}
