import SwiftUI

struct MyCollectionView: View {
    @State private var showSearch = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                // Іконка
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.gray)
                
                // Заголовок
                Text("Your collection is empty")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                // Підказка
                Text("Add games from the catalog to see them here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
            .navigationTitle("My Collection")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18))
                    }
                }
            }
            .sheet(isPresented: $showSearch) {
                SearchView()
            }
        }
    }
}
