import SwiftUI

struct SplashView: View {
    @State private var isAnimating = false
    @State private var showContent = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoRotation: Double = 0
    @State private var textOpacity: Double = 0
    @State private var dotsOffset: [CGFloat] = [0, 0, 0]
    private let theme = Theme()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            theme.backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Professional Logo matching LoginView
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(theme.primaryGradient, lineWidth: 2)
                        .frame(width: 90, height: 90)
                        .scaleEffect(logoScale)
                    
                    // Main logo
                    Circle()
                        .fill(theme.primaryGradient)
                        .frame(width: 70, height: 70)
                        .shadow(color: theme.primaryColor.opacity(0.2), radius: theme.shadowRadius, x: 0, y: theme.shadowY)
                    
                    // Service icon
                    VStack(spacing: 2) {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.system(size: 25, weight: .medium))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(logoRotation))
                        
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .rotationEffect(.degrees(-logoRotation * 0.5))
                    }
                }
                
                // App branding with professional typography
                VStack(spacing: 12) {
                    if colorScheme == .light {
                        LinearGradient(
                            colors: [theme.primaryColor, theme.secondaryColor, theme.accentColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(
                            Text("Fixigo")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                        )
                    } else {
                        Text("Fixigo")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(theme.primaryColor)
                    }
                    
                    Text("Professional Service Solutions")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color("#64748B"))
                        .opacity(textOpacity)
                        .offset(y: textOpacity == 0 ? 30 : 0)
                    
                    // Service highlights
                    HStack(spacing: 20) {
                        ServiceHighlight(icon: "checkmark.circle.fill", text: "Trusted")
                        ServiceHighlight(icon: "clock.fill", text: "Fast")
                        ServiceHighlight(icon: "star.fill", text: "Quality")
                    }
                    .opacity(textOpacity)
                    .offset(y: textOpacity == 0 ? 30 : 0)
                }
                
                // Professional loading indicator
                HStack(spacing: 12) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color("#146C94"), Color("#19A7CE")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 10, height: 10)
                            .scaleEffect(isAnimating ? 1.3 : 0.7)
                            .offset(y: dotsOffset[index])
                            .animation(
                                .easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
                .opacity(textOpacity)
                .offset(y: textOpacity == 0 ? 30 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Start logo animations
        withAnimation(.easeOut(duration: 1.0)) {
            logoScale = 1.0
        }
        
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            logoRotation = 360
        }
        
        // Start general animations
        isAnimating = true
        
        // Animate dots
        for i in 0..<3 {
            withAnimation(
                .easeInOut(duration: 0.8)
                .repeatForever(autoreverses: true)
                .delay(Double(i) * 0.2)
            ) {
                dotsOffset[i] = -10
            }
        }
        
        // Reveal content with staggered animation
        withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
            textOpacity = 1.0
        }
    }
}

// Service highlight component
struct ServiceHighlight: View {
    let icon: String
    let text: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("#146C94"))
            
            Text(text)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color("#64748B"))
        }
    }
} 