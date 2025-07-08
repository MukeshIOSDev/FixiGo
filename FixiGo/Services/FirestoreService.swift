import Foundation
import Firebase
import FirebaseFirestore
import CoreLocation
import Combine

@MainActor
class FirestoreService: ObservableObject, Sendable {
    private let db = Firestore.firestore()
    
    // MARK: - Helper Methods for Parsing
    private func parseWorker(from data: [String: Any]) -> Worker? {
        guard let id = data["id"] as? String,
              let name = data["name"] as? String,
              let email = data["email"] as? String,
              let phone = data["phone"] as? String,
              let address = data["address"] as? String,
              let servicesRaw = data["services"] as? [String],
              let rating = data["rating"] as? Double,
              let totalJobs = data["totalJobs"] as? Int,
              let isVerified = data["isVerified"] as? Bool,
              let createdAtTimestamp = data["createdAt"] as? Timestamp else {
            return nil
        }
        let services = servicesRaw.compactMap { ServiceType(rawValue: $0) }
        let createdAt = createdAtTimestamp.dateValue()
        return Worker(
            id: id,
            name: name,
            email: email,
            phone: phone,
            address: address,
            services: services,
            rating: rating,
            totalJobs: totalJobs,
            isVerified: isVerified,
            createdAt: createdAt
        )
    }
    
    private func parseBooking(from data: [String: Any]) -> Booking? {
        guard let id = data["id"] as? String,
              let customerId = data["customerId"] as? String,
              let workerId = data["workerId"] as? String,
              let serviceTypeRaw = data["serviceType"] as? String,
              let serviceType = ServiceType(rawValue: serviceTypeRaw),
              let dateTimestamp = data["date"] as? Timestamp,
              let timeTimestamp = data["time"] as? Timestamp,
              let description = data["description"] as? String,
              let address = data["address"] as? String,
              let statusRaw = data["status"] as? String,
              let status = BookingStatus(rawValue: statusRaw),
              let estimatedCostMin = data["estimatedCostMin"] as? Double,
              let estimatedCostMax = data["estimatedCostMax"] as? Double,
              let createdAtTimestamp = data["createdAt"] as? Timestamp
        else {
            return nil
        }
        let actualCost = data["actualCost"] as? Double
        let completedAt = (data["completedAt"] as? Timestamp)?.dateValue()
        let rating = data["rating"] as? Double
        let review = data["review"] as? String
        let estimatedCost: ClosedRange<Double> = estimatedCostMin...estimatedCostMax
        return Booking(
            id: id,
            customerId: customerId,
            workerId: workerId,
            serviceType: serviceType,
            date: dateTimestamp.dateValue(),
            time: timeTimestamp.dateValue(),
            description: description,
            address: address,
            status: status,
            estimatedCost: estimatedCost,
            createdAt: createdAtTimestamp.dateValue(),
            actualCost: actualCost,
            completedAt: completedAt,
            rating: rating,
            review: review
        )
    }
    
    private func parseChatMessage(from data: [String: Any]) -> ChatMessage? {
        guard let id = data["id"] as? String,
              let senderId = data["senderId"] as? String,
              let receiverId = data["receiverId"] as? String,
              let content = data["content"] as? String else {
            return nil
        }
        
        return ChatMessage(
            id: id,
            content: content,
            senderId: senderId,
            receiverId: receiverId,
            timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
            isRead: data["isRead"] as? Bool ?? false
        )
    }
    
    private func parseReview(from data: [String: Any]) -> Review? {
        guard let id = data["id"] as? String,
              let userId = data["userId"] as? String,
              let workerId = data["workerId"] as? String,
              let rating = data["rating"] as? Int,
              let dateTimestamp = data["date"] as? Timestamp else {
            return nil
        }
        let comment = data["comment"] as? String
        return Review(
            id: id,
            userId: userId,
            workerId: workerId,
            rating: rating,
            comment: comment,
            date: dateTimestamp.dateValue()
        )
    }
    
