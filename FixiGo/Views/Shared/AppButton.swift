import SwiftUI

struct AppButton: View {
    var title: String
    var action: () -> Void
    var style: ButtonStyle = .primary
    var isLoading: Bool = false
    var icon: String? = nil
    var isDisabled: Bool = false
    
    private let theme = Theme()
    @Environment(\.colorScheme) private var colorScheme
    
    enum ButtonStyle {
        case primary, secondary, social
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style == .primary ? Color.white : buttonForeground))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .medium))
                    }
                    Text(title)
                        .font(theme.subtitleFont)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(buttonBackground)
            .foregroundColor(buttonForeground)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(buttonBorder, lineWidth: 1.5)
            )
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .disabled(isLoading || isDisabled)
        .opacity(isLoading || isDisabled ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
        .animation(.easeInOut(duration: 0.2), value: isDisabled)
    }
    
    private var buttonBackground: Color {
        switch style {
        case .primary:
            return theme.primaryColor
        case .secondary:
            return Color.clear
        case .social:
            return colorScheme == .dark ? Color("#222831") : Color.white
        }
    }
    
    private var buttonForeground: Color {
        switch style {
        case .primary:
            return Color.white
        case .secondary:
            return theme.primaryColor
        case .social:
            return colorScheme == .dark ? Color.white : theme.textColor
        }
    }
    
    private var buttonBorder: Color {
        switch style {
        case .primary:
            return Color.clear
        case .secondary:
            return theme.primaryColor
        case .social:
            return theme.borderColor
        }
    }
} 
