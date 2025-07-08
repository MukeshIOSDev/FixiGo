import SwiftUI

struct Theme {
    // MARK: - Colors
    let primaryColor = Color("PrimaryColor")
    let secondaryColor = Color("SecondaryColor")
    let accentColor = Color("AccentColor")
    let backgroundColor = Color("BackgroundColor")
    let textColor = Color("TextColor")
    let placeholderColor = Color("PlaceholderColor")
    let borderColor = Color("BorderColor")
    let errorColor = Color("#EF4444")
    let successColor = Color("#10B981")
    
    // MARK: - Theme Properties (for Color.theme access)
    var primary: Color { primaryColor }
    var secondary: Color { secondaryColor }
    var accent: Color { accentColor }
    var background: Color { backgroundColor }
    var text: Color { textColor }
    var textSecondary: Color { textColor.opacity(0.7) }
    var placeholder: Color { placeholderColor }
    var border: Color { borderColor }
    var surface: Color { Color.white }
    var error: Color { errorColor }
    var success: Color { successColor }
    
    // MARK: - Modern Colors
    let primaryGradient = LinearGradient(
        colors: [Color("PrimaryColor"), Color("SecondaryColor")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    let accentGradient = LinearGradient(
        colors: [Color("AccentColor"), Color.orange],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    let backgroundGradient = LinearGradient(
        colors: [Color("BackgroundColor"), Color("BackgroundColor")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    // MARK: - Social Colors
    let googleColor = Color("#DB4437")
    let appleColor = Color.black
    let facebookColor = Color("#1877F2")
    
    // MARK: - UI Colors
    let cardBackground = Color.white
    let shadowColor = Color.black.opacity(0.1)
    
    // MARK: - Fonts
    let titleFont = Font.poppinsTitle
    let subtitleFont = Font.poppinsSubtitle
    let bodyFont = Font.poppinsBody
    let buttonFont = Font.poppinsButton
    let captionFont = Font.poppinsCaption
    
    // MARK: - Spacing
    let spacing: CGFloat = 16
    let largeSpacing: CGFloat = 24
    let smallSpacing: CGFloat = 8
    
    // MARK: - Corner Radius
    let cornerRadius: CGFloat = 16
    let smallCornerRadius: CGFloat = 8
    let largeCornerRadius: CGFloat = 24
    
    // MARK: - Shadows
    let shadowRadius: CGFloat = 10
    let shadowY: CGFloat = 4
} 
