import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Вкладка 1: Головна (список ігор)
            GameListView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Вкладка 2: Моя колекція
            MyCollectionView()
                .tabItem {
                    Label("Collection", systemImage: "star.fill")
                }
        }
        .accentColor(.blue) // Колір активної вкладки
    }
}
