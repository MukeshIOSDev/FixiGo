import Foundation
import Firebase
import FirebaseMessaging
import UserNotifications
import Combine
import FirebaseAuth

@MainActor
@preconcurrency
class NotificationService: NSObject, ObservableObject, Sendable {
    @Published var fcmToken: String?
    @Published var isPermissionGranted: Bool = false
    @Published var errorMessage: String?
    
    private let messaging = Messaging.messaging()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupNotifications()
        setupTokenRefresh()
    }
    
    // MARK: - Setup
    private func setupNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        // Request permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            Task { @MainActor in
                self?.isPermissionGranted = granted
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
        
        // Set messaging delegate
        messaging.delegate = self
    }
    
    private func setupTokenRefresh() {
        messaging.token { [weak self] token, error in
            Task { @MainActor in
                if let error = error {
                    self?.errorMessage = "Failed to get FCM token: \(error.localizedDescription)"
                } else if let token = token {
                    self?.fcmToken = token
                    self?.saveTokenToServer(token: token)
                }
            }
        }
    }
    
    // MARK: - Token Management
    private func saveTokenToServer(token: String) {
        // Save token to Firestore for the current user
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let tokenData: [String: Any] = [
            "token": token,
            "userId": userId,
            "platform": "iOS",
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        Firestore.firestore().collection("fcmTokens").document(userId).setData(tokenData) { error in
            if let error = error {
                Task { @MainActor in
                    self.errorMessage = "Failed to save token: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func refreshToken() {
        messaging.token { [weak self] token, error in
            Task { @MainActor in
                if let error = error {
                    self?.errorMessage = "Failed to refresh token: \(error.localizedDescription)"
                } else if let token = token {
                    self?.fcmToken = token
                    self?.saveTokenToServer(token: token)
                }
            }
        }
    }
    
    // MARK: - Topic Management
    func subscribeToTopic(_ topic: String) {
        messaging.subscribe(toTopic: topic) { error in
            if let error = error {
                Task { @MainActor in
                    self.errorMessage = "Failed to subscribe to topic: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func unsubscribeFromTopic(_ topic: String) {
        messaging.unsubscribe(fromTopic: topic) { error in
            if let error = error {
                Task { @MainActor in
                    self.errorMessage = "Failed to unsubscribe from topic: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Local Notifications
    func scheduleLocalNotification(title: String, body: String, timeInterval: TimeInterval = 0) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Task { @MainActor in
                    self.errorMessage = "Failed to schedule notification: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func scheduleBookingReminder(bookingId: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = ["bookingId": bookingId]
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date), repeats: false)
        let request = UNNotificationRequest(identifier: "booking_\(bookingId)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                Task { @MainActor in
                    self.errorMessage = "Failed to schedule booking reminder: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Notification Categories
    func setupNotificationCategories() {
        // Booking actions
        let acceptAction = UNNotificationAction(
            identifier: "ACCEPT_BOOKING",
            title: "Accept",
            options: [.foreground]
        )
        
        let declineAction = UNNotificationAction(
            identifier: "DECLINE_BOOKING",
            title: "Decline",
            options: [.destructive]
        )
        
        let bookingCategory = UNNotificationCategory(
            identifier: "BOOKING_REQUEST",
            actions: [acceptAction, declineAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Chat actions
        let replyAction = UNTextInputNotificationAction(
            identifier: "REPLY_MESSAGE",
            title: "Reply",
            options: [],
            textInputButtonTitle: "Send",
            textInputPlaceholder: "Type your message..."
        )
        
        let chatCategory = UNNotificationCategory(
            identifier: "CHAT_MESSAGE",
            actions: [replyAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([bookingCategory, chatCategory])
    }
    
    // MARK: - Cleanup
    func cleanup() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Remove token from server
        Firestore.firestore().collection("fcmTokens").document(userId).delete()
        
        // Unsubscribe from all topics
        messaging.unsubscribe(fromTopic: "all")
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle notification actions
        switch response.actionIdentifier {
        case "ACCEPT_BOOKING":
            if let bookingId = userInfo["bookingId"] as? String {
                handleBookingAction(bookingId: bookingId, action: .accept)
            }
        case "DECLINE_BOOKING":
            if let bookingId = userInfo["bookingId"] as? String {
                handleBookingAction(bookingId: bookingId, action: .decline)
            }
        case "REPLY_MESSAGE":
            if let response = response as? UNTextInputNotificationResponse,
               let chatId = userInfo["chatId"] as? String {
                handleChatReply(chatId: chatId, message: response.userText)
            }
        default:
            // Handle default tap
            handleNotificationTap(userInfo: userInfo)
        }
        
        completionHandler()
    }
    
    private func handleBookingAction(bookingId: String, action: BookingAction) {
        // Update booking status in Firestore
        Task {
            do {
                let status: BookingStatus = action == .accept ? .confirmed : .cancelled
                try await FirestoreService().updateBookingStatus(bookingId: bookingId, status: status)
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to update booking: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func handleChatReply(chatId: String, message: String) {
        // Send reply message
        // This would typically navigate to chat view and send the message
        print("Reply to chat \(chatId): \(message)")
    }
    
    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        // Navigate to appropriate screen based on notification type
        if let bookingId = userInfo["bookingId"] as? String {
            // Navigate to booking details
            print("Navigate to booking: \(bookingId)")
        } else if let chatId = userInfo["chatId"] as? String {
            // Navigate to chat
            print("Navigate to chat: \(chatId)")
        }
    }
}

// MARK: - MessagingDelegate
extension NotificationService: MessagingDelegate {
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Task { @MainActor in
            self.fcmToken = fcmToken
            if let token = fcmToken {
                self.saveTokenToServer(token: token)
            }
        }
    }
}

// MARK: - Supporting Types
enum BookingAction {
    case accept
    case decline
} 