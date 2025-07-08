import SwiftUI

struct ServiceTypeButton: View {
    let service: ServiceType
    let isSelected: Bool
    let action: () -> Void
    
    private let theme = Theme()
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: theme.smallSpacing) {
                Image(systemName: service.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : theme.primaryColor)
                
                Text(service.rawValue)
                    .font(theme.captionFont)
                    .foregroundColor(isSelected ? .white : theme.textColor)
                    .lineLimit(1)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, theme.spacing)
            .padding(.vertical, theme.smallSpacing)
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