import SwiftUI
// Import the shared components and view model
// If using modules, adjust import as needed
// import FixiGo.ViewModels.AuthViewModel
// import FixiGo.Views.Shared.AppTextField
// import FixiGo.Views.Shared.AppButton

struct SignupView: View {
    let onSignupSuccess: () -> Void
    let onShowLogin: () -> Void
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 60))
                                .foregroundColor(Color.theme.primary)
                            
                            Text("Create Account")
                                .font(.custom("Poppins-Bold", size: 28))
                                .foregroundColor(Color.theme.text)
                            
                            Text("Join FixiGo to connect with skilled professionals")
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundColor(Color.theme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        
                        // Signup Form
                        VStack(spacing: 16) {
                            // Name Field
                            AppTextField(
                                placeholder: "Full Name",
                                text: $authViewModel.signupName,
                                icon: "person.fill"
                            )
                            .textContentType(.name)
                            
                            // Email Field
                            AppTextField(
                                placeholder: "Email",
                                text: $authViewModel.signupEmail,
                                icon: "envelope.fill"
                            )
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            
                            // Phone Field
                            AppTextField(
                                placeholder: "Phone Number",
                                text: $authViewModel.signupPhone,
                                icon: "phone.fill"
                            )
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                            
                            // Address Field
                            AppTextField(
                                placeholder: "Address",
                                text: $authViewModel.signupAddress,
                                icon: "location.fill"
                            )
                            .textContentType(.fullStreetAddress)
                            
                            // User Type Selection
                            VStack(alignment: .leading, spacing: 12) {
                                Text("I am a:")
                                    .font(.custom("Poppins-Medium", size: 16))
                                    .foregroundColor(Color.theme.text)
                                
                                HStack(spacing: 12) {
                                    UserTypeButton(
                                        type: .customer,
                                        isSelected: authViewModel.selectedUserType == .customer,
                                        action: { authViewModel.selectedUserType = .customer }
                                    )
                                    
                                    UserTypeButton(
                                        type: .worker,
                                        isSelected: authViewModel.selectedUserType == .worker,
                                        action: { authViewModel.selectedUserType = .worker }
                                    )
                                }
                            }
                            
                            // Service Types (for workers)
                            if authViewModel.selectedUserType == .worker {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Services I provide:")
                                        .font(.custom("Poppins-Medium", size: 16))
                                        .foregroundColor(Color.theme.text)
                                    
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                        ForEach(ServiceType.allCases, id: \.self) { serviceType in
                                            ServiceTypeButton(
                                                service: serviceType,
                                                isSelected: authViewModel.selectedServiceTypes.contains(serviceType),
                                                action: { authViewModel.toggleServiceType(serviceType) }
                                            )
                                        }
                                    }
                                }
                            }
                            
                            // Password Field
                            HStack {
                                if showPassword {
                                    TextField("Password", text: $authViewModel.signupPassword)
                                        .textContentType(.newPassword)
                                        .autocapitalization(.none)
                                } else {
                                    SecureField("Password", text: $authViewModel.signupPassword)
                                        .textContentType(.newPassword)
                                }
                                
                                Button(action: {
                                    showPassword.toggle()
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                            }
                            .padding()
                            .background(Color.theme.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.theme.border, lineWidth: 1)
                            )
                            
                            // Confirm Password Field
                            HStack {
                                if showConfirmPassword {
                                    TextField("Confirm Password", text: $authViewModel.signupConfirmPassword)
                                        .textContentType(.newPassword)
                                        .autocapitalization(.none)
                                } else {
                                    SecureField("Confirm Password", text: $authViewModel.signupConfirmPassword)
                                        .textContentType(.newPassword)
                                }
                                
                                Button(action: {
                                    showConfirmPassword.toggle()
                                }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                            }
                            .padding()
                            .background(Color.theme.surface)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.theme.border, lineWidth: 1)
                            )
                            
                            // Terms Agreement
                            HStack(alignment: .top, spacing: 12) {
                                Button(action: {
                                    authViewModel.agreedToTerms.toggle()
                                }) {
                                    Image(systemName: authViewModel.agreedToTerms ? "checkmark.square.fill" : "square")
                                        .foregroundColor(authViewModel.agreedToTerms ? Color.theme.primary : Color.theme.textSecondary)
                                        .font(.system(size: 20))
                                }
                                
                                Text("I agree to the Terms of Service and Privacy Policy")
                                    .font(.custom("Poppins-Regular", size: 14))
                                    .foregroundColor(Color.theme.textSecondary)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        
                        // Error Message
                        if let errorMessage = authViewModel.errorMessage {
                            Text(errorMessage)
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        // Sign Up Button
                        Button(action: {
                            Task {
                                await authViewModel.signUp()
                            }
                        }) {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Create Account")
                                    .font(.custom("Poppins-SemiBold", size: 16))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.theme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(authViewModel.isLoading)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.theme.border)
                            
                            Text("OR")
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(Color.theme.textSecondary)
                                .padding(.horizontal, 16)
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.theme.border)
                        }
                        
                        // Sign In Link
                        HStack {
                            Text("Already have an account?")
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(Color.theme.textSecondary)
                            
                            Button("Sign In") {
                                onShowLogin()
                            }
                            .font(.custom("Poppins-SemiBold", size: 14))
                            .foregroundColor(Color.theme.primary)
                        }
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    SignupView(
        onSignupSuccess: {},
        onShowLogin: {}
    )
    .environmentObject(AuthViewModel())
} 
