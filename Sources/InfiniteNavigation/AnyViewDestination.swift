import SwiftUI

public struct AnyViewDestination: Hashable {
    public static func == (lhs: AnyViewDestination, rhs: AnyViewDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id: AnyHashable
    public let value: AnyView
    
    init<Destination: NavDestinable>(id: AnyHashable = UUID().uuidString, destination: Destination) {
        self.id = id
        self.value = destination.toAnyView()
    }
    
    public init(id: AnyHashable = UUID().uuidString, value: some View) {
        self.id = id
        self.value = value.toAnyView()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
