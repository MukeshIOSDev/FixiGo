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
    @State private var selectedTab: Tab = .home
    @State private var showBookNowSheet = false
    @State private var isBookNowPressed = false
    
    enum Tab {
        case home, bookings, bookNow, chat, profile
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    DashboardView()
                        .environmentObject(authViewModel)
                case .bookings:
                    BookingHistoryView()
                case .chat:
                    ChatListView()
                        .environmentObject(authViewModel)
                case .profile:
                    UserProfileView()
                case .bookNow:
                    DashboardView()
                        .environmentObject(authViewModel) // fallback, should never be visible
                }
            }
            .edgesIgnoringSafeArea(.bottom)
            
            customTabBar
        }
        .sheet(isPresented: $showBookNowSheet) {
            BookingFormView()
        }
    }
    
    private var customTabBar: some View {
        HStack {
            tabBarButton(tab: .home, icon: "house.fill", label: "Home")
            Spacer()
            tabBarButton(tab: .bookings, icon: "calendar", label: "Bookings")
            Spacer()
            ZStack {
                Circle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.theme.primary, Color.theme.accent]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: isBookNowPressed ? 80 : 68, height: isBookNowPressed ? 80 : 68)
                    .shadow(color: Color.theme.primary.opacity(0.30), radius: 12, x: 0, y: 6)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )
                Button(action: { withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) { isBookNowPressed = true }; showBookNowSheet = true; DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { isBookNowPressed = false } }) {
                    VStack(spacing: 2) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.white)
                        Text("Book Now")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -2)
                .scaleEffect(isBookNowPressed ? 1.12 : 1.0)
            }
            .offset(y: -24)
            Spacer()
            tabBarButton(tab: .chat, icon: "bubble.left.and.bubble.right.fill", label: "Chat")
            Spacer()
            tabBarButton(tab: .profile, icon: "person.fill", label: "Profile")
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
        .frame(height: 70)
        .background(
            Color.white
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: -2)
        )
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func tabBarButton(tab: Tab, icon: String, label: String) -> some View {
        Button(action: { selectedTab = tab }) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(selectedTab == tab ? Color.theme.primary : Color.theme.placeholder)
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(selectedTab == tab ? Color.theme.primary : Color.theme.placeholder)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
