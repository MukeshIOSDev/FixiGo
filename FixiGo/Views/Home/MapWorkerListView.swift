import SwiftUI
import MapKit

struct MapWorkerListView: View {
    let workers: [Worker]
    @Environment(\.dismiss) private var dismiss
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777), // Mumbai
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedWorker: Worker?
    @State private var showingWorkerProfile = false
    
    private let theme = Theme()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map
                Map(coordinateRegion: $region, annotationItems: workers) { worker in
                    MapAnnotation(coordinate: worker.coordinate) {
                        WorkerMapAnnotation(
                            worker: worker,
                            isSelected: selectedWorker?.id == worker.id
                        ) {
                            selectedWorker = worker
                        }
                    }
                }
                .ignoresSafeArea()
                
                // Bottom sheet with worker details
                VStack {
                    Spacer()
                    
                    if let selectedWorker = selectedWorker {
                        WorkerMapCard(worker: selectedWorker) {
                            showingWorkerProfile = true
                        }
                        .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationTitle("Nearby Workers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(theme.buttonFont)
                    .foregroundColor(theme.primaryColor)
                }
            }
        }
        .sheet(isPresented: $showingWorkerProfile) {
            if let worker = selectedWorker {
                WorkerProfileView(worker: worker)
            }
        }
    }
}

// MARK: - Worker Map Annotation
struct WorkerMapAnnotation: View {
    let worker: Worker
    let isSelected: Bool
    let action: () -> Void
    
    private let theme = Theme()
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Worker avatar
                ZStack {
                    Circle()
                        .fill(isSelected ? theme.accentColor : theme.primaryColor)
                        .frame(width: 40, height: 40)
                    
                    Text(worker.name.prefix(1).uppercased())
                        .font(.poppins(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
                
                // Rating badge
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                        .foregroundColor(theme.accentColor)
                    
                    Text(String(format: "%.1f", worker.rating))
                        .font(.poppins(size: 10, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(theme.accentColor)
                .cornerRadius(8)
                .offset(y: -5)
            }
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Worker Map Card
struct WorkerMapCard: View {
    let worker: Worker
    let onTap: () -> Void
    
    private let theme = Theme()
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: theme.smallSpacing) {
                HStack {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(theme.primaryGradient)
                            .frame(width: 50, height: 50)
                        
                        Text(worker.name.prefix(1).uppercased())
                            .font(.poppins(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(worker.name)
                                .font(theme.subtitleFont)
                                .foregroundColor(theme.textColor)
                            
                            if worker.isVerified {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(theme.accentColor)
                                    .font(.system(size: 14))
                            }
                        }
                        
                        // Rating
                        HStack(spacing: 4) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(worker.rating) ? "star.fill" : "star")
                                    .font(.system(size: 10))
                                    .foregroundColor(index < Int(worker.rating) ? theme.accentColor : theme.placeholderColor)
                            }
                            
                            Text(String(format: "%.1f", worker.rating))
                                .font(theme.captionFont)
                                .foregroundColor(theme.textColor)
                        }
                    }
                    
                    Spacer()
                    
                    // Services
                    VStack(alignment: .trailing, spacing: 4) {
                        ForEach(Array(worker.services.prefix(2)), id: \.self) { service in
                            Text(service.rawValue)
                                .font(.poppins(size: 10, weight: .medium))
                                .foregroundColor(theme.primaryColor)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(theme.primaryColor.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                
                // Action buttons
                HStack {
                    Button(action: { /* Chat action */ }) {
                        HStack(spacing: 4) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 12))
                            Text("Chat")
                                .font(theme.captionFont)
                        }
                        .foregroundColor(theme.primaryColor)
                        .padding(.horizontal, theme.spacing)
                        .padding(.vertical, 6)
                        .background(theme.primaryColor.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                    Button(action: { /* Book action */ }) {
                        Text("Book Now")
                            .font(theme.captionFont)
                            .foregroundColor(.white)
                            .padding(.horizontal, theme.spacing)
                            .padding(.vertical, 6)
                            .background(theme.primaryGradient)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(theme.spacing)
            .background(Color.white)
            .cornerRadius(theme.cornerRadius)
            .shadow(color: theme.shadowColor, radius: theme.shadowRadius, x: 0, y: theme.shadowY)
            .padding(.horizontal, theme.largeSpacing)
            .padding(.bottom, theme.largeSpacing)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MapWorkerListView(workers: [
        Worker(
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
        )
    ])
} 