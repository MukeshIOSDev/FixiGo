import Foundation
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let chatService: ChatService
    
    init() {
        self.chatService = ChatService()
        setupMessageUpdates()
    }
    
    // MARK: - Public Methods
    func loadMessages(for workerId: String) {
        isLoading = true
        errorMessage = nil
        
        // For now, we'll use mock data
        // In production, this would fetch from Firestore
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.messages = self.generateMockMessages(for: workerId)
            self.isLoading = false
        }
    }
    
    func sendMessage(_ content: String, to workerId: String) async {
        let newMessage = ChatMessage(
            content: content,
            senderId: "currentUser",
            receiverId: workerId
        )
        
        // Add message to local array immediately for instant feedback
        messages.append(newMessage)
        
        // In production, this would send to Firestore
        do {
            try await chatService.sendMessage(newMessage)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Private Methods
    private func setupMessageUpdates() {
        chatService.$newMessages
            .compactMap { $0 }
            .sink { [weak self] message in
                self?.messages.append(message)
            }
            .store(in: &cancellables)
    }
    
    private func generateMockMessages(for workerId: String) -> [ChatMessage] {
        return [
            ChatMessage(
                id: "1",
                content: "Hi! I need help with plumbing work. Are you available today?",
                senderId: "currentUser",
                receiverId: workerId,
                timestamp: Date().addingTimeInterval(-3600),
                isRead: true
            ),
            ChatMessage(
                id: "2",
                content: "Hello! Yes, I'm available. What kind of plumbing work do you need?",
                senderId: workerId,
                receiverId: "currentUser",
                timestamp: Date().addingTimeInterval(-3500),
                isRead: true
            ),
            ChatMessage(
                id: "3",
                content: "I have a leaking tap in my kitchen. Can you fix it?",
                senderId: "currentUser",
                receiverId: workerId,
                timestamp: Date().addingTimeInterval(-3400),
                isRead: true
            ),
            ChatMessage(
                id: "4",
                content: "Sure! I can help with that. What's your address and when would you like me to come?",
                senderId: workerId,
                receiverId: "currentUser",
                timestamp: Date().addingTimeInterval(-3300),
                isRead: true
            )
        ]
    }
} 