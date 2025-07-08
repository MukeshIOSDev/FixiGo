import SwiftUI

struct BookingHistoryView: View {
    @StateObject private var bookingViewModel = BookingViewModel()
    @State private var selectedFilter: BookingStatus?
    
    private let theme = Theme()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter buttons
                filterSection
                
                // Booking list
                if bookingViewModel.isLoading {
                    LoadingView()
                } else if filteredBookings.isEmpty {
                    emptyStateView
                } else {
                    bookingList
                }
            }
            .background(theme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("My Bookings")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            bookingViewModel.loadBookings()
        }
    }
    
    // MARK: - Filter Section
    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.smallSpacing) {
                FilterButton(
                    title: "All",
                    isSelected: selectedFilter == nil,
                    action: { selectedFilter = nil }
                )
                
                ForEach(BookingStatus.allCases, id: \.self) { status in
                    FilterButton(
                        title: status.rawValue,
                        isSelected: selectedFilter == status,
                        action: { selectedFilter = status }
                    )
                }
            }
            .padding(.horizontal, theme.largeSpacing)
        }
        .padding(.vertical, theme.spacing)
    }
    
    // MARK: - Booking List
    private var bookingList: some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing) {
                ForEach(filteredBookings, id: \.id) { booking in
                    BookingCard(booking: booking)
                        .padding(.horizontal, theme.largeSpacing)
                }
            }
            .padding(.bottom, theme.largeSpacing)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: theme.largeSpacing) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 60))
                .foregroundColor(theme.placeholderColor)
            
            VStack(spacing: theme.smallSpacing) {
                Text("No Bookings Found")
                    .font(theme.subtitleFont)
                    .foregroundColor(theme.textColor)
                
                Text("You haven't made any bookings yet")
                    .font(theme.captionFont)
                    .foregroundColor(theme.placeholderColor)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { /* Navigate to home */ }) {
                Text("Find Services")
                    .font(theme.buttonFont)
                    .foregroundColor(.white)
                    .padding(.horizontal, theme.largeSpacing)
                    .padding(.vertical, theme.spacing)
                    .background(theme.primaryGradient)
                    .cornerRadius(theme.cornerRadius)
            }
        }
        .padding(theme.largeSpacing)
    }
    
    // MARK: - Computed Properties
    private var filteredBookings: [Booking] {
        if let selectedFilter = selectedFilter {
            return bookingViewModel.bookings.filter { $0.status == selectedFilter }
        }
        return bookingViewModel.bookings
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    private let theme = Theme()
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(theme.captionFont)
                .foregroundColor(isSelected ? .white : theme.textColor)
                .padding(.horizontal, theme.spacing)
                .padding(.vertical, 8)
                .background(
                    isSelected ? AnyShapeStyle(theme.primaryGradient) : AnyShapeStyle(Color.white)
                )
                .cornerRadius(20)
                .shadow(color: theme.shadowColor, radius: 2, x: 0, y: 1)
        }
    }
}

// MARK: - Booking Card
struct BookingCard: View {
    let booking: Booking
    @State private var showingDetails = false
    
    private let theme = Theme()
    
    var body: some View {
        Button(action: { showingDetails.toggle() }) {
            VStack(alignment: .leading, spacing: theme.spacing) {
                // Header with status
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(booking.serviceType.rawValue)
                            .font(theme.subtitleFont)
                            .foregroundColor(theme.textColor)
                        
                        Text("Booking #\(booking.id.prefix(8).uppercased())")
                            .font(theme.captionFont)
                            .foregroundColor(theme.placeholderColor)
                    }
                    
                    Spacer()
                    
                    // Status badge
                    HStack(spacing: 4) {
                        Image(systemName: booking.status.icon)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        
                        Text(booking.status.rawValue)
                            .font(theme.captionFont)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(booking.status.color))
                    .cornerRadius(12)
                }
                
                // Details
                VStack(alignment: .leading, spacing: theme.smallSpacing) {
                    HStack(spacing: theme.smallSpacing) {
                        Image(systemName: "calendar")
                            .foregroundColor(theme.primaryColor)
                            .frame(width: 16)
                        
                        Text(booking.date.formatted(date: .abbreviated, time: .omitted))
                            .font(theme.bodyFont)
                            .foregroundColor(theme.textColor)
                    }
                    
                    HStack(spacing: theme.smallSpacing) {
                        Image(systemName: "clock")
                            .foregroundColor(theme.primaryColor)
                            .frame(width: 16)
                        
                        Text(booking.time.formatted(date: .omitted, time: .shortened))
                            .font(theme.bodyFont)
                            .foregroundColor(theme.textColor)
                    }
                    
                    HStack(spacing: theme.smallSpacing) {
                        Image(systemName: "location")
                            .foregroundColor(theme.primaryColor)
                            .frame(width: 16)
                        
                        Text(booking.address)
                            .font(theme.bodyFont)
                            .foregroundColor(theme.textColor)
                            .lineLimit(1)
                    }
                }
                
                // Cost
                HStack {
                    Text("Estimated Cost:")
                        .font(theme.captionFont)
                        .foregroundColor(theme.placeholderColor)
                    
                    Text("₹\(Int(booking.estimatedCost.lowerBound)) - ₹\(Int(booking.estimatedCost.upperBound))")
                        .font(theme.bodyFont)
                        .foregroundColor(theme.primaryColor)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(theme.placeholderColor)
                }
            }
            .padding(theme.spacing)
            .background(Color.white)
            .cornerRadius(theme.cornerRadius)
            .shadow(color: theme.shadowColor, radius: theme.shadowRadius, x: 0, y: theme.shadowY)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetails) {
            BookingDetailView(booking: booking)
        }
    }
}

// MARK: - Booking Detail View (Placeholder)
struct BookingDetailView: View {
    let booking: Booking
    @Environment(\.dismiss) private var dismiss
    
    private let theme = Theme()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing) {
                    Text("Booking Details")
                        .font(theme.titleFont)
                        .foregroundColor(theme.textColor)
                    
                    Text("Service: \(booking.serviceType.rawValue)")
                        .font(theme.bodyFont)
                        .foregroundColor(theme.textColor)
                    
                    Text("Status: \(booking.status.rawValue)")
                        .font(theme.bodyFont)
                        .foregroundColor(theme.textColor)
                    
                    Text("Description: \(booking.description)")
                        .font(theme.bodyFont)
                        .foregroundColor(theme.textColor)
                }
                .padding(theme.largeSpacing)
            }
            .background(theme.backgroundGradient.ignoresSafeArea())
            .navigationTitle("Booking Details")
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
    BookingHistoryView()
} 