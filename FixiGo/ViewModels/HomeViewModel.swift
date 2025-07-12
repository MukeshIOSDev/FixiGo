import Foundation
import Combine
import CoreLocation
import MapKit

@MainActor
class HomeViewModel: ObservableObject, Sendable {
    @Published var workers: [Worker] = []
    @Published var filteredWorkers: [Worker] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""
    @Published var selectedServiceType: ServiceType?
    @Published var currentLocation: CLLocation?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629), // India center
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    private let firestoreService = FirestoreService()
    private let locationService = LocationService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
        requestLocationPermission()
    }
    
    private func setupBindings() {
        // Bind search text changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filterWorkers(by: nil)
            }
            .store(in: &cancellables)
        
        // Bind service type changes
        $selectedServiceType
            .sink { [weak self] _ in
                self?.filterWorkers(by: nil)
            }
            .store(in: &cancellables)
        
        locationService.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] location in
                self?.currentLocation = location
                self?.updateRegion(with: location)
                self?.fetchNearbyWorkers()
            }
            .store(in: &cancellables)
        
        locationService.$errorMessage
            .compactMap { $0 }
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Worker Management
    func fetchNearbyWorkers() {
        guard currentLocation != nil else {
            locationService.requestLocation()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let nearbyWorkers = try await firestoreService.searchWorkers(
                    query: searchText,
                    serviceType: selectedServiceType
                )
                
                await MainActor.run {
                    self.workers = nearbyWorkers
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func searchWorkers() {
        fetchNearbyWorkers()
    }
    
    func filterWorkers(by serviceType: ServiceType?) {
        if let services = serviceType {
            selectedServiceType = services
        }
        fetchNearbyWorkers()
    }
    
    func clearFilters() {
        selectedServiceType = nil
        searchText = ""
        fetchNearbyWorkers()
    }
    
    // MARK: - Worker Details
    func getWorkerDetails(for workerId: String) async -> Worker? {
        // For now, we'll search for the worker in the current list
        // In production, you would have a dedicated fetchWorker method
        return workers.first { $0.id == workerId }
    }
    
    // MARK: - Booking Management
    func createBooking(for worker: Worker, date: Date, description: String) async -> Booking? {
        guard let currentUser = getCurrentUser() else {
            errorMessage = "User not authenticated"
            return nil
        }
        
        do {
            let booking = Booking(
                id: UUID().uuidString,
                customerId: currentUser.id,
                workerId: worker.id,
                serviceType: worker.services.first ?? .other,
                date: date,
                time: date,
                description: description,
                address: currentUser.address,
                status: .pending,
                estimatedCost: 0.0...0.0, // This would be calculated based on service type and duration
                createdAt: Date()
            )
            
            try await firestoreService.createBooking(booking)
            return booking
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    // MARK: - Location Management
    private func updateRegion(with location: CLLocation) {
        region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    private func requestLocationPermission() {
        locationService.requestLocationPermission()
    }
    
    // MARK: - Map Annotations
    func createMapAnnotations() -> [WorkerAnnotation] {
        return workers.map { worker in
            WorkerAnnotation(
                coordinate: worker.coordinate,
                title: worker.name,
                subtitle: worker.services.map { $0.rawValue }.joined(separator: ", "),
                worker: worker
            )
        }
    }
    
    // MARK: - Service Type Management
    func selectServiceType(_ serviceType: ServiceType?) {
        selectedServiceType = serviceType
    }
    
    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Helper Methods
    private func getCurrentUser() -> User? {
        // This would typically come from AuthService
        // For now, return a mock user
        return User(
            id: "currentUser",
            name: "Current User",
            email: "user@example.com",
            phone: "+1234567890",
            address: "123 Main St",
            userType: .customer,
            createdAt: Date(), services: [.cleaner, .carpenter]
        )
    }
    
    // MARK: - Refresh
    func refreshData() {
        locationService.requestLocation()
    }
}

// MARK: - Supporting Types
class WorkerAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let worker: Worker
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, worker: Worker) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.worker = worker
        super.init()
    }
} 
