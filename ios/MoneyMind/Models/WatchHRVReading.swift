import Foundation
import SwiftData

@Model
class WatchHRVReading {
    var timestamp: Date
    var rmssd: Double
    var isStressDetected: Bool

    init(timestamp: Date = Date(), rmssd: Double, isStressDetected: Bool = false) {
        self.timestamp = timestamp
        self.rmssd = rmssd
        self.isStressDetected = isStressDetected
    }
}
