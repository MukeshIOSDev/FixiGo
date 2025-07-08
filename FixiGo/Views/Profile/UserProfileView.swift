import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var showingEditProfile = false
    @State private var showingSettings = false
    
    private let theme = Theme()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: theme.largeSpacing) {
                    // Profile header
                    profileHeader
                    
                    // Stats section
                    statsSection
                    
                    // Menu options
                    menuSection
                }
                .padding(.horizontal, theme.largeSpacing)
                .padding(.bottom, theme.largeSpacing)
            }
            .background(theme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditProfile = true
                    }
                    .font(theme.buttonFont)
                    .foregroundColor(theme.primaryColor)
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Profile Header
    private var profileHeader: some View {
        VStack(spacing: theme.spacing) {
            // Avatar
            ZStack {
                Circle()
                    .fill(theme.primaryGradient)
                    .frame(width: 100, height: 100)
                
                Text(profileViewModel.user?.name.prefix(1).uppercased() ?? "U")
                    .font(.poppins(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text(profileViewModel.user?.name ?? "User Name")
                    .font(theme.titleFont)
                    .foregroundColor(theme.textColor)
                
                Text(profileViewModel.user?.email ?? "user@example.com")
                    .font(theme.bodyFont)
                    .foregroundColor(theme.placeholderColor)
            }
        }
        .padding(theme.largeSpacing)
        .background(Color.white)
        .cornerRadius(theme.cornerRadius)
        .shadow(color: theme.shadowColor, radius: theme.shadowRadius, x: 0, y: theme.shadowY)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: theme.spacing) {
            StatCard(
                title: "Total Bookings",
                value: "\(profileViewModel.totalBookings)",
                icon: "list.bullet.clipboard"
            )
            
            StatCard(
                title: "Completed",
                value: "\(profileViewModel.completedBookings)",
                icon: "checkmark.circle"
            )
            
            StatCard(
                title: "Pending",
                value: "\(profileViewModel.pendingBookings)",
                icon: "clock"
            )
        }
    }
    
    // MARK: - Menu Section
    private var menuSection: some View {
        VStack(spacing: theme.spacing) {
            MenuRow(
                icon: "person.fill",
                title: "Personal Information",
                subtitle: "Update your profile details",
                action: { showingEditProfile = true }
            )
            
            MenuRow(
                icon: "location.fill",
                title: "Saved Addresses",
                subtitle: "Manage your addresses",
                action: { /* Navigate to addresses */ }
            )
            
            MenuRow(
                icon: "creditcard.fill",
                title: "Payment Methods",
                subtitle: "Manage payment options",
                action: { /* Navigate to payments */ }
            )
            
            MenuRow(
                icon: "bell.fill",
                title: "Notifications",
                subtitle: "Configure notification settings",
                action: { /* Navigate to notifications */ }
            )
            
            MenuRow(
                icon: "questionmark.circle.fill",
                title: "Help & Support",
                subtitle: "Get help and contact support",
                action: { /* Navigate to support */ }
            )
            
            MenuRow(
                icon: "gear",
                title: "Settings",
                subtitle: "App settings and preferences",
                action: { showingSettings = true }
            )
            
            Divider()
                .background(theme.borderColor)
                .padding(.vertical, theme.spacing)
            
            // Logout button
            Button(action: { authViewModel.signOut() }) {
                HStack(spacing: theme.spacing) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                    
                    Text("Sign Out")
                        .font(theme.bodyFont)
                        .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding(theme.spacing)
                .background(Color.white)
                .cornerRadius(theme.cornerRadius)
                .shadow(color: theme.shadowColor, radius: 2, x: 0, y: 1)
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    private let theme = Theme()
    
    var body: some View {
        VStack(spacing: theme.smallSpacing) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(theme.primaryColor)
            
            Text(value)
                .font(theme.titleFont)
                .foregroundColor(theme.textColor)
            
            Text(title)
                .font(theme.captionFont)
                .foregroundColor(theme.placeholderColor)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(theme.spacing)
        .background(Color.white)
        .cornerRadius(theme.cornerRadius)
        .shadow(color: theme.shadowColor, radius: theme.shadowRadius, x: 0, y: theme.shadowY)
    }
}

// MARK: - Menu Row
struct MenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    private let theme = Theme()
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: theme.spacing) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(theme.primaryColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(theme.bodyFont)
                        .foregroundColor(theme.textColor)
                    
                    Text(subtitle)
                        .font(theme.captionFont)
                        .foregroundColor(theme.placeholderColor)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(theme.placeholderColor)
            }
            .padding(theme.spacing)
            .background(Color.white)
            .cornerRadius(theme.cornerRadius)
            .shadow(color: theme.shadowColor, radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Edit Profile View (Placeholder)
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let theme = Theme()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Edit Profile")
                    .font(theme.titleFont)
                    .foregroundColor(theme.textColor)
            }
            .background(theme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(theme.buttonFont)
                    .foregroundColor(theme.primaryColor)
                }
            }
        }
    }
}

// MARK: - Settings View (Placeholder)
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let theme = Theme()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
                    .font(theme.titleFont)
                    .foregroundColor(theme.textColor)
            }
            .background(theme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(theme.buttonFont)
                    .foregroundColor(theme.primaryColor)
                }
            }
        }
    }
}

#Preview {
    UserProfileView()
        .environmentObject(AuthViewModel())
} 