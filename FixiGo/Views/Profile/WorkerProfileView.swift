import SwiftUI

struct WorkerProfileView: View {
    let worker: Worker
    @Environment(\.dismiss) private var dismiss
    @State private var showingBookingForm = false
    @State private var showingChat = false
    @State private var selectedTab = 0
    
    private let theme = Theme()
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    // Header section
                    headerSection
                    
                    // Tab selector
                    tabSelector
                    
                    // Tab content
                    tabContent
                }
            }
            .background(theme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Worker Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: toolbarContent)
        }
        .sheet(isPresented: $showingBookingForm) {
            BookingFormView()
        }
        .sheet(isPresented: $showingChat) {
            ChatView(worker: worker)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: theme.largeSpacing) {
            // Avatar and basic info
            VStack(spacing: theme.spacing) {
                ZStack {
                    Circle()
                        .fill(theme.primaryGradient)
                        .frame(width: 100, height: 100)
                    
                    Text(worker.name.prefix(1).uppercased())
                        .font(.poppins(size: 40, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    HStack {
                        Text(worker.name)
                            .font(theme.titleFont)
                            .foregroundColor(theme.textColor)
                        
                        if worker.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(theme.accentColor)
                                .font(.system(size: 20))
                        }
                    }
                    
                    // Rating
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(worker.rating) ? "star.fill" : "star")
                                .font(.system(size: 16))
                                .foregroundColor(index < Int(worker.rating) ? theme.accentColor : theme.placeholderColor)
                        }
                        
                        Text(String(format: "%.1f", worker.rating))
                            .font(theme.bodyFont)
                            .foregroundColor(theme.textColor)
                        
                        Text("(\(worker.totalJobs) jobs)")
                            .font(theme.captionFont)
                            .foregroundColor(theme.placeholderColor)
                    }
                }
            }
            
            // Services
            VStack(alignment: .leading, spacing: theme.smallSpacing) {
                Text("Services")
                    .font(theme.subtitleFont)
                    .foregroundColor(theme.textColor)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: theme.smallSpacing) {
                    ForEach(worker.services, id: \.self) { service in
                        HStack(spacing: 8) {
                            Image(systemName: service.icon)
                                .font(.system(size: 16))
                                .foregroundColor(theme.primaryColor)
                            
                            Text(service.rawValue)
                                .font(theme.bodyFont)
                                .foregroundColor(theme.textColor)
                        }
                        .padding(theme.spacing)
                        .background(Color.white)
                        .cornerRadius(theme.cornerRadius)
                        .shadow(color: theme.shadowColor, radius: 2, x: 0, y: 1)
                    }
                }
            }
            .padding(.horizontal, theme.largeSpacing)
            
            // Action buttons
            HStack(spacing: theme.spacing) {
                Button(action: { showingChat.toggle() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 16))
                        Text("Chat")
                            .font(theme.buttonFont)
                    }
                    .foregroundColor(theme.primaryColor)
                    .padding(.horizontal, theme.largeSpacing)
                    .padding(.vertical, theme.spacing)
                    .background(Color.white)
                    .cornerRadius(theme.cornerRadius)
                    .shadow(color: theme.shadowColor, radius: 2, x: 0, y: 1)
                }
                
                Button(action: { showingBookingForm.toggle() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 16))
                        Text("Book Now")
                            .font(theme.buttonFont)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, theme.largeSpacing)
                    .padding(.vertical, theme.spacing)
                    .background(theme.primaryGradient)
                    .cornerRadius(theme.cornerRadius)
                    .shadow(color: theme.shadowColor, radius: 2, x: 0, y: 1)
                }
            }
            .padding(.horizontal, theme.largeSpacing)
        }
        .padding(.vertical, theme.largeSpacing)
        .background(Color.white)
        .cornerRadius(theme.cornerRadius, corners: [.bottomLeft, .bottomRight])
        .shadow(color: theme.shadowColor, radius: theme.shadowRadius, x: 0, y: theme.shadowY)
        .padding(.horizontal, theme.largeSpacing)
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(["About", "Reviews", "Photos"], id: \.self) { tab in
                Button(action: {
                    selectedTab = ["About", "Reviews", "Photos"].firstIndex(of: tab) ?? 0
                }) {
                    Text(tab)
                        .font(theme.bodyFont)
                        .foregroundColor(selectedTab == ["About", "Reviews", "Photos"].firstIndex(of: tab) ? theme.primaryColor : theme.placeholderColor)
                        .padding(.vertical, theme.spacing)
                        .frame(maxWidth: .infinity)
                        .background(
                            selectedTab == ["About", "Reviews", "Photos"].firstIndex(of: tab) ? 
                            theme.primaryColor.opacity(0.1) : Color.clear
                        )
                }
            }
        }
        .background(Color.white)
        .cornerRadius(theme.cornerRadius)
        .shadow(color: theme.shadowColor, radius: 2, x: 0, y: 1)
        .padding(.horizontal, theme.largeSpacing)
        .padding(.top, theme.spacing)
    }
    
    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0:
            aboutTab
        case 1:
            reviewsTab
        case 2:
            photosTab
        default:
            aboutTab
        }
    }
    
    // MARK: - About Tab
    private var aboutTab: some View {
        VStack(alignment: .leading, spacing: theme.spacing) {
            // Contact Info
            VStack(alignment: .leading, spacing: theme.smallSpacing) {
                Text("Contact Information")
                    .font(theme.subtitleFont)
                    .foregroundColor(theme.textColor)
                
                VStack(spacing: theme.smallSpacing) {
                    HStack(spacing: theme.smallSpacing) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(theme.primaryColor)
                            .frame(width: 20)
                        
                        Text(worker.email)
                            .font(theme.bodyFont)
                            .foregroundColor(theme.textColor)
                    }
                    
                    HStack(spacing: theme.smallSpacing) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(theme.primaryColor)
                            .frame(width: 20)
                        
                        Text(worker.phone)
                            .font(theme.bodyFont)
                            .foregroundColor(theme.textColor)
                    }
                    
                    HStack(spacing: theme.smallSpacing) {
                        Image(systemName: "location.fill")
                            .foregroundColor(theme.primaryColor)
                            .frame(width: 20)
                        
                        Text(worker.address)
                            .font(theme.bodyFont)
                            .foregroundColor(theme.textColor)
                    }
                }
            }
            .padding(theme.spacing)
            .background(Color.white)
            .cornerRadius(theme.cornerRadius)
            .shadow(color: theme.shadowColor, radius: 2, x: 0, y: 1)
            
            // Experience
            VStack(alignment: .leading, spacing: theme.smallSpacing) {
                Text("Experience")
                    .font(theme.subtitleFont)
                    .foregroundColor(theme.textColor)
                
                Text("Completed \(worker.totalJobs) jobs with an average rating of \(String(format: "%.1f", worker.rating)) stars. \(worker.name) is a trusted professional in the local community.")
                    .font(theme.bodyFont)
                    .foregroundColor(theme.textColor)
                    .lineLimit(nil)
            }
            .padding(theme.spacing)
            .background(Color.white)
            .cornerRadius(theme.cornerRadius)
            .shadow(color: theme.shadowColor, radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, theme.largeSpacing)
        .padding(.top, theme.spacing)
    }
    
    // MARK: - Reviews Tab
    private var reviewsTab: some View {
        VStack(alignment: .leading, spacing: theme.spacing) {
            Text("Customer Reviews")
                .font(theme.subtitleFont)
                .foregroundColor(theme.textColor)
                .padding(.horizontal, theme.largeSpacing)
            
            LazyVStack(spacing: theme.spacing) {
                ForEach(0..<5, id: \.self) { index in
                    ReviewCard(
                        reviewerName: "Customer \(index + 1)",
                        rating: Double.random(in: 3.5...5.0),
                        review: "Great work! Very professional and completed the job on time. Highly recommended.",
                        date: Date().addingTimeInterval(-Double.random(in: 86400...2592000))
                    )
                }
            }
        }
        .padding(.top, theme.spacing)
    }
    
    // MARK: - Photos Tab
    private var photosTab: some View {
        VStack(alignment: .leading, spacing: theme.spacing) {
            Text("Work Photos")
                .font(theme.subtitleFont)
                .foregroundColor(theme.textColor)
                .padding(.horizontal, theme.largeSpacing)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: theme.spacing) {
                ForEach(0..<6, id: \.self) { index in
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .fill(theme.placeholderColor.opacity(0.3))
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundColor(theme.placeholderColor)
                        )
                }
            }
            .padding(.horizontal, theme.largeSpacing)
        }
        .padding(.top, theme.spacing)
    }
    
    // MARK: - Toolbar Content
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Close") {
                dismiss()
            }
            .font(theme.buttonFont)
            .foregroundColor(theme.primaryColor)
        }
    }
}

