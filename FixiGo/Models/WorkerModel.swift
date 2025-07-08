import Foundation
import CoreLocation

struct Worker: Identifiable {
    let id: String
    let name: String
    let email: String
    let phone: String
    let address: String
    let services: [ServiceType]
    let rating: Double
    let totalJobs: Int
    let isVerified: Bool
    let createdAt: Date
    
    // Computed property for coordinate (mock data for now)
    var coordinate: CLLocationCoordinate2D {
        // Mock coordinates for different areas in Mumbai
        let coordinates: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 19.1197, longitude: 72.8464), // Andheri
            CLLocationCoordinate2D(latitude: 19.0596, longitude: 72.8295), // Bandra
            CLLocationCoordinate2D(latitude: 19.0996, longitude: 72.8344), // Juhu
            CLLocationCoordinate2D(latitude: 19.1197, longitude: 72.9089), // Powai
            CLLocationCoordinate2D(latitude: 19.0176, longitude: 72.8138)  // Worli
        ]
        
        let index = Int(id) ?? 0
        return coordinates[index % coordinates.count]
    }
} 