    private func parseUser(from data: [String: Any]) -> User? {
        guard let id = data["id"] as? String,
              let name = data["name"] as? String,
              let email = data["email"] as? String,
              let phone = data["phone"] as? String,
              let userTypeString = data["userType"] as? String,
              let userType = UserType(rawValue: userTypeString) else {
            return nil
        }
        
        return User(
            id: id,
            name: name,
            email: email,
            phone: phone,
            address: data["address"] as? String ?? "",
            userType: userType,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        )
    }
    
    // MARK: - Workers Management
    func fetchNearbyWorkers(location: CLLocation, radius: Double) async throws -> [Worker] {
        let snapshot = try await db.collection("workers")
            .whereField("isActive", isEqualTo: true)
            .getDocuments()
        
        let workers = snapshot.documents.compactMap { document in
            parseWorker(from: document.data())
        }
        
        // Filter by distance (simplified - in production use proper geospatial queries)
        return workers.filter { worker in
            let workerLocation = CLLocation(latitude: worker.coordinate.latitude, longitude: worker.coordinate.longitude)
            let distance = location.distance(from: workerLocation) / 1000 // Convert to km
            return distance <= radius
        }
    }
    
    func fetchWorker(workerId: String) async throws -> Worker {
        let document = try await db.collection("workers").document(workerId).getDocument()
        guard let data = document.data(),
              let worker = parseWorker(from: data) else {
            throw FirestoreError.documentNotFound
        }
        return worker
    }
    
    func saveWorker(_ worker: Worker) async throws {
        try await db.collection("workers").document(worker.id).setData([
            "id": worker.id,
            "name": worker.name,
            "email": worker.email,
            "phone": worker.phone,
            "address": worker.address,
            "services": worker.services.map { $0.rawValue },
            "rating": worker.rating,
            "totalJobs": worker.totalJobs,
            "isVerified": worker.isVerified,
            "createdAt": worker.createdAt
        ])
    }
    
    func updateWorkerAvailability(workerId: String, isAvailable: Bool) async throws {
        try await db.collection("workers").document(workerId).updateData([
            "isAvailable": isAvailable
        ])
    }
    
    // MARK: - Bookings Management
    func createBooking(_ booking: Booking) async throws {
        try await db.collection("bookings").document(booking.id).setData([
            "id": booking.id,
            "customerId": booking.customerId,
            "workerId": booking.workerId,
            "serviceType": booking.serviceType.rawValue,
            "date": booking.date,
            "time": booking.time,
            "description": booking.description,
            "address": booking.address,
            "status": booking.status.rawValue,
            "estimatedCostMin": booking.estimatedCost.lowerBound,
            "estimatedCostMax": booking.estimatedCost.upperBound,
            "createdAt": booking.createdAt,
            "actualCost": booking.actualCost as Any,
            "completedAt": booking.completedAt as Any,
            "rating": booking.rating as Any,
            "review": booking.review as Any
        ])
        
        // Update worker's booking count
        try await db.collection("workers").document(booking.workerId).updateData([
            "totalJobs": FieldValue.increment(Int64(1))
        ])
    }
    
    func fetchUserBookings(userId: String, userType: UserType) async throws -> [Booking] {
        let field = userType == .customer ? "customerId" : "workerId"
        let snapshot = try await db.collection("bookings")
            .whereField(field, isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            parseBooking(from: document.data())
        }
    }
    
