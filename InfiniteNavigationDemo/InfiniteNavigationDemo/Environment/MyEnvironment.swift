import Foundation
import SwiftUI

final class MyEnvironment: ObservableObject {
    @Published var appSessionDuration = "0"
    
    private var start: Date
    private var timer: Timer?
    
    init() {
        start = .now
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            DispatchQueue.main.async {
                let elapsed = Date().timeIntervalSince1970 - self.start.timeIntervalSince1970
                self.appSessionDuration = formatter.string(from: elapsed) ?? "-"
            }
        }
    }
}
