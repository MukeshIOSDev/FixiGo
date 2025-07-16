import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    private let theme = Theme()
    @Namespace private var animation
    @State private var showBookNowSheet = false
    @State private var selectedStatsPeriod: StatsPeriod = .today
    @State private var showStatDetail: Bool = false
    @State private var selectedStat: StatType? = nil
    
    enum StatsPeriod: String, CaseIterable, Identifiable {
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
        var id: String { self.rawValue }
    }
    
    enum StatType: String, Identifiable {
        case bookings = "Bookings"
        case completed = "Completed"
        case pending = "Pending"
        var id: String { self.rawValue }
    }
    
    // Computed stats for each period
    private var bookingsStat: (value: Int, progress: Double) {
        switch selectedStatsPeriod {
        case .today: return (5, 0.5)
        case .week: return (28, 0.7)
        case .month: return (110, 0.9)
        }
    }
    private var completedStat: (value: Int, progress: Double) {
        switch selectedStatsPeriod {
        case .today: return (3, 0.3)
        case .week: return (20, 0.5)
        case .month: return (80, 0.7)
        }
    }
    private var pendingStat: (value: Int, progress: Double) {
        switch selectedStatsPeriod {
        case .today: return (2, 0.2)
        case .week: return (8, 0.2)
        case .month: return (30, 0.3)
        }
    }
    
    // Mock data for histories
    private let bookingHistory: [BookingHistoryItem] = [
        .init(id: 1, worker: "Rajesh Kumar", date: "10 July", status: "Completed"),
        .init(id: 2, worker: "Amit Singh", date: "9 July", status: "Pending"),
        .init(id: 3, worker: "Priya Sharma", date: "8 July", status: "Cancelled")
    ]
    private let paymentHistory: [PaymentHistoryItem] = [
        .init(id: 1, amount: 500, date: "10 July", method: "UPI"),
        .init(id: 2, amount: 300, date: "8 July", method: "Card"),
        .init(id: 3, amount: 700, date: "5 July", method: "UPI")
    ]
    private let reviewHistory: [ReviewHistoryItem] = [
        .init(id: 1, rating: 5, text: "Great service!", date: "10 July"),
        .init(id: 2, rating: 4, text: "Good, but a bit late.", date: "8 July"),
        .init(id: 3, rating: 3, text: "Average experience.", date: "5 July")
    ]
    
    struct BookingHistoryItem: Identifiable { let id: Int; let worker: String; let date: String; let status: String }
    struct PaymentHistoryItem: Identifiable { let id: Int; let amount: Int; let date: String; let method: String }
    struct ReviewHistoryItem: Identifiable { let id: Int; let rating: Int; let text: String; let date: String }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: theme.spacing) {
                headerSection
                // Period Picker and Label
                VStack(spacing: 4) {
                    Picker("Stats Period", selection: $selectedStatsPeriod) {
                        ForEach(StatsPeriod.allCases) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 8)
                    Text("Showing \(selectedStatsPeriod.rawValue)\'s Stats")
                        .font(.caption)
                        .foregroundColor(theme.placeholderColor)
                        .padding(.bottom, 2)
                }
                statsSection
                // Booking History Section
                historySection(title: "Booking History", items: bookingHistory.map { AnyView(BookingHistoryCard(item: $0)) }, onMore: { /* Future: Navigate to full booking history */ })
                // Payment History Section
                historySection(title: "Payment History", items: paymentHistory.map { AnyView(PaymentHistoryCard(item: $0)) }, onMore: { /* Future: Navigate to full payment history */ })
                // Review History Section
                //historySection(title: "Review History", items: reviewHistory.map { AnyView(ReviewHistoryCard(item: $0)) })
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
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(18)
                .background(theme.primaryGradient)
                .clipShape(Circle())
                .shadow(color: theme.primaryColor.opacity(0.18), radius: 10, x: 0, y: 6)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 24)
        .animation(.spring(), value: showBookNowSheet)
    }
    
    // MARK: - Stats Section
    private var statsSection: some View {
        HStack(spacing: theme.spacing) {
            StatCardButton(title: "Bookings", value: bookingsStat.value, icon: "calendar", color: theme.primaryColor, progress: bookingsStat.progress, statType: .bookings, showStatDetail: $showStatDetail, selectedStat: $selectedStat)
            StatCardButton(title: "Completed", value: completedStat.value, icon: "checkmark.seal.fill", color: Color.green, progress: completedStat.progress, statType: .completed, showStatDetail: $showStatDetail, selectedStat: $selectedStat)
            StatCardButton(title: "Pending", value: pendingStat.value, icon: "clock.fill", color: theme.accentColor, progress: pendingStat.progress, statType: .pending, showStatDetail: $showStatDetail, selectedStat: $selectedStat)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .sheet(isPresented: $showStatDetail) {
            if let stat = selectedStat {
                StatDetailSheet(statType: stat, period: selectedStatsPeriod)
            }
        }
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

// Generic horizontal scrollable history section
private func historySection(title: String, items: [AnyView], onMore: (() -> Void)? = nil) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(theme.primaryColor)
            Spacer()
            if let onMore = onMore {
                Button(action: onMore) {
                    HStack(spacing: 4) {
                        Text("More")
                            .font(.subheadline)
                            .foregroundColor(theme.accentColor)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(theme.accentColor)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(theme.accentColor.opacity(0.08)))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 4)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(items.enumerated()), id: \ .0) { idx, view in
                    view
                }
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 2)
        }
    }
    .padding(.top, 8)
}

