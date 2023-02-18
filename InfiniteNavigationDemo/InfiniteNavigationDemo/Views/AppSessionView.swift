import SwiftUI

struct AppSessionView: View {
    
    @EnvironmentObject private var env: MyEnvironment
    
    var body: some View {
        Text("Session duration: \(env.appSessionDuration)")
    }
}

#if DEBUG
struct AppSessionView_Previews: PreviewProvider {
    static var previews: some View {
        AppSessionView()
            .environmentObject(MyEnvironment())
    }
}
#endif
