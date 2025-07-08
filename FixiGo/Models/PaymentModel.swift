import Foundation

enum PaymentMethod: String, Codable, CaseIterable {
    case creditCard = "credit_card"
    case debitCard = "debit_card"
    case upi = "upi"
    case netBanking = "net_banking"
    case wallet = "wallet"
    case cash = "cash"
}

enum PaymentStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
    case refunded = "refunded"
    case cancelled = "cancelled"
}

struct Payment: Identifiable, Codable {
    let id: String
    let bookingId: String
    let amount: Double
    let paymentMethod: PaymentMethod
    let status: PaymentStatus
    let paymentDate: Date
    let transactionId: String?
    let upiId: String?
    let refundAmount: Double?
    let refundDate: Date?
    
    init(id: String = UUID().uuidString,
         bookingId: String,
         amount: Double,
         paymentMethod: PaymentMethod,
         status: PaymentStatus = .pending,
         paymentDate: Date = Date(),
         transactionId: String? = nil,
         upiId: String? = nil,
         refundAmount: Double? = nil,
         refundDate: Date? = nil) {
        self.id = id
        self.bookingId = bookingId
        self.amount = amount
        self.paymentMethod = paymentMethod
        self.status = status
        self.paymentDate = paymentDate
        self.transactionId = transactionId
        self.upiId = upiId
        self.refundAmount = refundAmount
        self.refundDate = refundDate
    }
} 