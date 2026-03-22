import Foundation
import SwiftData

@Model
class ImaginalSession {
    var date: Date
    var initialUrgeRating: Int
    var finalUrgeRating: Int

    init(initialUrgeRating: Int, finalUrgeRating: Int) {
        self.date = Date()
        self.initialUrgeRating = initialUrgeRating
        self.finalUrgeRating = finalUrgeRating
    }
}
