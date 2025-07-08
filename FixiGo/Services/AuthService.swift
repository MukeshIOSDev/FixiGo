import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAuthStateListener()
    }
    
    // MARK: - Authentication State Management
    private func setupAuthStateListener() {
        auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let firebaseUser = user {
                    self?.fetchUserData(userId: firebaseUser.uid)
                } else {
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            }
        }
    }
    
    // MARK: - Sign Up
    @MainActor
    func signUp(userData: UserSignupData) async throws {
        isLoading = true
        errorMessage = nil

        do {
            // Create Firebase Auth user
            let authResult = try await auth.createUser(withEmail: userData.email, password: userData.password)

            // Create user document in Firestore
            let user = User(
                id: authResult.user.uid,
                name: userData.name,
                email: userData.email,
                phone: userData.phone,
                address: userData.address,
                userType: userData.userType,
                createdAt: Date()
            )

            try await saveUserToFirestore(user)

            self.currentUser = user
            self.isAuthenticated = true
            self.isLoading = false

        } catch {
            print("SignUp Error: \(error)")
            let nsError = error as NSError
            print("Code: \(nsError.code), Domain: \(nsError.domain), Description: \(nsError.localizedDescription)")
            
            self.errorMessage = nsError.localizedDescription
            self.isLoading = false
            throw error
        }
    }
    
    // MARK: - Sign In
    @MainActor
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil

        do {
            let authResult = try await auth.signIn(withEmail: email, password: password)
            // User data will be fetched by the auth state listener
           
            self.isAuthenticated = true
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            throw error
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try auth.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Password Reset
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await auth.sendPasswordReset(withEmail: email)
            DispatchQueue.main.async {
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - User Data Management
    private func fetchUserData(userId: String) {
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            DispatchQueue.main.async {
                if let document = document, document.exists {
                    do {
                        let user = try document.data(as: User.self)
                        self?.currentUser = user
                        self?.isAuthenticated = true
                        print("User data fetched, navigation should occur.")
                    } catch {
                        self?.errorMessage = "Failed to parse user data: \(error.localizedDescription)"
                        print("Parse error: \(error)")
                    }
                } else {
                    self?.errorMessage = "User document not found"
                    print("User document not found for id: \(userId)")
                }
            }
        }
    }
    
    private func saveUserToFirestore(_ user: User) async throws {
        try await db.collection("users").document(user.id).setData(from: user)
    }
    
    func updateUserProfile(_ user: User) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await saveUserToFirestore(user)
            DispatchQueue.main.async {
                self.currentUser = user
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            throw error
        }
    }
    
    // MARK: - User Verification
    func sendEmailVerification() async throws {
        guard let currentUser = auth.currentUser else {
            throw AuthError.userNotFound
        }
        
        try await currentUser.sendEmailVerification()
    }
    
    func reloadUser() async throws {
        guard let currentUser = auth.currentUser else {
            throw AuthError.userNotFound
        }
        
        try await currentUser.reload()
    }
}

// MARK: - Custom Errors
enum AuthError: LocalizedError {
    case userNotFound
    case invalidCredentials
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Network error. Please check your connection"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 
