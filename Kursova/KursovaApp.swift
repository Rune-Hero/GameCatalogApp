//
//  KursovaApp.swift
//  Kursova
//
//  Created by ІПЗ-31/1 on 14.11.2025.
//

import SwiftUI

@main
struct KursovaApp: App {
    
    // 1. Створюємо єдиний екземпляр LocalStorageService і зберігаємо його стан.
    // @StateObject забезпечує, що цей об'єкт існує протягом усього життєвого циклу App.
    @StateObject var localStorageService = LocalStorageService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // 2. Робимо об'єкт доступним для всіх дочірніх View
                // через механізм оточення SwiftUI (Environment).
                .environmentObject(localStorageService)
        }
    }
}
