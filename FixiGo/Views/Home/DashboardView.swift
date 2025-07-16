import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    private let theme = Theme()
    @Namespace private var animation
    @State private var showBookNowSheet = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: theme.spacing) {
                headerSection
                statsSection
                if let user = authViewModel.currentUser {
                    if user.userType == .customer {
                        featuredWorkersSection
                        quickActionsSection
                        activityTimelineSection
                        tipsCard
                        referEarnCard
                        customerDashboard
                    } else if user.userType == .worker {
                        featuredCustomersSection
                        quickActionsSection
                        activityTimelineSection
                        tipsCard
                        referEarnCard
                        workerDashboard
                    }
                } else {
                    LoadingView()
                }
            }
            .padding(.horizontal, 4)
            .padding(.top, 0)
            .padding(.bottom, 90) // Add bottom padding for tab bar
            .background(theme.backgroundGradient.ignoresSafeArea())
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showBookNowSheet) {
            // Placeholder for booking form
            VStack {
                Text("Book a Service")
                    .font(theme.titleFont)
                Spacer()
                Button("Close") { showBookNowSheet = false }
                    .font(theme.buttonFont)
                    .padding()
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            // Top header bar with color/gradient and rounded bottom corners
            HStack(alignment: .center) {
                // Profile Avatar
                Button(action: { /* Navigate to profile */ }) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                        .foregroundColor(.white)
                        .background(Circle().fill(theme.primaryColor))
                }
                .buttonStyle(PlainButtonStyle())
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                .padding(.trailing, 8)

                Spacer()
                // App Name
                Text("FixiGo")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.10), radius: 2, x: 0, y: 1)
                Spacer()
                // Notification Bell with Badge
                Button(action: { /* Navigate to notifications */ }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 28, weight: .regular))
                            .foregroundColor(.white)
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Text("2") // Replace with dynamic count
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            )
                            .offset(x: 1, y: -6)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            .padding(.bottom, 32)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: [theme.primaryColor, theme.secondaryColor]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .clipShape(RoundedCorner(radius: 32, corners: [.bottomLeft, .bottomRight]))
            )
            // Overlapping search bar
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(theme.placeholderColor)
                    TextField("Search services, workers...", text: .constant(""))
                        .font(theme.bodyFont)
                        .foregroundColor(theme.textColor)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 18)
                .background(
                    RoundedRectangle(cornerRadius: theme.largeCornerRadius)
                        .fill(Color.white)
                        .shadow(color: theme.primaryColor.opacity(0.10), radius: 6, x: 0, y: 2)
                )
            }
            .padding(.horizontal, 20)
            .offset(y: 32)
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Book Now Button
    private var bookNowButton: some View {
        Button(action: { showBookNowSheet = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(theme.primaryGradient)
            .cornerRadius(theme.largeCornerRadius)
            .shadow(color: theme.primaryColor.opacity(0.18), radius: 10, x: 0, y: 6)
        }
        .padding(.vertical, 4)
        .padding(.bottom, 2)
        .animation(.spring(), value: showBookNowSheet)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: theme.spacing) {
            statCard(title: "Bookings", value: "12", icon: "calendar", color: theme.primaryColor)
            statCard(title: "Completed", value: "8", icon: "checkmark.seal.fill", color: theme.successColor)
            statCard(title: "Pending", value: "4", icon: "clock.fill", color: theme.accentColor)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
            }
            Text(value)
                .font(.poppins(size: 22, weight: .bold))
                .foregroundColor(theme.textColor)
            Text(title)
                .font(theme.captionFont)
                .foregroundColor(theme.placeholderColor)
        }
        .padding(.vertical, theme.spacing)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .fill(LinearGradient(gradient: Gradient(colors: [color.opacity(0.08), .white]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: color.opacity(0.10), radius: 8, x: 0, y: 4)
        )
        .animation(.spring(), value: value)
    }
    
    // MARK: - Featured Workers/Customers
    private var featuredWorkersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Featured Workers")
                .font(theme.subtitleFont)
                .foregroundColor(theme.primaryColor)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing) {
                    ForEach(0..<3) { i in
                        featuredCard(name: "Worker \(i+1)", role: "Plumber", rating: 4.5, color: theme.primaryGradient)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    private var featuredCustomersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Top Customers")
                .font(theme.subtitleFont)
                .foregroundColor(theme.primaryColor)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing) {
                    ForEach(0..<3) { i in
                        featuredCard(name: "Customer \(i+1)", role: "Premium", rating: 5.0, color: LinearGradient(colors: [theme.secondaryColor, theme.accentColor], startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    private func featuredCard(name: String, role: String, rating: Double, color: LinearGradient) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 54, height: 54)
                Text(String(name.prefix(1)))
                    .font(.poppins(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }
            Text(name)
                .font(theme.bodyFont)
                .foregroundColor(theme.textColor)
            Text(role)
                .font(theme.captionFont)
                .foregroundColor(theme.placeholderColor)
            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .foregroundColor(theme.accentColor)
                    .font(.system(size: 12))
                Text(String(format: "%.1f", rating))
                    .font(theme.captionFont)
                    .foregroundColor(theme.textColor)
            }
        }
        .padding(theme.spacing)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .fill(Color.white)
                .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
        )
        .frame(width: 120)
        .animation(.easeInOut, value: name)
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        HStack(spacing: theme.spacing) {
            quickActionButton(title: "Track Job", icon: "location.fill", color: theme.secondaryColor)
            quickActionButton(title: "Pay", icon: "creditcard.fill", color: theme.accentColor)
            quickActionButton(title: "Support", icon: "questionmark.circle.fill", color: theme.primaryColor)
        }
        .padding(.vertical, 4)
    }
    private func quickActionButton(title: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(color)
            }
            Text(title)
                .font(theme.captionFont)
                .foregroundColor(theme.textColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(theme.cardBackground)
        .cornerRadius(theme.cornerRadius)
        .shadow(color: color.opacity(0.12), radius: 4, x: 0, y: 2)
        .animation(.spring(), value: title)
    }
    
    // MARK: - Activity Timeline
    private var activityTimelineSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recent Activity")
                .font(theme.subtitleFont)
                .foregroundColor(theme.primaryColor)
            VStack(spacing: 0) {
                ForEach(activityTimelineMock.indices, id: \ .self) { idx in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(idx == 0 ? theme.successColor : theme.primaryColor.opacity(0.18))
                                .frame(width: 16, height: 16)
                            if idx == 0 {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(activityTimelineMock[idx].title)
                                .font(theme.bodyFont)
                                .foregroundColor(theme.textColor)
                            Text(activityTimelineMock[idx].subtitle)
                                .font(theme.captionFont)
                                .foregroundColor(theme.placeholderColor)
                        }
                        Spacer()
                        Image(systemName: activityTimelineMock[idx].icon)
                            .font(.system(size: 18))
                            .foregroundColor(theme.primaryColor)
                            .padding(.top, 2)
                    }
                    .padding(.vertical, 12)
                    if idx != activityTimelineMock.indices.last {
                        Divider().background(theme.borderColor)
                    }
                }
            }
            .background(theme.cardBackground)
            .cornerRadius(theme.cornerRadius)
            .shadow(color: theme.shadowColor, radius: 2, x: 0, y: 1)
        }
    }
    private var activityTimelineMock: [(title: String, subtitle: String, icon: String)] {
        [
            ("You booked a service with Rajesh Kumar.", "10 July, 5:00 PM", "calendar"),
            ("Payment of ₹500 completed.", "10 July, 4:55 PM", "creditcard.fill"),
            ("Booking confirmed.", "10 July, 4:50 PM", "checkmark.seal.fill")
        ]
    }
    
    // MARK: - Tips & Safety Card
    private var tipsCard: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 32))
                .foregroundColor(theme.accentColor)
                .padding(.top, 4)
            VStack(alignment: .leading, spacing: 4) {
                Text("Tips & Safety")
                    .font(theme.subtitleFont)
                    .foregroundColor(theme.primaryColor)
                Text("Always verify worker ID before service. Pay securely through the app.")
                    .font(theme.captionFont)
                    .foregroundColor(theme.textColor)
            }
            Spacer()
        }
        .padding(theme.spacing)
        .background(
            LinearGradient(gradient: Gradient(colors: [theme.accentColor.opacity(0.08), .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(theme.cornerRadius)
        .shadow(color: theme.accentColor.opacity(0.10), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Refer & Earn Card
    private var referEarnCard: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: "gift.fill")
                .font(.system(size: 32))
                .foregroundColor(theme.successColor)
            VStack(alignment: .leading, spacing: 4) {
                Text("Refer & Earn")
                    .font(theme.subtitleFont)
                    .foregroundColor(theme.successColor)
                Text("Invite friends and earn rewards on their first booking!")
                    .font(theme.captionFont)
                    .foregroundColor(theme.textColor)
            }
            Spacer()
            Button(action: { /* Share action */ }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(theme.successColor)
                    .clipShape(Circle())
            }
        }
        .padding(theme.spacing)
        .background(
            LinearGradient(gradient: Gradient(colors: [theme.successColor.opacity(0.08), .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(theme.cornerRadius)
        .shadow(color: theme.successColor.opacity(0.10), radius: 6, x: 0, y: 2)
    }
    
    // MARK: - Customer Dashboard
    private var customerDashboard: some View {
        VStack(spacing: theme.largeSpacing) {
            dashboardCard(title: "Upcoming Bookings", icon: "calendar", color: theme.secondaryColor, description: "View and manage your scheduled jobs.")
            dashboardCard(title: "Payment & History", icon: "creditcard.fill", color: theme.primaryColor, description: "Check your payments and past jobs.")
            dashboardCard(title: "Reviews & Ratings", icon: "star.fill", color: theme.accentColor, description: "See your reviews and rate workers.")
        }
    }
    
    // MARK: - Worker Dashboard
    private var workerDashboard: some View {
        VStack(spacing: theme.largeSpacing) {
            dashboardCard(title: "New Job Requests", icon: "bell.fill", color: theme.accentColor, description: "See and accept new service requests.")
            dashboardCard(title: "My Bookings", icon: "calendar", color: theme.primaryColor, description: "Track your upcoming and past jobs.")
            dashboardCard(title: "Earnings", icon: "indianrupeesign.circle.fill", color: theme.secondaryColor, description: "View your earnings and payment status.")
            dashboardCard(title: "Profile & Verification", icon: "person.crop.circle.fill", color: theme.secondaryColor, description: "Manage your profile and documents.")
        }
    }
    
    // MARK: - Dashboard Card
    private func dashboardCard(title: String, icon: String, color: Color, description: String) -> some View {
        HStack(alignment: .top, spacing: theme.spacing) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(theme.subtitleFont)
                    .foregroundColor(theme.textColor)
                Text(description)
                    .font(theme.captionFont)
                    .foregroundColor(theme.placeholderColor)
            }
            Spacer()
        }
        .padding(theme.spacing)
        .background(
            LinearGradient(gradient: Gradient(colors: [color.opacity(0.08), .white]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(theme.cornerRadius)
        .shadow(color: color.opacity(0.10), radius: 8, x: 0, y: 4)
        .animation(.easeInOut, value: title)
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
} 
