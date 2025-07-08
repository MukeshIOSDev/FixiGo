import Foundation

struct User: Identifiable, Codable {
    let id: String
    var name: String
    var email: String
    var phone: String
    var address: String
    let userType: UserType
    let createdAt: Date
}

struct UserSignupData {
    let name: String
    let email: String
    let phone: String
    let address: String
    let password: String
    let userType: UserType
    let services: [ServiceType]
} 