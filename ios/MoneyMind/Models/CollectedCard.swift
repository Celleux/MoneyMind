import Foundation
import SwiftData

@Model
class CollectedCard {
    var id: UUID = UUID()
    var cardID: String = ""
    var rarity: String = "Common"
    var setName: String = ""
    var obtainedAt: Date = Date()
    var duplicateCount: Int = 0
    var isNew: Bool = true
    var evolutionLevel: Int = 0

    var isMaxEvolved: Bool {
        evolutionLevel >= 2
    }

    init(cardID: String = "", rarity: String = "Common", setName: String = "") {
        self.cardID = cardID
        self.rarity = rarity
        self.setName = setName
    }
}
