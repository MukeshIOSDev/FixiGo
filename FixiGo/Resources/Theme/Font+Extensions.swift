import SwiftUI

extension Font {
    // MARK: - Poppins Font Registration
    static func registerPoppinsFonts() {
        // Register Poppins fonts
        if let fontURL = Bundle.main.url(forResource: "Poppins-Regular", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
        
        if let fontURL = Bundle.main.url(forResource: "Poppins-Medium", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
        
        if let fontURL = Bundle.main.url(forResource: "Poppins-SemiBold", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
        
        if let fontURL = Bundle.main.url(forResource: "Poppins-Bold", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
        
        if let fontURL = Bundle.main.url(forResource: "Poppins-ExtraBold", withExtension: "ttf") {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        }
    }
    
    // MARK: - Poppins Font Convenience Methods
    static func poppins(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let fontName: String
        
        switch weight {
        case .bold:
            fontName = "Poppins-ExtraBold" // Use ExtraBold for more pronounced bold effect
        case .semibold:
            fontName = "Poppins-SemiBold"
        case .medium:
            fontName = "Poppins-Medium"
        default:
            fontName = "Poppins-Regular"
        }
        
        return Font.custom(fontName, size: size)
    }
    
    // MARK: - Predefined Poppins Fonts
    static let poppinsTitle = poppins(size: 28, weight: .bold) // This will now use ExtraBold
    static let poppinsSubtitle = poppins(size: 18, weight: .medium)
    static let poppinsBody = poppins(size: 16, weight: .regular)
    static let poppinsButton = poppins(size: 18, weight: .semibold)
    static let poppinsCaption = poppins(size: 14, weight: .medium)
    static let poppinsLarge = poppins(size: 24, weight: .semibold)
    static let poppinsSmall = poppins(size: 12, weight: .regular)
    static let poppinsExtraBold = Font.custom("Poppins-ExtraBold", size: 28) // Direct ExtraBold for maximum emphasis
} 