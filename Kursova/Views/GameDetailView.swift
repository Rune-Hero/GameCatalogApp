import SwiftUI

struct GameDetailView: View {
    let gameId: Int
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Тимчасовий контент
                Image(systemName: "gamecontroller.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                    .padding(.top, 50)
                
                Text("Game Details")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Game ID: \(gameId)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("(Детальний екран буде створений пізніше)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        GameDetailView(gameId: 3498)
    }
}
