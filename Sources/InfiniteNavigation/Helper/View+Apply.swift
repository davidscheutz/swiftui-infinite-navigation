import SwiftUI

extension View {
    @ViewBuilder
    func apply<T, Result: View>(_ value: T?, @ViewBuilder _ apply: (T, Self) -> Result) -> some View {
        if let value = value {
            apply(value, self)
        } else {
            self
        }
    }
}
