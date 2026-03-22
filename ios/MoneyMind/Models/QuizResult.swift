import Foundation
import SwiftData

@Model
class QuizResult {
    var stressResponse: String
    var biggestTrigger: String
    var desiredFeeling: String
    var personalityType: String
    var createdAt: Date

    init(stressResponse: String, biggestTrigger: String, desiredFeeling: String) {
        self.stressResponse = stressResponse
        self.biggestTrigger = biggestTrigger
        self.desiredFeeling = desiredFeeling
        self.createdAt = Date()

        switch (stressResponse, biggestTrigger) {
        case ("Spend", "Boredom"), ("Spend", "FOMO"):
            self.personalityType = "The Thrill Seeker"
        case ("Spend", "Stress"), ("Spend", "Social pressure"):
            self.personalityType = "The Comfort Spender"
        case ("Gamble", _):
            self.personalityType = "The Risk Taker"
        case ("Avoid", "Stress"), ("Avoid", "Social pressure"):
            self.personalityType = "The Ostrich"
        case ("Avoid", _):
            self.personalityType = "The Avoider"
        default:
            self.personalityType = "The Mindful One"
        }
    }
}
