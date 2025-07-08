import Foundation
import Firebase
import FirebaseDatabase
import FirebaseFirestore
import Combine

@MainActor
class ChatService: ObservableObject, Sendable {
    @Published var messages: [ChatMessage] = []
    @Published var newMessages: ChatMessage?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let database = Database.database().reference()
    private let firestore = Firestore.firestore()
    private var chatListener: DatabaseHandle?
    
    // MARK: - Real-time Chat Listening
    func startListeningToChat(userId1: String, userId2: String) {
        let chatId = [userId1, userId2].sorted().joined(separator: "_")
        let chatRef = database.child("chats").child(chatId).child("messages")
        
        chatListener = chatRef.observe(.childAdded) { [weak self] snapshot in
            guard let self = self,
                  let data = snapshot.value as? [String: Any] else { return }
            
            Task {
                do {
                    let message = try self.parseMessage(from: data, id: snapshot.key)
                    await MainActor.run {
                        self.messages.append(message)
                        self.newMessages = message
                    }
                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
    
    func stopListeningToChat() {
        if let listener = chatListener {
            database.removeObserver(withHandle: listener)
            chatListener = nil
        }
    }
    
    // MARK: - Message Operations
    func sendMessage(_ message: ChatMessage) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let chatId = [message.senderId, message.receiverId].sorted().joined(separator: "_")
            let messageRef = database.child("chats").child(chatId).child("messages").childByAutoId()
            
            let messageData: [String: Any] = [
                "senderId": message.senderId,
                "receiverId": message.receiverId,
                "content": message.content,
                "messageType": message.messageType.rawValue,
                "timestamp": ServerValue.timestamp(),
                "isRead": false
            ]
            
            try await messageRef.setValue(messageData)
            
            // Also save to Firestore for persistence
            try await saveMessageToFirestore(message)
            
            isLoading = false
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
    }
    
    func markMessageAsRead(messageId: String, chatId: String) async throws {
        let messageRef = database.child("chats").child(chatId).child("messages").child(messageId)
        try await messageRef.updateChildValues(["isRead": true])
    }
    
    func markAllMessagesAsRead(chatId: String) async throws {
        let messagesRef = database.child("chats").child(chatId).child("messages")
        let snapshot = try await messagesRef.getData()
        
        guard let messages = snapshot.value as? [String: [String: Any]] else { return }
        
        for (messageId, messageData) in messages {
            if let isRead = messageData["isRead"] as? Bool, !isRead {
                try await messagesRef.child(messageId).updateChildValues(["isRead": true])
            }
        }
    }
    
    // MARK: - Chat History
    func loadChatHistory(userId1: String, userId2: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let chatId = [userId1, userId2].sorted().joined(separator: "_")
            let snapshot = try await database.child("chats").child(chatId).child("messages").getData()
            
            guard let messagesData = snapshot.value as? [String: [String: Any]] else {
                messages = []
                isLoading = false
                return
            }
            
            let loadedMessages = try messagesData.compactMap { (id, data) in
                try parseMessage(from: data, id: id)
            }.sorted { $0.timestamp < $1.timestamp }
            
            messages = loadedMessages
            isLoading = false
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
    }
    
    // MARK: - Chat List Management
    func getChatList(for userId: String) async throws -> [ChatSummary] {
        let snapshot = try await database.child("userChats").child(userId).getData()
        
        guard let chatData = snapshot.value as? [String: [String: Any]] else {
            return []
        }
        
        var chatSummaries: [ChatSummary] = []
        
        for (chatId, data) in chatData {
            if let lastMessage = data["lastMessage"] as? String,
               let timestamp = data["lastMessageTime"] as? TimeInterval,
               let otherUserId = data["otherUserId"] as? String {
                
                let chatSummary = ChatSummary(
                    chatId: chatId,
                    otherUserId: otherUserId,
                    lastMessage: lastMessage,
                    lastMessageTime: Date(timeIntervalSince1970: timestamp / 1000),
                    unreadCount: data["unreadCount"] as? Int ?? 0
                )
                chatSummaries.append(chatSummary)
            }
        }
        
        return chatSummaries.sorted { $0.lastMessageTime > $1.lastMessageTime }
    }
    
    func updateChatSummary(chatId: String, userId: String, otherUserId: String, lastMessage: String) async throws {
        let userChatRef = database.child("userChats").child(userId).child(chatId)
        let otherUserChatRef = database.child("userChats").child(otherUserId).child(chatId)
        
        let chatData: [String: Any] = [
            "lastMessage": lastMessage,
            "lastMessageTime": ServerValue.timestamp(),
            "otherUserId": otherUserId
        ]
        
        try await userChatRef.setValue(chatData)
        try await otherUserChatRef.setValue(chatData)
    }
    
    // MARK: - Helper Methods
    private func parseMessage(from data: [String: Any], id: String) throws -> ChatMessage {
        guard let senderId = data["senderId"] as? String,
              let receiverId = data["receiverId"] as? String,
              let content = data["content"] as? String,
              let messageTypeRaw = data["messageType"] as? String,
              let messageType = MessageType(rawValue: messageTypeRaw),
              let timestamp = data["timestamp"] as? TimeInterval else {
            throw ChatError.invalidMessageData
        }
        
        let isRead = data["isRead"] as? Bool ?? false
        
        return ChatMessage(
            id: id,
            content: content,
            senderId: senderId,
            receiverId: receiverId,
            timestamp: Date(timeIntervalSince1970: timestamp / 1000),
            isRead: isRead,
            messageType: messageType
        )
    }
    
    private func saveMessageToFirestore(_ message: ChatMessage) async throws {
        let chatId = [message.senderId, message.receiverId].sorted().joined(separator: "_")
        try firestore.collection("chats")
            .document(chatId)
            .collection("messages")
            .document(message.id)
            .setData(from: message)
    }
}

// MARK: - Supporting Models
struct ChatSummary {
    let chatId: String
    let otherUserId: String
    let lastMessage: String
    let lastMessageTime: Date
    let unreadCount: Int
}

// MARK: - Custom Errors
enum ChatError: LocalizedError {
    case invalidMessageData
    case networkError
    case permissionDenied
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidMessageData:
            return "Invalid message data format"
        case .networkError:
            return "Network error. Please check your connection"
        case .permissionDenied:
            return "Permission denied"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 