    func updateBookingStatus(bookingId: String, status: BookingStatus) async throws {
        try await db.collection("bookings").document(bookingId).updateData([
            "status": status.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
    
    func fetchBooking(bookingId: String) async throws -> Booking {
        let document = try await db.collection("bookings").document(bookingId).getDocument()
        guard let data = document.data(),
              let booking = parseBooking(from: data) else {
            throw FirestoreError.documentNotFound
        }
        return booking
    }
    
    // MARK: - Chat Management
    func saveMessage(_ message: ChatMessage) async throws {
        let chatId = [message.senderId, message.receiverId].sorted().joined(separator: "_")
        try await db.collection("chats")
            .document(chatId)
            .collection("messages")
            .document(message.id)
            .setData([
                "id": message.id,
                "senderId": message.senderId,
                "receiverId": message.receiverId,
                "content": message.content,
                "timestamp": message.timestamp,
                "isRead": message.isRead
            ])
    }
    
    func fetchChatMessages(userId1: String, userId2: String) async throws -> [ChatMessage] {
        let chatId = [userId1, userId2].sorted().joined(separator: "_")
        let snapshot = try await db.collection("chats")
            .document(chatId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            parseChatMessage(from: document.data())
        }
    }
    
    func markMessageAsRead(messageId: String, chatId: String) async throws {
        try await db.collection("chats")
            .document(chatId)
            .collection("messages")
            .document(messageId)
            .updateData([
                "isRead": true
            ])
    }
    
    // MARK: - Reviews Management
    func saveReview(_ review: Review) async throws {
        try await db.collection("reviews").document(review.id).setData([
            "id": review.id,
            "userId": review.userId,
            "workerId": review.workerId,
            "rating": review.rating,
            "comment": review.comment as Any,
            "date": review.date
        ])
    }
    
    // MARK: - User Management
    func createUser(_ user: User) async throws {
        try await db.collection("users").document(user.id).setData([
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "phone": user.phone,
            "address": user.address,
            "userType": user.userType.rawValue,
            "createdAt": user.createdAt
        ])
    }
    
    func fetchUser(userId: String) async throws -> User {
        let document = try await db.collection("users").document(userId).getDocument()
        guard let data = document.data(),
              let user = parseUser(from: data) else {
            throw FirestoreError.documentNotFound
        }
        return user
    }
    
    // MARK: - Search and Filtering
    func searchWorkers(query: String, serviceType: ServiceType? = nil) async throws -> [Worker] {
        var queryRef = db.collection("workers").whereField("isActive", isEqualTo: true)
        
        if let serviceType = serviceType {
            queryRef = queryRef.whereField("services", arrayContains: serviceType.rawValue)
        }
        
        let snapshot = try await queryRef.getDocuments()
        let workers = snapshot.documents.compactMap { document in
            parseWorker(from: document.data())
        }
        
        // Filter by search query
        if !query.isEmpty {
            return workers.filter { worker in
                worker.name.localizedCaseInsensitiveContains(query) ||
                worker.services.contains { service in
                    service.rawValue.localizedCaseInsensitiveContains(query)
                }
            }
        }
        
        return workers
    }
    
    // MARK: - Analytics and Statistics
    func getWorkerStats(workerId: String) async throws -> WorkerStats {
        let bookings = try await fetchUserBookings(userId: workerId, userType: .worker)
        
        let completedBookings = bookings.filter { $0.status == .completed }
        let totalEarnings = completedBookings.compactMap { $0.actualCost }.reduce(0, +)
        let averageRating = bookings.map { $0.rating ?? 0.0 }.reduce(0, +) / Double(max(bookings.count, 1))
        
        return WorkerStats(
            totalBookings: bookings.count,
            completedBookings: completedBookings.count,
            totalEarnings: totalEarnings,
            averageRating: averageRating,
            totalReviews: bookings.count
        )
    }
    
    func getUserStats(userId: String) async throws -> UserStats {
        let bookings = try await fetchUserBookings(userId: userId, userType: .customer)
        
        let completedBookings = bookings.filter { $0.status == .completed }
        let pendingBookings = bookings.filter { $0.status == .pending }
        
        return UserStats(
            totalBookings: bookings.count,
            completedBookings: completedBookings.count,
            pendingBookings: pendingBookings.count
        )
    }
}

// MARK: - Supporting Models
struct WorkerStats {
    let totalBookings: Int
    let completedBookings: Int
    let totalEarnings: Double
    let averageRating: Double
    let totalReviews: Int
}

struct UserStats {
    let totalBookings: Int
    let completedBookings: Int
    let pendingBookings: Int
}

// MARK: - Custom Errors
enum FirestoreError: LocalizedError {
    case documentNotFound
    case invalidData
    case networkError
    case permissionDenied
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Document not found"
        case .invalidData:
            return "Invalid data format"
        case .networkError:
            return "Network error. Please check your connection"
        case .permissionDenied:
            return "Permission denied"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 
