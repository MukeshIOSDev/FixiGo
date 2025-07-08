import Foundation
import Combine
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Signup form fields
    @Published var signupName: String = ""
    @Published var signupEmail: String = ""
    @Published var signupPassword: String = ""
    @Published var signupConfirmPassword: String = ""
    @Published var signupPhone: String = ""
    @Published var signupAddress: String = ""
    @Published var selectedUserType: UserType = .customer
    @Published var selectedServiceTypes: Set<ServiceType> = []
    @Published var agreedToTerms: Bool = false
    
    // Login form fields
    @Published var loginEmail: String = ""
    @Published var loginPassword: String = ""
    
    private let authService = AuthService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind to AuthService state
        authService.$isAuthenticated
            .assign(to: \.isAuthenticated, on: self)
            .store(in: &cancellables)
        
        authService.$currentUser
            .assign(to: \.currentUser, on: self)
            .store(in: &cancellables)
        
        authService.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        authService.$errorMessage
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Sign Up
    func signUp() async {
        guard validateSignupForm() else { return }
        
        let userData = UserSignupData(
            name: signupName,
            email: signupEmail,
            phone: signupPhone,
            address: signupAddress,
            password: signupPassword,
            userType: selectedUserType,
            services: Array(selectedServiceTypes)
        )
        
        do {
            try await authService.signUp(userData: userData)
        } catch {
            // Error is already handled by AuthService
        }
    }
    
    
    private func validateSignupForm() -> Bool {
        // Clear previous errors
        DispatchQueue.main.async {
            self.errorMessage = nil
        }
        
        
        // Validate name
        guard !signupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter your name"
            return false
        }
        
        // Validate email
        guard isValidEmail(signupEmail) else {
            errorMessage = "Please enter a valid email address"
            return false
        }
        
        // Validate password
        guard signupPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long"
            return false
        }
        
        // Validate password confirmation
        guard signupPassword == signupConfirmPassword else {
            errorMessage = "Passwords do not match"
            return false
        }
        
        // Validate phone
        guard !signupPhone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter your phone number"
            return false
        }
        
        // Validate address
        guard !signupAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter your address"
            return false
        }
        
        // Validate service types for workers
        if selectedUserType == .worker && selectedServiceTypes.isEmpty {
            errorMessage = "Please select at least one service type"
            return false
        }
        
        // Validate terms agreement
        guard agreedToTerms else {
            errorMessage = "Please agree to the terms and conditions"
            return false
        }
        
        return true
    }
    
    // MARK: - Sign In
    func signIn() async {
        guard validateLoginForm() else { return }
        
        do {
            try await authService.signIn(email: loginEmail, password: loginPassword)
        } catch {
            // Error is already handled by AuthService
        }
    }
    
    private func validateLoginForm() -> Bool {
        // Clear previous errors
        DispatchQueue.main.async {
            self.errorMessage = nil
        }
        
        
        // Validate email
        guard isValidEmail(loginEmail) else {
            errorMessage = "Please enter a valid email address"
            return false
        }
        
        // Validate password
        guard !loginPassword.isEmpty else {
            errorMessage = "Please enter your password"
            return false
        }
        
        return true
    }
    
    // MARK: - Sign Out
    func signOut() {
        authService.signOut()
        clearFormData()
    }
    
    // MARK: - Password Reset
    func resetPassword() async {
        guard isValidEmail(loginEmail) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        do {
            try await authService.resetPassword(email: loginEmail)
            errorMessage = "Password reset email sent. Please check your inbox."
        } catch {
            // Error is already handled by AuthService
        }
    }
    
    // MARK: - Form Management
    func toggleServiceType(_ serviceType: ServiceType) {
        if selectedServiceTypes.contains(serviceType) {
            selectedServiceTypes.remove(serviceType)
        } else {
            selectedServiceTypes.insert(serviceType)
        }
    }
    
    func clearFormData() {
        signupName = ""
        signupEmail = ""
        signupPassword = ""
        signupConfirmPassword = ""
        signupPhone = ""
        signupAddress = ""
        selectedUserType = .customer
        selectedServiceTypes.removeAll()
        agreedToTerms = false
        
        loginEmail = ""
        loginPassword = ""
        
        errorMessage = nil
    }
    
    // MARK: - Validation Helpers
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // MARK: - User Profile Management
    func updateUserProfile() async {
        guard let user = currentUser else { return }
        
        do {
            try await authService.updateUserProfile(user)
        } catch {
            // Error is already handled by AuthService
        }
    }
    
    // MARK: - Email Verification
    func sendEmailVerification() async {
        do {
            try await authService.sendEmailVerification()
            errorMessage = "Verification email sent. Please check your inbox."
        } catch {
            // Error is already handled by AuthService
        }
    }
    
    func reloadUser() async {
        do {
            try await authService.reloadUser()
        } catch {
            // Error is already handled by AuthService
        }
    }
} 
