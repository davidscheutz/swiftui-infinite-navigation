import SwiftUI

extension View {
    func apply(environments: [Environment]) -> AnyView {
        var result: any View = self
        environments.forEach { result = (result.environmentObject($0) as any View) }
        return result.toAnyView()
    }
}
