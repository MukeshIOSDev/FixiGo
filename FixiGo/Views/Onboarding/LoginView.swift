import SwiftUI
// Import the shared components and view model
// If using modules, adjust import as needed
// import FixiGo.ViewModels.AuthViewModel
// import FixiGo.Views.Shared.AppTextField
// import FixiGo.Views.Shared.AppButton

struct LoginView: View {
    let onSignInSuccess: () -> Void
    let onShowSignup: () -> Void
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showPassword = false
    @State private var showForgotPassword = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.theme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "wrench.and.screwdriver.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color.theme.primary)
                            
                            Text("Welcome Back!")
                                .font(.custom("Poppins-Bold", size: 28))
                                .foregroundColor(Color.theme.text)
                            
                            Text("Sign in to continue with FixiGo")
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundColor(Color.theme.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        
                        // Login Form
                        VStack(spacing: 20) {
                            // Email Field
                            AppTextField(
                                placeholder: "Email",
                                text: $authViewModel.loginEmail,
                                icon: "envelope.fill"
                            )
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            
                            // Password Field
                            HStack {
                                if showPassword {
                                    TextField("Password", text: $authViewModel.loginPassword)
                                        .textContentType(.password)
                                        .autocapitalization(.none)
                                } else {
                                    SecureField("Password", text: $authViewModel.loginPassword)
                                        .textContentType(.password)
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
                            
                            // Forgot Password
                            HStack {
                                Spacer()
                                Button("Forgot Password?") {
                                    showForgotPassword = true
                                }
                                .font(.custom("Poppins-Medium", size: 14))
                                .foregroundColor(Color.theme.primary)
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
                        
                        // Sign In Button
                        Button(action: {
                            Task {
                                await authViewModel.signIn()
                                if authViewModel.isAuthenticated {
                                    onSignInSuccess()
                                }
                            }
                        }) {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Sign In")
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
                        
                        // Sign Up Link
                        HStack {
                            Text("Don't have an account?")
                                .font(.custom("Poppins-Regular", size: 14))
                                .foregroundColor(Color.theme.textSecondary)
                            
                            Button("Sign Up") {
                                onShowSignup()
                            }
                            .font(.custom("Poppins-SemiBold", size: 14))
                            .foregroundColor(Color.theme.primary)
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
        }
    }
}

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 50))
                        .foregroundColor(Color.theme.primary)
                    
                    Text("Reset Password")
                        .font(.custom("Poppins-Bold", size: 24))
                        .foregroundColor(Color.theme.text)
                    
                    Text("Enter your email address and we'll send you a link to reset your password.")
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(Color.theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Email Field
                AppTextField(
                    placeholder: "Email",
                    text: $email,
                    icon: "envelope.fill"
                )
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                
                // Error Message
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.custom("Poppins-Regular", size: 14))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                // Reset Button
                Button(action: {
                    authViewModel.loginEmail = email
                    Task {
                        await authViewModel.resetPassword()
                        dismiss()
                    }
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Send Reset Link")
                            .font(.custom("Poppins-SemiBold", size: 16))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.theme.primary)
                .foregroundColor(.white)
                .cornerRadius(12)
                .disabled(authViewModel.isLoading)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(Color.theme.primary)
                }
            }
        }
    }
}

#Preview {
    LoginView(
        onSignInSuccess: {},
        onShowSignup: {}
    )
    .environmentObject(AuthViewModel())
} 