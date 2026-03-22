import Foundation
import SwiftData

@Model
class ReferralCode {
    var code: String
    var referredUserId: String
    var dateReferred: Date
    var converted: Bool

    init(code: String, referredUserId: String = "", converted: Bool = false) {
        self.code = code
        self.referredUserId = referredUserId
        self.dateReferred = Date()
        self.converted = converted
    }
}
