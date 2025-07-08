import Foundation

// Add app-wide enums here 

// User Types for the app
enum UserType: String, CaseIterable, Codable {
    case customer = "Customer"
    case worker = "Worker"
    
    var icon: String {
        switch self {
        case .customer:
            return "person.fill"
        case .worker:
            return "wrench.and.screwdriver.fill"
        }
    }
    
    var description: String {
        switch self {
        case .customer:
            return "I need services"
        case .worker:
            return "I provide services"
        }
    }
}

// Service Types for workers
enum ServiceType: String, CaseIterable, Codable {
    case plumber = "Plumber"
    case electrician = "Electrician"
    case carpenter = "Carpenter"
    case painter = "Painter"
    case cleaner = "Cleaner"
    case mechanic = "Mechanic"
    case gardener = "Gardener"
    case mason = "Mason"
    case laborer = "Laborer"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .plumber:
            return "drop.fill"
        case .electrician:
            return "bolt.fill"
        case .carpenter:
            return "hammer.fill"
        case .painter:
            return "paintbrush.fill"
        case .cleaner:
            return "sparkles"
        case .mechanic:
            return "wrench.fill"
        case .gardener:
            return "leaf.fill"
        case .mason:
            return "building.2.fill"
        case .laborer:
            return "person.fill"
        case .other:
            return "ellipsis.circle.fill"
        }
    }
} 