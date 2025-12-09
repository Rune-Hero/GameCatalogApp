import Foundation
import Combine
import Photos

@MainActor
class GameDetailViewModel: ObservableObject {
    @Published var gameDetails: GameDetails?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Стан колекції
    @Published var isInCollection: Bool = false
    
    // Стан збереження фото
    @Published var showSaveAlert = false
    @Published var saveAlertMessage = ""
    
    // Алерт для "Відкрити налаштування"
    @Published var showOpenSettingsAlert = false
    
    private let gameId: Int
    private var cancellables = Set<AnyCancellable>()
    
    init(gameId: Int) {
        self.gameId = gameId
    }
    
    // MARK: - Collection Tracking
    func setupCollectionTracking(with localStorageService: LocalStorageService) {
        self.isInCollection = localStorageService.isGameInCollection(gameId: self.gameId)
        
        localStorageService.$collection
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.isInCollection = localStorageService.isGameInCollection(gameId: self.gameId)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Fetch Game Details
    func fetchGameDetails() async {
        isLoading = true
        errorMessage = nil
        do {
            let details = try await NetworkService.shared.fetchGameDetails(id: gameId)
            self.gameDetails = details
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Toggle Collection Status
    func toggleCollectionStatus(in localStorageService: LocalStorageService) {
        guard let game = gameDetails else { return }
        localStorageService.toggleCollectionStatus(for: game)
        self.isInCollection = localStorageService.isGameInCollection(gameId: game.id)
    }
    
    // MARK: - Save Image to Gallery
    func saveImageToGallery() {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            performSaving()
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] newStatus in
                DispatchQueue.main.async {
                    switch newStatus {
                    case .authorized, .limited:
                        self?.performSaving()
                    case .denied, .restricted:
                        self?.saveAlertMessage = "Access denied. Please enable Photos access in Settings."
                        self?.showOpenSettingsAlert = true
                    default:
                        break
                    }
                }
            }
            
        case .denied, .restricted:
            saveAlertMessage = "Access to Photos is denied. You must enable it in Settings."
            showOpenSettingsAlert = true
            
        @unknown default:
            saveAlertMessage = "Unknown photo access status."
            showSaveAlert = true
        }
    }
    
    private func performSaving() {
        guard let url = gameDetails?.backgroundImage else {
            saveAlertMessage = "No image available."
            showSaveAlert = true
            return
        }
        
        PhotoLibraryService.shared.downloadAndSaveImage(from: url) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.saveAlertMessage = "Image saved to Photos!"
                    self?.showSaveAlert = true
                case .failure(let error):
                    self?.saveAlertMessage = "Failed to save: \(error.localizedDescription)"
                    self?.showSaveAlert = true
                }
            }
        }
    }
}
