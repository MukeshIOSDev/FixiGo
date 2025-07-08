import SwiftUI

struct WorkerCardView: View {
    let worker: Worker
    @State private var showingWorkerProfile = false
    
    private let theme = Theme()
    
    var body: some View {
        Button(action: { showingWorkerProfile.toggle() }) {
            VStack(alignment: .leading, spacing: theme.spacing) {
                // Header with avatar and basic info
                HStack(spacing: theme.spacing) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(theme.primaryGradient)
                            .frame(width: 60, height: 60)
                        
                        Text(worker.name.prefix(1).uppercased())
                            .font(.poppins(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(worker.name)
                                .font(theme.subtitleFont)
                                .foregroundColor(theme.textColor)
                            
                            Spacer()
                            
                            // Verified badge
                            if worker.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(theme.accentColor)
                                    .font(.system(size: 16))
                            }
                        }
                        
                        // Rating
                        HStack(spacing: 4) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(worker.rating) ? "star.fill" : "star")
                                    .font(.system(size: 12))
                                    .foregroundColor(index < Int(worker.rating) ? theme.accentColor : theme.placeholderColor)
                            }
                            
                            Text(String(format: "%.1f", worker.rating))
                                .font(theme.captionFont)
                                .foregroundColor(theme.textColor)
                            
                            Text("(\(worker.totalJobs) jobs)")
                                .font(theme.captionFont)
                                .foregroundColor(theme.placeholderColor)
                        }
                        
                        // Services
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(worker.services, id: \.self) { service in
                                    Text(service.rawValue)
                                        .font(theme.captionFont)
                                        .foregroundColor(theme.primaryColor)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(theme.primaryColor.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                
                // Divider
                Rectangle()
                    .fill(theme.borderColor)
                    .frame(height: 1)
                
                // Footer with action buttons
                HStack {
                    // Distance/Status
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                            .foregroundColor(theme.primaryColor)
                        
                        Text("2.5 km away")
                            .font(theme.captionFont)
                            .foregroundColor(theme.textColor)
                    }
                    
                    Spacer()
                    
                    // Quick actions
                    HStack(spacing: theme.smallSpacing) {
                        Button(action: { /* Chat action */ }) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 14))
                                .foregroundColor(theme.primaryColor)
                                .frame(width: 32, height: 32)
                                .background(theme.primaryColor.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        Button(action: { /* Book action */ }) {
                            Text("Book Now")
                                .font(theme.captionFont)
                                .foregroundColor(.white)
                                .padding(.horizontal, theme.spacing)
                                .padding(.vertical, 6)
                                .background(theme.primaryGradient)
                                .cornerRadius(16)
                        }
                    }
                }
            }
            .padding(theme.spacing)
            .background(Color.white)
            .cornerRadius(theme.cornerRadius)
            .shadow(color: theme.shadowColor, radius: theme.shadowRadius, x: 0, y: theme.shadowY)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingWorkerProfile) {
            WorkerProfileView(worker: worker)
        }
    }
}

#Preview {
    WorkerCardView(worker: Worker(
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
    .padding()
    .background(Color.gray.opacity(0.1))
} 