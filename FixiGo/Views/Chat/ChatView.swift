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

struct ChatListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedChat: ChatPreview? = nil
    private let theme = Theme()
    
    // Mock chat previews
    private var chatPreviews: [ChatPreview] {
        // In production, fetch from backend
        if let user = authViewModel.currentUser {
            if user.userType == .customer {
                return [
                    ChatPreview(id: "w1", name: "Rajesh Kumar", lastMessage: "Sure, I can come at 5pm.", time: "2m ago", unreadCount: 1, avatar: "R", isOnline: true),
                    ChatPreview(id: "w2", name: "Anita Sharma", lastMessage: "Thank you for the review!", time: "1h ago", unreadCount: 0, avatar: "A", isOnline: false)
                ]
            } else {
                return [
                    ChatPreview(id: "c1", name: "Priya Singh", lastMessage: "Can you come tomorrow?", time: "5m ago", unreadCount: 2, avatar: "P", isOnline: true),
                    ChatPreview(id: "c2", name: "Amit Patel", lastMessage: "Payment done.", time: "3h ago", unreadCount: 0, avatar: "A", isOnline: false)
                ]
            }
        }
        return []
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                theme.backgroundGradient.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Chats")
                            .font(theme.titleFont)
                            .foregroundColor(theme.primaryColor)
                        Spacer()
                    }
                    .padding(.horizontal, theme.largeSpacing)
                    .padding(.top, theme.largeSpacing)
                    
                    if chatPreviews.isEmpty {
                        VStack(spacing: theme.largeSpacing) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 60))
                                .foregroundColor(theme.placeholderColor)
                            Text("No conversations yet")
                                .font(theme.subtitleFont)
                                .foregroundColor(theme.textColor)
                        }
                        .padding(.top, 100)
                    } else {
                        ScrollView {
                            VStack(spacing: theme.spacing) {
                                ForEach(chatPreviews) { chat in
                                    Button(action: { selectedChat = chat }) {
                                        HStack(spacing: theme.spacing) {
                                            ZStack {
                                                Circle()
                                                    .fill(theme.primaryGradient)
                                                    .frame(width: 54, height: 54)
                                                Text(chat.avatar)
                                                    .font(.poppins(size: 22, weight: .bold))
                                                    .foregroundColor(.white)
                                                if chat.isOnline {
                                                    Circle()
                                                        .fill(theme.successColor)
                                                        .frame(width: 14, height: 14)
                                                        .offset(x: 20, y: 20)
                                                }
                                            }
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(chat.name)
                                                    .font(theme.subtitleFont)
                                                    .foregroundColor(theme.textColor)
                                                Text(chat.lastMessage)
                                                    .font(theme.captionFont)
                                                    .foregroundColor(theme.placeholderColor)
                                                    .lineLimit(1)
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing, spacing: 6) {
                                                Text(chat.time)
                                                    .font(theme.captionFont)
                                                    .foregroundColor(theme.placeholderColor)
                                                if chat.unreadCount > 0 {
                                                    Text("\(chat.unreadCount)")
                                                        .font(.poppins(size: 12, weight: .bold))
                                                        .foregroundColor(.white)
                                                        .padding(6)
                                                        .background(theme.accentColor)
                                                        .clipShape(Circle())
                                                }
                                            }
                                        }
                                        .padding(theme.spacing)
                                        .background(theme.cardBackground)
                                        .cornerRadius(theme.cornerRadius)
                                        .shadow(color: theme.shadowColor, radius: 4, x: 0, y: 2)
                                    }
                                }
                            }
                            .padding(.horizontal, theme.largeSpacing)
                            .padding(.top, theme.spacing)
                        }
                    }
                }
            }
            .sheet(item: $selectedChat) { chat in
                // For now, show a mock worker for ChatView
                ChatView(worker: Worker(
                    id: chat.id,
                    name: chat.name,
                    email: "",
                    phone: "",
                    address: "",
                    services: [.plumber],
                    rating: 4.5,
                    totalJobs: 10,
                    isVerified: true,
                    createdAt: Date()
                ))
            }
        }
    }
}

struct ChatPreview: Identifiable, Hashable {
    let id: String
    let name: String
    let lastMessage: String
    let time: String
    let unreadCount: Int
    let avatar: String
    let isOnline: Bool
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