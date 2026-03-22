import ActivityKit
import SwiftUI

struct CoolingOffAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var motivationQuote: String
    }

    var endTime: Date
    var triggerReason: String
}
