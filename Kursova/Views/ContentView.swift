import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            GameListView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            MyCollectionView()
                .tabItem {
                    Label("Collection", systemImage: "star.fill")
                }
        }
        .accentColor(AppTheme.accent)
        .background(AppTheme.background)
    }
}
