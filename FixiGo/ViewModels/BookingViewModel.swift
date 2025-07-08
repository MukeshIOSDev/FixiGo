import Foundation
import Combine

@MainActor
class BookingViewModel: ObservableObject {
    @Published var currentBooking: Booking?
    @Published var bookings: [Booking] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var selectedWorker: Worker?
    @Published var selectedServiceType: ServiceType = .plumber
    @Published var scheduledDate = Date()
    @Published var estimatedDuration: Int = 2
    @Published var description: String = ""
    @Published var totalAmount: Double = 0.0
    @Published var bookingCreated = false
    
    private var cancellables = Set<AnyCancellable>()
    private let firestoreService: FirestoreService
    
    init() {
        self.firestoreService = FirestoreService()
        loadBookings()
    }
    
    // MARK: - Public Methods
    func createBooking(
        workerId: String,
        serviceType: ServiceType,
        date: Date,
        time: Date,
        description: String,
        address: String
    ) {
        isLoading = true
        errorMessage = nil
        
        let booking = Booking(
            id: UUID().uuidString,
            customerId: "currentUser", // In production, get from AuthService
            workerId: workerId,
            serviceType: serviceType,
            date: date,
            time: time,
            description: description,
            address: address,
            status: .pending,
            estimatedCost: generateEstimatedCost(for: serviceType),
            createdAt: Date()
        )
        
        currentBooking = booking
        
        // In production, save to Firestore
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.bookings.append(booking)
            self.isLoading = false
        }
    }
    
    func updateBookingStatus(_ bookingId: String, status: BookingStatus) {
        if let index = bookings.firstIndex(where: { $0.id == bookingId }) {
            bookings[index].status = status
        }
        
        // In production, update in Firestore
    }
    
    func loadBookings() {
        isLoading = true
        errorMessage = nil
        
        // For now, we'll use mock data
        // In production, this would fetch from Firestore
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.bookings = self.generateMockBookings()
            self.isLoading = false
        }
    }
    
    // MARK: - Private Methods
    private func generateEstimatedCost(for serviceType: ServiceType) -> ClosedRange<Double> {
        switch serviceType {
        case .plumber:
            return 500...1500
        case .electrician:
            return 800...2000
        case .carpenter:
            return 600...1800
        case .painter:
            return 400...1200
        case .cleaner:
            return 300...800
        case .mechanic:
            return 700...2500
        case .gardener:
            return 400...1000
        case .mason:
            return 1000...3000
        case .laborer:
            return 500...1500
        case .other:
            return 500...2000
        }
    }
    
    private func generateMockBookings() -> [Booking] {
        return [
            Booking(
                id: "1",
                customerId: "currentUser",
                workerId: "worker1",
                serviceType: .plumber,
                date: Date().addingTimeInterval(86400), // Tomorrow
                time: Date(),
                description: "Fix leaking tap in kitchen",
                address: "123 Main Street, Mumbai",
                status: .confirmed,
                estimatedCost: 500...1500,
                createdAt: Date().addingTimeInterval(-3600)
            ),
            Booking(
                id: "2",
                customerId: "currentUser",
                workerId: "worker2",
                serviceType: .electrician,
                date: Date().addingTimeInterval(172800), // Day after tomorrow
                time: Date(),
                description: "Install new ceiling fan",
                address: "123 Main Street, Mumbai",
                status: .pending,
                estimatedCost: 800...2000,
                createdAt: Date().addingTimeInterval(-7200)
            ),
            Booking(
                id: "3",
                customerId: "currentUser",
                workerId: "worker3",
                serviceType: .cleaner,
                date: Date().addingTimeInterval(-86400), // Yesterday
                time: Date(),
                description: "Deep cleaning of apartment",
                address: "123 Main Street, Mumbai",
                status: .completed,
                estimatedCost: 300...800,
                createdAt: Date().addingTimeInterval(-172800)
            )
        ]
    }
} 