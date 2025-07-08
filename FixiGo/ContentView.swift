//
//  ContentView.swift
//  FixiGo
//
//  Created by Mukesh Behera on 26/06/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var notificationService = NotificationService()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(notificationService)
            } else {
                OnboardingView()
                    .environmentObject(authViewModel)
            }
        }
        .onAppear {
            // Setup notification categories when app launches
            notificationService.setupNotificationCategories()
        }
    }
}

struct OnboardingView: View {
    @State private var currentPage: OnboardingPage = .splash
    @EnvironmentObject var authViewModel: AuthViewModel
    
    enum OnboardingPage {
        case splash, login, signup
    }
    
    var body: some View {
        ZStack {
            // Background
            Color.theme.background
                .ignoresSafeArea()
            
            switch currentPage {
            case .splash:
                SplashView()
                    .onAppear {
                        // Auto-transition to login after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                currentPage = .login
                            }
                        }
                    }
                
            case .login:
                LoginView(
                    onSignInSuccess: {
                        // Auth state will be handled by AuthService
                    },
                    onShowSignup: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentPage = .signup
                        }
                    }
                )
                .environmentObject(authViewModel)
                .transition(.move(edge: .trailing))
                
            case .signup:
                SignupView(
                    onSignupSuccess: {
                        // Auth state will be handled by AuthService
                    },
                    onShowLogin: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            currentPage = .login
                        }
                    }
                )
                .environmentObject(authViewModel)
                .transition(.move(edge: .trailing))
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var notificationService: NotificationService
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            BookingHistoryView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Bookings")
                }
            
            UserProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(Color.theme.primary)
        .onAppear {
            // Request notification permissions when user is authenticated
            if !notificationService.isPermissionGranted {
                // Permission request is handled in NotificationService init
            }
        }
    }
}

#Preview {
    ContentView()
}
