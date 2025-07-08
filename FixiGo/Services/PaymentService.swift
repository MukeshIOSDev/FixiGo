import Foundation
import Firebase
import FirebaseFirestore
import Combine

@MainActor
class PaymentService: ObservableObject, Sendable {
    @Published var paymentHistory: [Payment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Payment Processing
    func processPayment(bookingId: String, amount: Double, paymentMethod: PaymentMethod) async throws -> Payment {
        isLoading = true
        errorMessage = nil
        
        do {
            let payment = Payment(
                id: UUID().uuidString,
                bookingId: bookingId,
                amount: amount,
                paymentMethod: paymentMethod,
                status: .pending
            )
            
            // Save payment to Firestore
            try await savePaymentToFirestore(payment)
            
            // Simulate payment processing
            try await simulatePaymentProcessing(payment: payment)
            
            paymentHistory.append(payment)
            isLoading = false
            
            return payment
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
    }
    
    private func simulatePaymentProcessing(payment: Payment) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Simulate payment success (90% success rate)
        let isSuccess = Double.random(in: 0...1) < 0.9
        
        if isSuccess {
            try await updatePaymentStatus(paymentId: payment.id, status: .completed)
        } else {
            try await updatePaymentStatus(paymentId: payment.id, status: .failed)
            throw PaymentError.paymentFailed
        }
    }
    
    // MARK: - UPI Payment
    func initiateUPIPayment(bookingId: String, amount: Double, upiId: String) async throws -> Payment {
        let payment = Payment(
            id: UUID().uuidString,
            bookingId: bookingId,
            amount: amount,
            paymentMethod: .upi,
            status: .pending,
            upiId: upiId
        )
        
        try await savePaymentToFirestore(payment)
        
        // In a real app, you would integrate with UPI payment gateway
        // For now, we'll simulate the UPI payment process
        try await simulateUPIPayment(payment: payment)
        
        return payment
    }
    
    private func simulateUPIPayment(payment: Payment) async throws {
        // Simulate UPI payment flow
        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        
        // Simulate UPI payment success
        let isSuccess = Double.random(in: 0...1) < 0.95 // 95% success rate for UPI
        
        if isSuccess {
            try await updatePaymentStatus(paymentId: payment.id, status: .completed)
        } else {
            try await updatePaymentStatus(paymentId: payment.id, status: .failed)
            throw PaymentError.upiPaymentFailed
        }
    }
    
    // MARK: - Payment Status Management
    func updatePaymentStatus(paymentId: String, status: PaymentStatus) async throws {
        try await db.collection("payments").document(paymentId).updateData([
            "status": status.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ])
        
        // Update local payment history
        if let index = paymentHistory.firstIndex(where: { $0.id == paymentId }) {
            paymentHistory[index] = Payment(
                id: paymentHistory[index].id,
                bookingId: paymentHistory[index].bookingId,
                amount: paymentHistory[index].amount,
                paymentMethod: paymentHistory[index].paymentMethod,
                status: status,
                paymentDate: paymentHistory[index].paymentDate,
                transactionId: paymentHistory[index].transactionId,
                upiId: paymentHistory[index].upiId,
                refundAmount: paymentHistory[index].refundAmount,
                refundDate: paymentHistory[index].refundDate
            )
        }
        
        // If payment is completed, update booking status
        if status == .completed {
            try await updateBookingPaymentStatus(paymentId: paymentId)
        }
    }
    
    private func updateBookingPaymentStatus(paymentId: String) async throws {
        let paymentDoc = try await db.collection("payments").document(paymentId).getDocument()
        let payment = try paymentDoc.data(as: Payment.self)
        
        try await db.collection("bookings").document(payment.bookingId).updateData([
            "paymentStatus": "paid",
            "paymentId": paymentId,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
    
    // MARK: - Payment History
    func fetchPaymentHistory(userId: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection("payments")
                .whereField("userId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            let payments = try snapshot.documents.compactMap { document in
                try document.data(as: Payment.self)
            }
            
            paymentHistory = payments
            isLoading = false
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
    }
    
    func fetchPayment(paymentId: String) async throws -> Payment {
        let document = try await db.collection("payments").document(paymentId).getDocument()
        let payment = try document.data(as: Payment.self)
        return payment
    }
    
    // MARK: - Refunds
    func initiateRefund(paymentId: String, reason: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let payment = try await fetchPayment(paymentId: paymentId)
            
            guard payment.status == .completed else {
                throw PaymentError.refundNotAllowed
            }
            
            let refund = Refund(
                id: UUID().uuidString,
                paymentId: paymentId,
                amount: payment.amount,
                reason: reason,
                status: .pending
            )
            
            // Save refund to Firestore
            try await saveRefundToFirestore(refund)
            
            // Simulate refund processing
            try await simulateRefundProcessing(refund: refund)
            
            isLoading = false
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
    }
    
    private func simulateRefundProcessing(refund: Refund) async throws {
        // Simulate refund processing time
        try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        
        // Simulate refund success
        let isSuccess = Double.random(in: 0...1) < 0.98 // 98% success rate for refunds
        
        if isSuccess {
            try await updateRefundStatus(refundId: refund.id, status: .completed)
            
            // Update payment with refund information
            try await updatePaymentWithRefund(paymentId: refund.paymentId, refundAmount: refund.amount)
        } else {
            try await updateRefundStatus(refundId: refund.id, status: .failed)
            throw PaymentError.refundFailed
        }
    }
    
    private func updateRefundStatus(refundId: String, status: RefundStatus) async throws {
        try await db.collection("refunds").document(refundId).updateData([
            "status": status.rawValue,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
    
    private func updatePaymentWithRefund(paymentId: String, refundAmount: Double) async throws {
        try await db.collection("payments").document(paymentId).updateData([
            "refundAmount": refundAmount,
            "refundDate": FieldValue.serverTimestamp(),
            "status": PaymentStatus.refunded.rawValue
        ])
    }
    
    // MARK: - Analytics
    func getPaymentAnalytics(userId: String) async throws -> PaymentAnalytics {
        let snapshot = try await db.collection("payments")
            .whereField("userId", isEqualTo: userId)
            .getDocuments()
        
        let payments = try snapshot.documents.compactMap { document in
            try document.data(as: Payment.self)
        }
        
        let totalAmount = payments.reduce(0) { $0 + $1.amount }
        let completedPayments = payments.filter { $0.status == .completed }
        let failedPayments = payments.filter { $0.status == .failed }
        let refundedPayments = payments.filter { $0.status == .refunded }
        
        return PaymentAnalytics(
            totalPayments: payments.count,
            totalAmount: totalAmount,
            completedPayments: completedPayments.count,
            failedPayments: failedPayments.count,
            refundedPayments: refundedPayments.count,
            successRate: payments.isEmpty ? 0 : Double(completedPayments.count) / Double(payments.count)
        )
    }
    
    // MARK: - Helper Methods
    private func savePaymentToFirestore(_ payment: Payment) async throws {
        try await db.collection("payments")
            .document(payment.id)
            .setData(from: payment)
    }
    
    private func saveRefundToFirestore(_ refund: Refund) async throws {
        try await db.collection("refunds")
            .document(refund.id)
            .setData(from: refund)
    }
}

// MARK: - Supporting Models
struct Refund: Identifiable, Codable {
    let id: String
    let paymentId: String
    let amount: Double
    let reason: String
    let status: RefundStatus
    let createdAt: Date
    
    init(id: String = UUID().uuidString,
         paymentId: String,
         amount: Double,
         reason: String,
         status: RefundStatus = .pending,
         createdAt: Date = Date()) {
        self.id = id
        self.paymentId = paymentId
        self.amount = amount
        self.reason = reason
        self.status = status
        self.createdAt = createdAt
    }
}

enum RefundStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
}

struct PaymentAnalytics {
    let totalPayments: Int
    let totalAmount: Double
    let completedPayments: Int
    let failedPayments: Int
    let refundedPayments: Int
    let successRate: Double
}

// MARK: - Custom Errors
enum PaymentError: LocalizedError {
    case paymentFailed
    case upiPaymentFailed
    case paymentNotFound
    case refundNotAllowed
    case refundFailed
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .paymentFailed:
            return "Payment processing failed. Please try again."
        case .upiPaymentFailed:
            return "UPI payment failed. Please check your UPI ID and try again."
        case .paymentNotFound:
            return "Payment not found."
        case .refundNotAllowed:
            return "Refund is not allowed for this payment."
        case .refundFailed:
            return "Refund processing failed. Please contact support."
        case .networkError:
            return "Network error. Please check your connection."
        case .unknown:
            return "An unknown error occurred."
        }
    }
} 