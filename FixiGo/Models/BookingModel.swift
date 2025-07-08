import Foundation

struct Booking: Identifiable, Codable {
    let id: String
    let customerId: String
    let workerId: String
    let serviceType: ServiceType
    let date: Date
    let time: Date
    let description: String
    let address: String
    var status: BookingStatus
    let estimatedCost: ClosedRange<Double>
    let createdAt: Date
    var actualCost: Double?
    var completedAt: Date?
    var rating: Double?
    var review: String?
}

enum BookingStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case inProgress = "In Progress"
    case completed = "Completed"
    case cancelled = "Cancelled"
    
    var color: String {
        switch self {
        case .pending:
            return "orange"
        case .confirmed:
            return "blue"
        case .inProgress:
            return "purple"
        case .completed:
            return "green"
        case .cancelled:
            return "red"
        }
    }
    
    var icon: String {
        switch self {
        case .pending:
            return "clock"
        case .confirmed:
            return "checkmark.circle"
        case .inProgress:
            return "wrench.and.screwdriver"
        case .completed:
            return "checkmark.circle.fill"
        case .cancelled:
            return "xmark.circle"
        }
    }
} 