import SwiftUI

@main
struct KursovaApp: App {
    
    @StateObject var localStorageService = LocalStorageService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(localStorageService)
                .preferredColorScheme(.dark)
        }
    }
}
