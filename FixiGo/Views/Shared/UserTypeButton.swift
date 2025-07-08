import SwiftUI

struct UserTypeButton: View {
    let type: UserType
    let isSelected: Bool
    let action: () -> Void
    
    private let theme = Theme()
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: theme.smallSpacing) {
                Image(systemName: type.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .white : theme.primaryColor)
                
                Text(type.rawValue)
                    .font(theme.bodyFont)
                    .foregroundColor(isSelected ? .white : theme.textColor)
                
                Text(type.description)
                    .font(theme.captionFont)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : theme.placeholderColor)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(theme.spacing)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(isSelected ? theme.primaryColor : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.cornerRadius)
                            .stroke(isSelected ? Color.clear : theme.borderColor, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 