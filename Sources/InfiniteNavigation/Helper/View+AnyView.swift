import SwiftUI

extension View {
    public func toAnyView() -> AnyView {
        .init(self)
    }
}
