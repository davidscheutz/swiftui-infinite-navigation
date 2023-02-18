import SwiftUI

protocol DetailNavigation: HomeNavigation {
    func back()
    func popDetails()
}

struct DetailView: View {
    
    let navigation: DetailNavigation
    
    var body: some View {
        VStack {
            HStack {
                Button(action: navigation.back) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .buttonStyle(.plain)
                Spacer()
            }
            
            Spacer()
            Text("Detail")
                .font(.title)
            AppSessionView()
            Spacer()
            
            NavFooterView(
                showSheet: navigation.showSheet,
                showDetail: navigation.showDetail,
                popDetails: navigation.popDetails
            )
        }
        .padding()
        .background(Color.green.opacity(0.5))
    }
}

#if DEBUG
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(navigation: MyNavigation())
            .environmentObject(MyEnvironment())
    }
}
#endif
