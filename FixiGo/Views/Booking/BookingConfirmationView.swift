import SwiftUI

struct BookingConfirmationView: View {
    let worker: Worker
    let booking: Booking?
    @Environment(\.dismiss) private var dismiss
    @State private var showingHome = false
    
    private let theme = Theme()
    
    var body: some View {
        NavigationView {
            VStack(spacing: theme.largeSpacing) {
                // Success animation
                successAnimation
                
                // Confirmation details
                confirmationDetails
                
                // Action buttons
                actionButtons
                
                Spacer()
            }
            .padding(theme.largeSpacing)
            .background(theme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Booking Confirmed")
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
        .fullScreenCover(isPresented: $showingHome) {
            HomeView()
        }
    }
    
    // MARK: - Success Animation
    private var successAnimation: some View {
        VStack(spacing: theme.spacing) {
            ZStack {
                Circle()
                    .fill(theme.accentColor.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Circle()
                    .fill(theme.accentColor)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Booking Confirmed!")
                .font(theme.titleFont)
                .foregroundColor(theme.textColor)
            
            Text("Your booking has been successfully created and sent to \(worker.name)")
                .font(theme.bodyFont)
                .foregroundColor(theme.placeholderColor)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Confirmation Details
    private var confirmationDetails: some View {
        VStack(spacing: theme.spacing) {
            // Booking ID
            HStack {
                Text("Booking ID")
                    .font(theme.bodyFont)
                    .foregroundColor(theme.placeholderColor)
                
                Spacer()
                
                Text(booking?.id.prefix(8).uppercased() ?? "N/A")
                    .font(theme.bodyFont)
                    .foregroundColor(theme.textColor)
                    .fontWeight(.medium)
            }
            
            Divider()
                .background(theme.borderColor)
            
            // Service details
            HStack {
                Text("Service")
                    .font(theme.bodyFont)
                    .foregroundColor(theme.placeholderColor)
                
                Spacer()
                
                Text(booking?.serviceType.rawValue ?? "N/A")
                    .font(theme.bodyFont)
                    .foregroundColor(theme.textColor)
                    .fontWeight(.medium)
            }
            
            Divider()
                .background(theme.borderColor)
            
            // Date and time
            HStack {
                Text("Date & Time")
                    .font(theme.bodyFont)
                    .foregroundColor(theme.placeholderColor)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(booking?.date.formatted(date: .abbreviated, time: .omitted) ?? "N/A")
                        .font(theme.bodyFont)
                        .foregroundColor(theme.textColor)
                        .fontWeight(.medium)
                    
                    Text(booking?.time.formatted(date: .omitted, time: .shortened) ?? "N/A")
                        .font(theme.captionFont)
                        .foregroundColor(theme.placeholderColor)
                }
            }
            
            Divider()
                .background(theme.borderColor)
            
            // Estimated cost
            HStack {
                Text("Estimated Cost")
                    .font(theme.bodyFont)
                    .foregroundColor(theme.placeholderColor)
                
                Spacer()
                
                Text("₹\(Int(booking?.estimatedCost.lowerBound ?? 0)) - ₹\(Int(booking?.estimatedCost.upperBound ?? 0))")
                    .font(theme.bodyFont)
                    .foregroundColor(theme.primaryColor)
                    .fontWeight(.medium)
            }
        }
        .padding(theme.largeSpacing)
        .background(Color.white)
        .cornerRadius(theme.cornerRadius)
        .shadow(color: theme.shadowColor, radius: theme.shadowRadius, x: 0, y: theme.shadowY)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: theme.spacing) {
            Button(action: { showingHome = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 16))
                    Text("Go to Home")
                        .font(theme.buttonFont)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, theme.spacing)
                .background(theme.primaryGradient)
                .cornerRadius(theme.cornerRadius)
            }
            
            Button(action: { /* View bookings action */ }) {
                HStack(spacing: 8) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 16))
                    Text("View My Bookings")
                        .font(theme.buttonFont)
                }
                .foregroundColor(theme.primaryColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, theme.spacing)
                .background(Color.white)
                .cornerRadius(theme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .stroke(theme.primaryColor, lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    BookingConfirmationView(
        worker: Worker(
            id: "1",
            name: "Rajesh Kumar",
            email: "rajesh@example.com",
            phone: "+91 98765 43210",
            address: "Mumbai, Maharashtra",
            services: [ServiceType.plumber, ServiceType.electrician],
            rating: 4.5,
            totalJobs: 127,
            isVerified: true,
            createdAt: Date()
        ),
        booking: Booking(
            id: "booking123",
            customerId: "currentUser",
            workerId: "1",
            serviceType: ServiceType.plumber,
            date: Date().addingTimeInterval(86400),
            time: Date(),
            description: "Fix leaking tap",
            address: "123 Main Street",
            status: BookingStatus.pending,
            estimatedCost: 500...1500,
            createdAt: Date()
        )
    )
} 