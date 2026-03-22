import Foundation
import SwiftData

@Model
class AccountabilityPartner {
    var partnerName: String
    var matchDate: Date
    var selectedReason: String
    var streakLength: Int
    var lastCheckInDate: Date?
    var checkInDay: Int

    init(partnerName: String, selectedReason: String, streakLength: Int, checkInDay: Int = 1) {
        self.partnerName = partnerName
        self.matchDate = Date()
        self.selectedReason = selectedReason
        self.streakLength = streakLength
        self.lastCheckInDate = nil
        self.checkInDay = checkInDay
    }
}