// MARK: - Review Card
struct ReviewCard: View {
    let reviewerName: String
    let rating: Double
    let review: String
    let date: Date
    
    private let theme = Theme()
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.smallSpacing) {
            HStack {
                Text(reviewerName)
                    .font(theme.bodyFont)
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(rating) ? "star.fill" : "star")
                            .font(.system(size: 12))
                            .foregroundColor(index < Int(rating) ? theme.accentColor : theme.placeholderColor)
                    }
                }
            }
            
            Text(review)
                .font(theme.bodyFont)
                .foregroundColor(theme.textColor)
                .lineLimit(3)
            
            Text(date, style: .relative)
                .font(theme.captionFont)
                .foregroundColor(theme.placeholderColor)
        }
        .padding(theme.spacing)
        .background(Color.white)
        .cornerRadius(theme.cornerRadius)
        .shadow(color: theme.shadowColor, radius: 2, x: 0, y: 1)
        .padding(.horizontal, theme.largeSpacing)
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    WorkerProfileView(worker: Worker(
        id: "1",
        name: "Rajesh Kumar",
        email: "rajesh@example.com",
        phone: "+91 98765 43210",
        address: "Mumbai, Maharashtra",
        services: [.plumber, .electrician],
        rating: 4.5,
        totalJobs: 127,
        isVerified: true,
        createdAt: Date()
    ))
} 