// Improved Booking History Card
struct BookingHistoryCard: View {
    let item: DashboardView.BookingHistoryItem
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(item.status == "Completed" ? Color.green.opacity(0.15) : (item.status == "Pending" ? Color.orange.opacity(0.15) : Color.red.opacity(0.15)))
                    .frame(width: 38, height: 38)
                Image(systemName: item.status == "Completed" ? "checkmark.seal.fill" : (item.status == "Pending" ? "clock.fill" : "xmark.octagon.fill"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(item.status == "Completed" ? .green : (item.status == "Pending" ? .orange : .red))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(item.worker)
                    .font(.subheadline).bold()
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text(item.date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(item.status)
                    .font(.caption2)
                    .foregroundColor(item.status == "Completed" ? .green : (item.status == "Pending" ? .orange : .red))
                    .padding(.top, 2)
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
        )
        .frame(width: 180, alignment: .leading)
        .onTapGesture { /* Future: Navigate to booking detail */ }
    }
}
// Improved Payment History Card
struct PaymentHistoryCard: View {
    let item: DashboardView.PaymentHistoryItem
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: item.method == "UPI" ? "indianrupeesign.circle.fill" : "creditcard.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(item.method == "UPI" ? .blue : .purple)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("₹\(item.amount)")
                    .font(.subheadline).bold()
                Text(item.method)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(item.date)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
        )
        .frame(width: 160)
        .onTapGesture { /* Future: Navigate to payment detail */ }
    }
}
// Review History Card
struct ReviewHistoryCard: View {
    let item: DashboardView.ReviewHistoryItem
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 2) {
                ForEach(0..<item.rating, id: \.self) { _ in
                    Image(systemName: "star.fill").font(.caption2).foregroundColor(.yellow)
                }
            }
            Text(item.text)
                .font(.caption)
                .lineLimit(2)
            Text(item.date)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white).shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2))
        .frame(width: 160)
        .onTapGesture { /* Future: Navigate to review detail */ }
    }
}
}

// AnimatedStatCard View (move outside DashboardView)
struct AnimatedStatCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    let progress: Double // 0.0 to 1.0
    @State private var animatedValue: Double = 0
    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.12), lineWidth: 7)
                    .frame(width: 54, height: 54)
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(color, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 54, height: 54)
                    .shadow(color: color.opacity(0.18), radius: 4, x: 0, y: 2)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(color)
            }
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.7))
                    .blur(radius: 0.5)
            )
            .padding(.bottom, 2)
            Text("\(Int(animatedValue))")
                .font(.poppins(size: 22, weight: .bold))
                .foregroundColor(.primary)
                .animation(nil, value: animatedValue)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.5))
                .shadow(color: color.opacity(0.10), radius: 8, x: 0, y: 4)
        )
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedValue = Double(value)
                animatedProgress = progress
            }
        }
    }
}

// StatCardButton wraps AnimatedStatCard and handles tap
struct StatCardButton: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    let progress: Double
    let statType: DashboardView.StatType
    @Binding var showStatDetail: Bool
    @Binding var selectedStat: DashboardView.StatType?
    @State private var isPressed = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            selectedStat = statType
            showStatDetail = true
        }) {
            AnimatedStatCard(title: title, value: value, icon: icon, color: color, progress: progress)
                .scaleEffect(isPressed ? 0.96 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in isPressed = true }
            .onEnded { _ in isPressed = false })
    }
}

// StatDetailSheet for showing detailed data
struct StatDetailSheet: View {
    let statType: DashboardView.StatType
    let period: DashboardView.StatsPeriod
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.secondary.opacity(0.2))
                .frame(width: 40, height: 6)
                .padding(.top, 8)
            Text("\(statType.rawValue) Details")
                .font(.title2).bold()
            Text("Period: \(period.rawValue)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Divider()
            // Placeholder for detailed data (list, chart, etc.)
            VStack(spacing: 12) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 40))
                    .foregroundColor(.accentColor)
                Text("Detailed data for \(statType.rawValue) in \(period.rawValue) will appear here.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
} 
