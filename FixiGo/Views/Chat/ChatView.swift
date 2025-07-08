import SwiftUI

struct ChatView: View {
    let worker: Worker
    @Environment(\.dismiss) private var dismiss
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var messageText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    private let theme = Theme()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: theme.spacing) {
                            ForEach(chatViewModel.messages, id: \.id) { message in
                                MessageBubble(message: message, isFromCurrentUser: message.senderId == "currentUser")
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal, theme.largeSpacing)
                        .padding(.vertical, theme.spacing)
                    }
                    .onChange(of: chatViewModel.messages.count) { _, _ in
                        if let lastMessage = chatViewModel.messages.last {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Message input
                messageInputSection
            }
            .background(theme.backgroundGradient.ignoresSafeArea())
            .navigationTitle(worker.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(theme.buttonFont)
                    .foregroundColor(theme.primaryColor)
                }
            }
        }
        .onAppear {
            chatViewModel.loadMessages(for: worker.id)
        }
    }
    
    // MARK: - Message Input Section
    private var messageInputSection: some View {
        VStack(spacing: 0) {
            Divider()
                .background(theme.borderColor)
            
            HStack(spacing: theme.smallSpacing) {
                TextField("Type a message...", text: $messageText, axis: .vertical)
                    .font(theme.bodyFont)
                    .foregroundColor(theme.textColor)
                    .padding(theme.spacing)
                    .background(Color.white)
                    .cornerRadius(20)
                    .focused($isTextFieldFocused)
                    .lineLimit(1...4)
                
                Button(action: {
                    Task {
                        await sendMessage()
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                            theme.placeholderColor : theme.primaryColor
                        )
                        .clipShape(Circle())
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, theme.largeSpacing)
            .padding(.vertical, theme.spacing)
            .background(Color.white)
        }
    }
    
    // MARK: - Send Message
    private func sendMessage() async {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        await chatViewModel.sendMessage(trimmedMessage, to: worker.id)
        messageText = ""
        isTextFieldFocused = false
    }
}

// MARK: - Message Bubble
struct MessageBubble: View {
    let message: ChatMessage
    let isFromCurrentUser: Bool
    
    private let theme = Theme()
    
    var body: some View {
        HStack {
            if isFromCurrentUser {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(theme.bodyFont)
                    .foregroundColor(isFromCurrentUser ? .white : theme.textColor)
                    .padding(.horizontal, theme.spacing)
                    .padding(.vertical, theme.smallSpacing)
                    .background(
                        isFromCurrentUser ? theme.primaryColor : Color.white
                    )
                    .cornerRadius(16)
                    .shadow(color: theme.shadowColor, radius: 2, x: 0, y: 1)
                
                Text(message.timestamp, style: .time)
                    .font(theme.captionFont)
                    .foregroundColor(theme.placeholderColor)
            }
            
            if !isFromCurrentUser {
                Spacer(minLength: 50)
            }
        }
    }
}

#Preview {
    ChatView(worker: Worker(
        id: "1",
        name: "Rajesh Kumar",
        email: "rajesh@example.com",
        phone: "+91 98765 43210",
        address: "Mumbai, Maharashtra",
        services: [.plumber, .electrician],
        rating: 4.5,
        totalJobs: 127,
        isVerified: true,
        createdAt: Date()
    ))
} 