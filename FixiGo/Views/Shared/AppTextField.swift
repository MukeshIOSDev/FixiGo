import SwiftUI
import UIKit

struct AppTextField: View {
    var placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var validationState: ValidationState = .neutral
    
    @State private var isSecured: Bool = true
    private let theme = Theme()
    
    enum ValidationState {
        case neutral, valid, error
        
        var color: Color {
            switch self {
            case .neutral: return Color("#E2E8F0")
            case .valid: return Color("#10B981")
            case .error: return Color("#EF4444")
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(validationState.color)
                    .frame(width: 20)
            }
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(theme.placeholderColor)
                        .padding(.leading, icon == nil ? 0 : 0)
                }
                if isSecure && isSecured {
                    SecureField("", text: $text)
                        .foregroundColor(theme.textColor)
                        .textContentType(textContentType)
                        .keyboardType(keyboardType)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                } else {
                    TextField("", text: $text)
                        .foregroundColor(theme.textColor)
                        .textContentType(textContentType)
                        .keyboardType(keyboardType)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            if isSecure {
                Button(action: { isSecured.toggle() }) {
                    Image(systemName: isSecured ? "eye.slash" : "eye")
                        .foregroundColor(theme.placeholderColor)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(validationState.color, lineWidth: 1.5)
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
        .animation(.easeInOut(duration: 0.2), value: validationState)
    }
} 