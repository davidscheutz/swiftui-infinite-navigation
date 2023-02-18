import SwiftUI

struct NavFooterView: View {
    
    typealias Completion = () -> Void
    
    let showSheet: Completion
    let showDetail: Completion
    var popDetails: Completion?
    
    var body: some View {
        HStack {
            Button("Show Detail", action: showDetail)
            if let popDetails = popDetails {
                Button("Pop Details", action: popDetails)
            }
            Button("Show Sheet", action: showSheet)
        }
        .buttonStyle(.bordered)
    }
}

#if DEBUG
struct NavFooterView_Previews: PreviewProvider {
    static var previews: some View {
        NavFooterView(showSheet: {}, showDetail: {})
        NavFooterView(showSheet: {}, showDetail: {}, popDetails: {})
    }
}
#endif
