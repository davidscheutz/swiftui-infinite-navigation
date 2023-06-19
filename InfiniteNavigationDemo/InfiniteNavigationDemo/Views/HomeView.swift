import SwiftUI
import InfiniteNavigation

protocol HomeNavigation {
    func showSheet(style: SheetPresentationStlye)
    func showDetail()
}

struct HomeView: View {
    
    let navigation: HomeNavigation
    
    var body: some View {
        VStack {
            Spacer()
            Text("Home")
                .font(.title)
            
            AppSessionView()
            Spacer()
            
            NavFooterView(
                showSheet: navigation.showSheet,
                showDetail: navigation.showDetail
            )
        }
        .padding()
    }
}

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(navigation: MyNavigation())
            .environmentObject(MyEnvironment())
    }
}
#endif
