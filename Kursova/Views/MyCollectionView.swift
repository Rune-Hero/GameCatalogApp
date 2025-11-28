import SwiftUI

struct MyCollectionView: View {
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
                
                // Кнопка (опціонально)
                Button(action: {
                    // TODO: Перемкнутись на вкладку Home
                    print("Browse Games tapped")
                }) {
                    Text("Browse Games")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .navigationTitle("My Collection")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // TODO: Пошук в колекції
                        print("Search in collection")
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18))
                    }
                }
            }
        }
    }
}

#Preview {
    MyCollectionView()
}
