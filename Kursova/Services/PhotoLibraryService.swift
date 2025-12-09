import UIKit
import Photos

class PhotoLibraryService {
    static let shared = PhotoLibraryService()
    private init() {}
    
    func saveImage(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }) { success, error in
                        DispatchQueue.main.async {
                            if success { completion(.success(())) }
                            else { completion(.failure(error ?? NSError(domain: "save", code: -1))) }
                        }
                    }
                    
                case .denied, .restricted:
                    let err = NSError(
                        domain: "PhotoLibrary",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "access_denied"]
                    )
                    completion(.failure(err))
                    
                default:
                    break
                }
            }
        }
    }
    
    func downloadAndSaveImage(from urlString: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard
            let str = urlString,
            let url = URL(string: str.replacingOccurrences(of: "http://", with: "https://"))
        else {
            return completion(.failure(NSError(domain: "PhotoLibrary", code: -2)))
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error { return completion(.failure(error)) }
                
                guard let data = data, let image = UIImage(data: data) else {
                    return completion(.failure(NSError(domain: "PhotoLibrary", code: -3)))
                }
                
                self.saveImage(image, completion: completion)
            }
        }.resume()
    }
}
