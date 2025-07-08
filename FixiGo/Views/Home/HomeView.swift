import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var searchText = ""
    @State private var selectedService: ServiceType?
    @State private var showingFilters = false
    @State private var showingMap = false
    
    private let theme = Theme()
    
    var body: some View {
        NavigationView {
            ZStack {
                theme.backgroundGradient.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with search and filters
                    headerSection
                    
                    // Service type quick filters
                    serviceTypeFilters
                    
                    // Main content
                    if homeViewModel.isLoading {
                        LoadingView()
                    } else if homeViewModel.workers.isEmpty {
                        emptyStateView
                    } else {
                        workerListView
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            homeViewModel.fetchNearbyWorkers()
        }
        .sheet(isPresented: $showingMap) {
            MapWorkerListView(workers: homeViewModel.workers)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: theme.spacing) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Find Local Services")
                        .font(theme.titleFont)
                        .foregroundColor(theme.textColor)
                    
                    Text("Discover trusted professionals near you")
                        .font(theme.captionFont)
                        .foregroundColor(theme.placeholderColor)
                }
                
                Spacer()
                
                Button(action: { showingMap.toggle() }) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 20))
                        .foregroundColor(theme.primaryColor)
                        .frame(width: 44, height: 44)
                        .background(theme.primaryColor.opacity(0.1))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, theme.largeSpacing)
            .padding(.top, theme.spacing)
            
            // Search Bar
            HStack(spacing: theme.smallSpacing) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(theme.placeholderColor)
                
                TextField("Search for services...", text: $searchText)
                    .font(theme.bodyFont)
                    .foregroundColor(theme.textColor)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(theme.placeholderColor)
                    }
                }
            }
            .padding(theme.spacing)
            .background(Color.white)
            .cornerRadius(theme.cornerRadius)
            .shadow(color: theme.shadowColor, radius: theme.shadowRadius, x: 0, y: theme.shadowY)
            .padding(.horizontal, theme.largeSpacing)
        }
        .padding(.bottom, theme.spacing)
    }
    
    // MARK: - Service Type Filters
    private var serviceTypeFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.smallSpacing) {
                ForEach(ServiceType.allCases, id: \.self) { service in
                    ServiceFilterButton(
                        service: service,
                        isSelected: selectedService == service,
                        action: {
                            if selectedService == service {
                                selectedService = nil
                            } else {
                                selectedService = service
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, theme.largeSpacing)
        }
        .padding(.bottom, theme.spacing)
    }
    
    // MARK: - Worker List View
    private var workerListView: some View {
        ScrollView {
            LazyVStack(spacing: theme.spacing) {
                ForEach(filteredWorkers, id: \.id) { worker in
                    WorkerCardView(worker: worker)
                        .padding(.horizontal, theme.largeSpacing)
                }
            }
            .padding(.bottom, theme.largeSpacing)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: theme.largeSpacing) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundColor(theme.placeholderColor)
            
            VStack(spacing: theme.smallSpacing) {
                Text("No Workers Found")
                    .font(theme.subtitleFont)
                    .foregroundColor(theme.textColor)
                
                Text("Try adjusting your search or check back later")
                    .font(theme.captionFont)
                    .foregroundColor(theme.placeholderColor)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { homeViewModel.fetchNearbyWorkers() }) {
                Text("Refresh")
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
    private var filteredWorkers: [Worker] {
        var workers = homeViewModel.workers
        
        // Filter by search text
        if !searchText.isEmpty {
            workers = workers.filter { worker in
                worker.name.localizedCaseInsensitiveContains(searchText) ||
                worker.services.contains { service in
                    service.rawValue.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        
        // Filter by selected service
        if let selectedService = selectedService {
            workers = workers.filter { worker in
                worker.services.contains(selectedService)
            }
        }
        
        return workers
    }
}

// MARK: - Service Filter Button
struct ServiceFilterButton: View {
    let service: ServiceType
    let isSelected: Bool
    let action: () -> Void
    
    private let theme = Theme()
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: service.icon)
                    .font(.system(size: 14, weight: .medium))
                
                Text(service.rawValue)
                    .font(theme.captionFont)
            }
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

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
} 