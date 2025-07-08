import Foundation
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var totalBookings: Int = 0
    @Published var completedBookings: Int = 0
    @Published var pendingBookings: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isEditing = false
    @Published var editedName = ""
    @Published var editedEmail = ""
    @Published var editedPhone = ""
    @Published var editedAddress = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let firestoreService: FirestoreService
    
    init() {
        self.firestoreService = FirestoreService()
        loadUserProfile()
        loadUserStats()
    }
    
    // MARK: - Public Methods
    func loadUserProfile() {
        isLoading = true
        errorMessage = nil
        
        // For now, we'll use mock data
        // In production, this would fetch from Firestore
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.user = self.generateMockUser()
            self.isLoading = false
        }
    }
    
    func loadUserStats() {
        // Load user statistics
        // In production, this would fetch from Firestore
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.totalBookings = 12
            self.completedBookings = 8
            self.pendingBookings = 4
        }
    }
    
    func updateProfile(name: String, email: String, phone: String, address: String) {
        isLoading = true
        errorMessage = nil
        
        // In production, this would update in Firestore
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.user?.name = name
            self.user?.email = email
            self.user?.phone = phone
            self.user?.address = address
            self.isLoading = false
        }
    }
    
    // MARK: - Private Methods
    private func generateMockUser() -> User {
        return User(
            id: "currentUser",
            name: "John Doe",
            email: "john.doe@example.com",
            phone: "+91 98765 43210",
            address: "Mumbai, Maharashtra",
            userType: .customer,
            createdAt: Date()
        )
    }
} 