import SwiftUI
import InfiniteNavigation

struct NavFooterView: View {
    
    typealias Completion = () -> Void
    
    let showSheet: (SheetPresentationStlye) -> Void
    let showDetail: Completion
    var popDetails: Completion?
    
    var body: some View {
        VStack {
            HStack {
                Button("Show Detail", action: showDetail)
                if let popDetails = popDetails {
                    Button("Pop Details", action: popDetails)
                }
            }
            
            HStack {
                Button("Show Full Sheet") { showSheet(.fullScreen) }
                Button("Show Modal Sheet") { showSheet(.modal) }
            }
        }
        .buttonStyle(.bordered)
    }
}

#if DEBUG
struct NavFooterView_Previews: PreviewProvider {
    static var previews: some View {
        NavFooterView(showSheet: { _ in }, showDetail: {})
        NavFooterView(showSheet: { _ in }, showDetail: {}, popDetails: {})
    }
}
#endif
