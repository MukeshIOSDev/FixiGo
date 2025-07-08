import SwiftUI

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    @Published var currentTheme: Theme = Theme()
    
    private init() {}
    
    // For future: Add methods to switch themes, persist user preference, etc.
} 