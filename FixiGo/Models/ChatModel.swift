import Foundation

enum MessageType: String, Codable, CaseIterable {
    case text = "text"
    case image = "image"
    case file = "file"
    case location = "location"
}

struct ChatMessage: Identifiable, Codable {
    let id: String
    let content: String
    let senderId: String
    let receiverId: String
    let timestamp: Date
    let isRead: Bool
    let messageType: MessageType
    
    init(id: String = UUID().uuidString,
         content: String,
         senderId: String,
         receiverId: String,
         timestamp: Date = Date(),
         isRead: Bool = false,
         messageType: MessageType = .text) {
        self.id = id
        self.content = content
        self.senderId = senderId
        self.receiverId = receiverId
        self.timestamp = timestamp
        self.isRead = isRead
        self.messageType = messageType
    }
} 