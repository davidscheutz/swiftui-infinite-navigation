import SwiftUI

protocol SheetNavigation: HomeNavigation {
    func close()
}

struct SheetView: View {
    
    let navigation: SheetNavigation
    
    var body: some View {
        VStack {
            HStack {
                Button(action: navigation.close) {
                    Image(systemName: "chevron.down")
                    Text("Close")
                }
                .buttonStyle(.plain)
                Spacer()
            }
            
            Spacer()
            Text("Sheet")
            AppSessionView()
            Spacer()
            
            NavFooterView(
                showSheet: navigation.showSheet,
                showDetail: navigation.showDetail
            )
        }
        .padding()
        .background(Color.yellow.opacity(0.5))
    }
}

#if DEBUG
struct SheetView_Previews: PreviewProvider {
    static var previews: some View {
        SheetView(navigation: MyNavigation())
    }
}
#endif
