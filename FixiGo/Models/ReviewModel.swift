import Foundation

struct Review: Identifiable, Codable {
    let id: String
    let userId: String
    let workerId: String
    let rating: Int
    let comment: String?
    let date: Date
    
    init(id: String = UUID().uuidString,
         userId: String,
         workerId: String,
         rating: Int,
         comment: String? = nil,
         date: Date = Date()) {
        self.id = id
        self.userId = userId
        self.workerId = workerId
        self.rating = rating
        self.comment = comment
        self.date = date
    }
} 