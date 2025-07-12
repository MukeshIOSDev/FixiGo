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
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
    }
    deinit {
        if let handle = authStateListenerHandle {
            auth.removeStateDidChangeListener(handle)
        }
    }
    // MARK: - Authentication State Management
    private func setupAuthStateListener() {
        authStateListenerHandle = auth.addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }

            if let user = user {
                self.fetchUserData(userId: user.uid)
            } else {
                DispatchQueue.main.async {
                    self.currentUser = nil
                    self.isAuthenticated = false
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
                createdAt: Date(),
                services: userData.services // Pass services from signup data
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
            let nsError = error as NSError
            switch nsError.code {
            case AuthErrorCode.wrongPassword.rawValue:
                self.errorMessage = "Incorrect password. Please try again."
            case AuthErrorCode.invalidEmail.rawValue:
                self.errorMessage = "Invalid email address."
            case AuthErrorCode.userNotFound.rawValue:
                self.errorMessage = "No account found with this email."
            default:
                self.errorMessage = nsError.localizedDescription
            }
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
    @MainActor
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await auth.sendPasswordReset(withEmail: email)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
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
                    } catch {
                        self?.errorMessage = "Failed to parse user data: \(error.localizedDescription)"
                    }
                } else if let firebaseUser = self?.auth.currentUser {
                    // User document not found, create it from Firebase Auth user
                    let user = User(
                        id: firebaseUser.uid,
                        name: firebaseUser.displayName ?? "",
                        email: firebaseUser.email ?? "",
                        phone: "",
                        address: "",
                        userType: .customer, // Default, or prompt for this
                        createdAt: Date(),
                        services: []
                    )
                    Task {
                        do {
                            try await self?.saveUserToFirestore(user)
                            self?.currentUser = user
                            self?.isAuthenticated = true
                        } catch {
                            self?.errorMessage = "Failed to create user profile: \(error.localizedDescription)"
                        }
                    }
                } else {
                    self?.errorMessage = "User document not found"
                }
            }
        }
    }
    
    private func saveUserToFirestore(_ user: User) async throws {
        try db.collection("users").document(user.id).setData(from: user)
    }
    
    func updateUserProfile(_ user: User) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            try await saveUserToFirestore(user)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.currentUser = user
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
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
